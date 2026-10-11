# Referee Scoring — Server-Side Tracking Requirements (Backend Change Request)

**Date:** 2026-10-11
**Context:** Cricket T20 scoring via `PUT /api/v1/referee/matches/{matchId}/score`
**Goal:** All match progression (balls, overs, strike, wickets, innings) must be tracked and validated **server-side**. The app should only send user intent (`ADD_EVENT`, `SET_BOWLER`, `END_PERIOD`, `COMPLETE`) and render whatever the backend returns. Nothing should rely on client-side state for correctness.

---

## 1. Verified current behavior (live API, match 4000/3997)

| Scenario | Observed backend behavior |
|---|---|
| `ADD_EVENT` RUN=4 then RUN=1 (odd) | `runtime.current_striker` unchanged — **no strike rotation** |
| `ADD_EVENT` WICKET | Dismissed player **remains** `current_striker`; no replacement flow |
| Any number of legal deliveries | `runtime.current_over`/`current_ball` stay **`0`** — no ball/over tracking |
| `ADD_EVENT` with any `player_id`/`team_id` | Accepted without validating striker/team membership |
| `END_PERIOD` | Works: increments `current_period`, swaps `current_batting_team`/`current_bowling_team`, nulls `runtime` players |
| `score` payload | Only total runs per team: `{"teams": {"2096": {"score": 30}}}` — no wickets/overs |

Conclusion: today the backend is a state *store*; the app has to compute ball count, over completion, strike rotation, wicket replacement, and innings end locally. All of this should move server-side.

---

## 2. Required server-side behaviors

### 2.1 Ball & over tracking
On every `ADD_EVENT` the backend must compute and persist:
- `current_ball` — legal balls bowled in the current over (0–6). **Only RUN and WICKET count as legal balls. WIDE and NO_BALL do not.**
- `current_over` — completed overs count in the current innings.
- On reaching 6 legal balls:
  - `current_over += 1`, `current_ball = 0`
  - `over_complete: true` and **clear `current_bowler`** (require a new `SET_BOWLER` before the next `ADD_EVENT`)
  - `next_action: "SET_BOWLER"`

### 2.2 Strike rotation
On `ADD_EVENT` with `event_code: "RUN"`:
- If `value` is **odd** → swap `current_striker` ↔ `current_non_striker` automatically.
- If `value` is even → no change.
- Wicket does not rotate; WIDE/NO_BALL do not rotate.

### 2.3 Wicket handling
On `ADD_EVENT` with `event_code: "WICKET"`:
- Dismiss `current_striker` (add to `dismissed_player_ids`), increment team wickets.
- Set `current_striker: null`, `awaiting_replacement: true`, `next_action: "SET_BATTERS"`.
- Reject further `ADD_EVENT` (422/409) until the replacement is set via `SET_BATTERS`.
- `SET_BATTERS` after a wicket must accept the **new striker + existing non-striker** (preserve bowler).

### 2.4 Player & event validation on `ADD_EVENT`
Reject with `422` when:
- `event_code` not in configured `available_events`, or `value` not in `allowed_values`.
- `team_id` ≠ current batting team.
- `requires_player` event has no `player_id`, or `player_id` is not the **current striker** (for RUN/WICKET) and not in the batting team.
- No `current_bowler` is set (or `over_complete` is true and `SET_BOWLER` hasn't been called since).
- `awaiting_replacement` is true.

### 2.5 Innings / period progression
- Track per-innings: runs, wickets, overs, balls.
- Expose:
  - `is_all_out` (wickets == max, e.g. 10)
  - `innings_complete` (overs exhausted, all out, or target reached in 2nd innings)
  - `target` / `runs_required` for the chasing innings
- `END_PERIOD` allowed only when the innings is complete (else `409`).
- On `END_PERIOD` (already working): swap batting/bowling teams, reset runtime players to `null`, increment `current_period`.
- When the chasing side passes the target → set `innings_complete` and suspend further `ADD_EVENT` (next step is `END_PERIOD` → `COMPLETE`).
- `COMPLETE` allowed only after all periods are finished; it resolves the winner (current behavior is correct: `409 "Cannot complete match before all periods are finished."`).

### 2.6 Undo
`UNDO_LAST` must roll back the **full runtime snapshot** of the last ball (score, wickets, ball count, striker pair, bowler state, awaiting_replacement), not just remove the event. After an undo, `runtime` must be identical to before that delivery.

---

## 2.7 Required emitted events (event stream)

The backend must emit explicit events for these transitions (in the mutation response and in a recent-events list) so the frontend can render/handle them **without computing anything locally**.

### 2.7.1 Event definitions

| Event type | When emitted | Triggered by | Payload fields |
|---|---|---|---|
| `STRIKE_ROTATED` | after `ADD_EVENT` RUN with **odd** value | server (automatic, no client action) | `striker_user_id`, `non_striker_user_id`, `reason: "ODD_RUN"` |
| `OVER_COMPLETE` | when the **6th legal ball** of the over is recorded (RUN/WICKET) | server (automatic) | `over_number` (completed), `bowler_user_id`, `runs_in_over`, `wickets_in_over`, `next_action: "SET_BOWLER"` |
| `OVER_STARTED` | when `SET_BOWLER` is applied for a new over | client action `SET_BOWLER` | `over_number` (new), `bowler_user_id` |
| `WICKET_RECORDED` | on `ADD_EVENT` WICKET | server (automatic) | `dismissed_user_id`, `team_wickets`, `awaiting_replacement: true`, `next_action: "SET_BATTERS"` |
| `BATTER_REPLACED` | on `SET_BATTERS` while `awaiting_replacement` is true | client action `SET_BATTERS` | `incoming_user_id`, `non_striker_user_id` |
| `INNINGS_CHANGED` | on `END_PERIOD` (innings/period boundary) | client action `END_PERIOD` | `from_inning`, `to_inning`, `batting_team_id`, `bowling_team_id`, `target`, `runs_required` |
| `MATCH_COMPLETED` | on `COMPLETE` | client action `COMPLETE` | `winner_team_id`, `result_status` |
| `EVENT_UNDONE` | on `UNDO_LAST` | client action `UNDO_LAST` | `undone_event_type` |

### 2.7.2 Which events need a client action

- `STRIKE_ROTATED`, `OVER_COMPLETE`, `WICKET_RECORDED` — **no client action**; the server performs them automatically inside `ADD_EVENT`.
- `OVER_STARTED` — client must call `SET_BOWLER` (advertised via `next_action`); the server emits `OVER_STARTED` when it is applied.
- `INNINGS_CHANGED` — client calls `END_PERIOD` (existing action); the server emits `INNINGS_CHANGED` and performs the team swap/reset.
- `MATCH_COMPLETED` / `EVENT_UNDONE` — emitted on the existing `COMPLETE` / `UNDO_LAST` actions.

### 2.7.3 Response shape

```json
"scoring": {
  "enabled": true,
  "method": "BALL_BY_BALL",
  "period_type": "INNINGS",
  "periods_count": 2,
  "current_period": 1,
  "available_events": [ ... ],
  "allowed_actions": [ ... ],
  "next_action": "ADD_EVENT",
  "last_event": {
    "type": "STRIKE_ROTATED",
    "striker_user_id": 12229,
    "non_striker_user_id": 12228,
    "reason": "ODD_RUN"
  },
  "events": [
    { "type": "OVER_COMPLETE", "over_number": 3, "bowler_user_id": 12261, "runs_in_over": 7, "wickets_in_over": 0 },
    { "type": "STRIKE_ROTATED", "striker_user_id": 12229, "non_striker_user_id": 12228, "reason": "ODD_RUN" }
  ],
  "runtime": { ... },
  "score": { ... }
}
```

- `last_event` — always present after a mutation (and after `GET /score`, the most recent recorded event).
- `events` — recent event history (safe to cap at the last N, e.g. 50, with paging if needed later); ordered oldest → newest.
- Event `type` names are fixed strings as listed in 2.7.1 so the frontend can switch on them.

---

## 3. Proposed response additions

### `scoring.runtime`
```json
{
  "state": "LIVE",
  "current_inning": 1,
  "current_over": 3,
  "current_ball": 4,
  "balls_per_over": 6,
  "over_complete": false,
  "awaiting_replacement": false,
  "is_all_out": false,
  "innings_complete": false,
  "current_batting_team_id": 2096,
  "current_bowling_team_id": 2099,
  "current_striker":  { "user_id": 12228, "name": "...", "profile_image_url": null },
  "current_non_striker": { "user_id": 12229, "name": "...", "profile_image_url": null },
  "current_bowler": { "user_id": 12261, "name": "...", "profile_image_url": null },
  "current_wicket_keeper": { "user_id": null, "name": null, "profile_image_url": null },
  "dismissed_player_ids": [12230, 12231],
  "target": 151,
  "runs_required": 45,
  "next_action": "ADD_EVENT"
}
```

### `scoring.score`
```json
{
  "teams": {
    "2096": { "score": 150, "wickets": 6, "overs": "20.0" },
    "2099": { "score": 105, "wickets": 4, "overs": "14.3" }
  }
}
```

### `scoring.allowed_actions` / `next_action` — canonical flow
- Innings running, ball ready → `["ADD_EVENT", "SET_BOWLER", "SET_BATTERS", "SET_WICKET_KEEPER", "END_PERIOD", "UNDO_LAST"]`, `next_action: "ADD_EVENT"`
- Over complete → `["SET_BOWLER", "UNDO_LAST"]`, `next_action: "SET_BOWLER"`
- Wicket → `["SET_BATTERS", "UNDO_LAST"]`, `next_action: "SET_BATTERS"`
- Innings complete → `["END_PERIOD"]`, `next_action: "END_PERIOD"`
- All periods finished → `["COMPLETE"]`, `next_action: "COMPLETE"`

---

## 4. Frontend impact (after the backend change lands)

The app will **remove** all local cricket logic:
- No local odd-run strike swap (server rotates) — no extra `SET_BATTERS` push for rotation.
- No local wait for wicket replacement beyond rendering the `SET_BATTERS` prompt from `awaiting_replacement`.
- Ball/over counters rendered from `current_ball` / `current_over`.
- Buttons rendered strictly from `allowed_actions` / `next_action`.
- Transitions (strike rotated, over complete, new over, innings change, match completed) rendered from `scoring.last_event` / `scoring.events[]` — useful for toasts and the ball-by-ball feed without the app recomputing anything.
- After each mutation the app re-renders from the returned payload (already implemented).

So `SET_BATTERS` remains used **only** for: innings openers, and wicket replacement. Strike rotation and ball/over progression become automatic server-side.

---

## 5. Acceptance tests for backend (T20)

1. `SET_BATTERS(12228,12229)` → `SET_BOWLER(12261)` → response emits `OVER_STARTED` (`over_number: 1`).
2. `RUN=1` by 12228 → `current_striker.user_id == 12229` (auto-swap) **and** `last_event.type == "STRIKE_ROTATED"` with the swapped pair.
3. 5×`RUN=1` → `current_ball == 6`, `current_over == 1`, `current_bowler == null`, `next_action == "SET_BOWLER"`, **and** `last_event.type == "OVER_COMPLETE"` with `over_number: 1`, `runs_in_over`, `bowler_user_id`.
4. `ADD_EVENT` before new `SET_BOWLER` → `422` (bowler required).
5. `WIDE` × 2 → `current_ball` unchanged (no `OVER_COMPLETE` emitted).
6. `WICKET` by 12229 → `current_striker == null`, `awaiting_replacement == true`, `next_action == "SET_BATTERS"`, **and** `last_event.type == "WICKET_RECORDED"`; further `ADD_EVENT` → `422`.
7. `SET_BATTERS(12230,12228)` → `ADD_EVENT` allowed again, wicket count incremented, **and** `last_event.type == "BATTER_REPLACED"` (`incoming_user_id: 12230`).
8. 20 overs completed → `innings_complete == true`, `allowed_actions == ["END_PERIOD"]`.
9. `END_PERIOD` → inning 2, teams swapped, players `null`, `target` set for chaser, **and** `last_event.type == "INNINGS_CHANGED"` with `from_inning/to_inning/batting_team_id/bowling_team_id/target`.
10. Chaser passes target → `innings_complete == true`; `END_PERIOD` → `COMPLETE` allowed; `COMPLETE` → match `COMPLETED` + winner resolved + `last_event.type == "MATCH_COMPLETED"`.
11. `UNDO_LAST` after a single run → score, ball count, and striker pair restored exactly, **and** `last_event.type == "EVENT_UNDONE"` with `undone_event_type`.
12. `GET /score` after any mutation → `last_event` matches the last mutation's event and `events[]` is ordered oldest → newest with the fixed type names from section 2.7.1.
