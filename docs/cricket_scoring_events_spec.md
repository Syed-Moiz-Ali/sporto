# Cricket Scoring — Complete Events Spec (Start → End)

**Purpose:** define every action the app sends and every event the backend must emit for a cricket match, so the app can render everything from server state — nothing computed locally.

---

## 1. Match lifecycle (phases)

```
ASSIGN → ACCEPT → TOSS → START → INNINGS 1 → INNINGS BREAK → INNINGS 2 → COMPLETE
                                                        └─ (if tie) SUPER OVER → COMPLETE
```

---

## 2. Client → Server actions (what the app sends)

| # | Action | Payload | When |
|---|---|---|---|
| 1 | `START` | `{action}` | After toss completed, to go LIVE |
| 2 | `SET_BATTERS` | `{action, striker_user_id, non_striker_user_id}` | Innings start (openers), after every wicket (replacement) |
| 3 | `SET_BOWLER` | `{action, bowler_user_id}` | Start of every over (including first, and after over complete) |
| 4 | `SET_WICKET_KEEPER` | `{action, wicket_keeper_user_id}` | Optional |
| 5a | `ADD_EVENT` RUN | `{action, event_code:"RUN", team_id, player_id, value}` value ∈ 0,1,2,3,4,6 | Legal ball, runs off bat |
| 5b | `ADD_EVENT` WIDE | `{action, event_code:"WIDE", team_id}` | Illegal ball, +1 extra, no ball count |
| 5c | `ADD_EVENT` NO_BALL | `{action, event_code:"NO_BALL", team_id, value?}` | Illegal ball, +1 extra (+ optional runs off bat) |
| 5d | `ADD_EVENT` WICKET | `{action, event_code:"WICKET", team_id, player_id, wicket_type?, value?}` | Legal ball, dismissal |
| 6 | `UNDO_LAST` | `{action}` | Revert last ball |
| 7 | `END_PERIOD` | `{action}` | End of innings only (after innings complete) |
| 8 | `START_SUPER_OVER` | `{action}` | Only when regulation ends in a tie |
| 9 | `COMPLETE` | `{action}` | After final period finished |

**Recommended addition to the event config** (`scoring_configuration.events[]`) — required by the tracking code:
`BYE` (1–4) and `LEG_BYE` (1–4) as optional events, and **`is_legal_delivery`** per event:
- Legal: `RUN`, `WICKET`, `BYE`, `LEG_BYE` → `is_legal_delivery: true`
- Illegal: `WIDE`, `NO_BALL` → `is_legal_delivery: false`
(If the key is missing, default it in code — currently it 500s.)

**Wicket types (optional field `wicket_type`):**
`BOWLED`, `CAUGHT`, `LBW`, `RUN_OUT`, `STUMPED`, `HIT_WICKET`, `RETIRED_HURT`, `OBSTRUCTION`, `TIMED_OUT`.

---

## 2.1 Cricket Option Codes (enums) — required by the app

### Wicket / dismissal types (`wicket_type` on `ADD_EVENT WICKET`)
**Required (must support):**
| Code | Notes |
|---|---|
| `BOWLED` | dismissed = striker |
| `CAUGHT` | dismissed = striker |
| `LBW` | dismissed = striker |
| `RUN_OUT` | can dismiss **striker or non-striker**; allow `value` = runs completed before the run-out (0–3) |
| `STUMPED` | dismissed = striker |
| `HIT_WICKET` | dismissed = striker |
| `RETIRED_HURT` | batter leaves injured; **does NOT count as a team wicket**, can return |

**Optional (full laws of cricket):**
| Code | Notes |
|---|---|
| `CAUGHT_AND_BOWLED` | display variant of CAUGHT |
| `HIT_BALL_TWICE` | rare |
| `OBSTRUCTING_THE_FIELD` | rare |
| `TIMED_OUT` | rare |
| `RETIRED_OUT` | retired but not returning |
| `MANKAD` | treated as `RUN_OUT` (non-striker) |

### Extras (`event_code` on `ADD_EVENT`)
| Code | Ball counts to over? | Runs | Strike rotation |
|---|---|---|---|
| `WIDE` | ❌ no | +1 (plus additional runs optional) | no (v1) |
| `NO_BALL` | ❌ no | +1 penalty (+ optional `value` runs off bat) | no (v1) |
| `BYE` | ✅ yes | `value` 1–4 (not credited to batter) | odd value rotates |
| `LEG_BYE` | ✅ yes | `value` 1–4 (not credited to batter) | odd value rotates |
| `PENALTY_RUN` | ❌ no (not a delivery) | +5 to batting team (optional v2) | no |

### Runs off the bat (`value` on `RUN`)
`0, 1, 2, 3, 4, 5, 6` (5 is rare/overthrows; app currently uses `0,1,2,3,4,6`)

### Innings lifecycle event codes (backend → app, in `runtime.events[]`)
`MATCH_STARTED`, `INNINGS_STARTED`, `BATTER_REPLACED`, `OVER_STARTED`, `BOWLER_CHANGED`, `WICKET_KEEPER_CHANGED`, `BALL_RECORDED`, `STRIKE_ROTATED`, `OVER_COMPLETE`, `WICKET_RECORDED`, `INNINGS_COMPLETE`, `INNINGS_CHANGED`, `SUPER_OVER_STARTED`, `MATCH_COMPLETED`, `EVENT_UNDONE`

**Wicket-specific payload extras the app needs in `WICKET_RECORDED`:**
- `dismissed_user_id` (striker or non-striker for run-out)
- `wicket_type` (code from the list above)
- `value` (runs completed before dismissal, for run-outs)
- `requires_replacement: true` (side not out yet)

---

## 3. Server → App events (what backend emits in `runtime.events[]` + `runtime.last_event`)

Every event: `{ type, sequence, occurred_at, data:{...} }` (format already implemented).

| Event type | Emitted when | `data` payload | App reaction |
|---|---|---|---|
| `MATCH_STARTED` | `START` applied | `{}` | Enter live scoring |
| `INNINGS_STARTED` | first ball of an innings (or on START / after END_PERIOD) | `{inning, batting_team_id, bowling_team_id}` | Show openers selection |
| `BATTER_REPLACED` ✅ *(exists)* | `SET_BATTERS` applied | `{striker_user_id, non_striker_user_id}` | Update batter display |
| `OVER_STARTED` ✅ *(exists)* | `SET_BOWLER` applied | `{bowler_user_id, over_number}` | Update bowler display |
| `WICKET_KEEPER_CHANGED` | `SET_WICKET_KEEPER` applied | `{wicket_keeper_user_id}` | Optional UI |
| `BALL_RECORDED` | every `ADD_EVENT` | `{event_code, is_legal_delivery, value, runs_total, striker_user_id, over_number, ball_in_over}` | Ball-by-ball feed, score card |
| `STRIKE_ROTATED` | odd runs (RUN/BYE/LEG_BYE) **and at over end** | `{striker_user_id, non_striker_user_id, reason: "ODD_RUN" \| "OVER_END"}` | Swap striker UI |
| `OVER_COMPLETE` | 6th legal ball | `{over_number, bowler_user_id, runs_in_over, wickets_in_over}` | Require new bowler (`SET_BOWLER`) |
| `WICKET_RECORDED` | `ADD_EVENT` WICKET | `{dismissed_user_id, wicket_type, team_wickets, requires_replacement: true}` | Show replacement batter picker |
| `INNINGS_COMPLETE` | overs done / all out / target passed | `{inning, reason: "OVERS_DONE" \| "ALL_OUT" \| "TARGET_REACHED"}` | Enable `END_PERIOD` |
| `INNINGS_CHANGED` | `END_PERIOD` applied | `{from_inning, to_inning, batting_team_id, bowling_team_id, target, runs_required}` | Show new openers + new fielding side |
| `SUPER_OVER_STARTED` ✅ *(exists)* | `START_SUPER_OVER` applied | `{round}` | Show super-over openers |
| `MATCH_COMPLETED` | `COMPLETE` applied | `{winner_team_id, result_status: "WIN"\|"DRAW"\|"TIE"}` | Final result screen |
| `EVENT_UNDONE` | `UNDO_LAST` applied | `{undone_event_type, restored_state summary}` | Roll back UI to returned state |

---

## 4. Rules the backend must enforce

1. **Legal deliveries:** `RUN`, `WICKET`, `BYE`, `LEG_BYE` count toward the 6-ball over; `WIDE`, `NO_BALL` do **not**.
2. **Strike rotation (automatic):**
   - odd runs (RUN/BYE/LEG_BYE) → swap striker ↔ non-striker
   - **end of over (6th legal ball) → swap striker ↔ non-striker** as well
   - WIDE/NO_BALL do not rotate (unless additional runs are completed — optional v2)
3. **Over complete:** on 6th legal ball → `OVER_COMPLETE`, clear `current_bowler`, `awaiting_bowler: true`, block `ADD_EVENT` until `SET_BOWLER`.
4. **Wicket:** dismissed striker leaves; `current_striker: null`, `awaiting_batter: true`, add to `dismissed_batters`, increment team wickets; block `ADD_EVENT` until `SET_BATTERS` (new batter + existing non-striker, bowler preserved).
5. **Validation on `ADD_EVENT` (4xx, never 5xx):**
   - `team_id` must be current batting team
   - `player_id` must be current striker (for RUN/WICKET)
   - `current_bowler` must be set; `over_complete` false; `awaiting_batter` false
   - `event_code` ∈ configured `available_events`; `value` ∈ `allowed_values`
6. **Innings complete:** overs exhausted OR all out OR target passed (innings 2). Only then is `END_PERIOD` allowed; otherwise `409`.
7. **Innings change (`END_PERIOD`):** swap batting/bowling teams, clear striker/non-striker/bowler, reset `current_over/current_ball`, set `target` and `runs_required` for the chase.
8. **Super over:** `START_SUPER_OVER` allowed only when regulation scores are tied and both periods finished; track `super_over_round`; tie again → allow another round; else `COMPLETE`.
9. **UNDO_LAST:** full snapshot rollback (score, wickets, ball count, striker pair, bowler, awaiting flags, dismissed list) + `EVENT_UNDONE` event.
10. **No 500s from missing config keys** — default `is_legal_delivery` and wicket types gracefully.

---

## 5. Required runtime/score fields (from server)

```
runtime: {
  state, current_inning, current_over, current_ball,
  awaiting_batter, awaiting_bowler, over_complete?,
  current_over_deliveries[], innings_complete, dismissed_batters[],
  is_super_over, super_over_round,
  current_batting_team_id, current_bowling_team_id,
  current_striker, current_non_striker, current_bowler, current_wicket_keeper,
  target, runs_required,
  events[], last_event
}
score.teams[teamId]: { score, wickets, legal_balls, overs }
score.super_over.regulation_teams: { ... }
```

---

## 6. Example: one over end-to-end

```
SET_BOWLER(12228)                    → OVER_STARTED {bowler_user_id:12228, over_number:1}
RUN value=1 by 12261                 → BALL_RECORDED {RUN, legal:true, value:1, ball:1}
                                     → STRIKE_ROTATED {reason:"ODD_RUN"}   (striker now 12262)
WIDE                                 → BALL_RECORDED {WIDE, legal:false, runs_total:1, ball:1}
RUN value=0 by 12262                 → BALL_RECORDED {RUN, legal:true, value:0, ball:2}
RUN value=4 by 12262                 → BALL_RECORDED {RUN, legal:true, value:4, ball:3}
WICKET by 12262                      → BALL_RECORDED {WICKET, legal:true, ball:4}
                                     → WICKET_RECORDED {dismissed_user_id:12262, requires_replacement:true}
SET_BATTERS(12263, 12261)            → BATTER_REPLACED {striker_user_id:12263, non_striker_user_id:12261}
RUN value=0 by 12263                 → ball:5
RUN value=0 by 12263                 → ball:6
                                     → OVER_COMPLETE {over_number:1}
                                     → STRIKE_ROTATED {reason:"OVER_END"}
SET_BOWLER(12229)                    → OVER_STARTED {bowler_user_id:12229, over_number:2}
...
END_PERIOD                           → INNINGS_COMPLETE → INNINGS_CHANGED {target, runs_required}
START_SUPER_OVER                     → SUPER_OVER_STARTED {round:1}
COMPLETE                             → MATCH_COMPLETED {winner_team_id, result_status}
```
