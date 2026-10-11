# Referee Scoring Events — v2 Live Test Results

**Date:** 2026-10-11
**Match:** `4001` (tournament 369) — full flow: toss → start → innings 1 (all out) → innings change → chase → complete
**Result:** ✅ Core event system works end-to-end. A few minor issues below.

---

## 1. Verified working ✅

### Ball tracking & rules
| Test | Result |
|---|---|
| `RUN=1` (odd) | 200 — `current_ball: 1`, **auto strike rotation** + `STRIKE_ROTATED {reason: ODD_RUN}` |
| `RUN=0` | 200 — `current_ball: 2` |
| `WIDE` | 200 — ball unchanged, `score +1`, `extras.wide +1`, `legal_delivery: false` |
| `NO_BALL` | 200 — ball unchanged, `score +1`, `extras.no_ball +1` |
| `RUN=4` | 200 — `current_ball: 3` |
| 6th legal ball | `OVER_COMPLETE {over: 1}`, `current_over: 1`, `current_ball: 0`, bowler cleared, `awaiting_bowler: true`, `allowed: [SET_BOWLER, UNDO_LAST]` |
| `STRIKE_ROTATED` at over end | ✅ `reason: OVER_END` |
| `ADD_EVENT` without bowler | 409 `"Select a bowler before recording a delivery."` |

### Wicket flow
| Test | Result |
|---|---|
| `WICKET` (+`wicket_type: BOWLED`) | 200 — `wickets +1`, `awaiting_batter: true`, `current_striker: null`, `WICKET_RECORDED {dismissed_user_id, wicket_type, requires_replacement: true}`, allowed → `[SET_BATTERS, UNDO_LAST]` |
| `ADD_EVENT` while awaiting batter | 409 `"A replacement batter is required before the next delivery."` |
| `SET_BATTERS` replacement | 200 — `BATTER_REPLACED`, ball count preserved, non-striker preserved |

### Innings & completion
| Test | Result |
|---|---|
| All out (wickets 10) | `INNINGS_COMPLETE {reason: ALL_OUT}`, `innings_complete: true`, allowed → `[END_PERIOD, UNDO_LAST]` |
| `END_PERIOD` mid-innings | 409 `"Cannot end period before innings is complete."` ✅ |
| `END_PERIOD` after innings | 200 — `INNINGS_CHANGED {new_inning: 2, target: 8}` + `INNINGS_STARTED {inning: 2}`, teams swapped, runtime reset |
| Chase target reached | `RUN=6` + `RUN=2` (target 8) → `INNINGS_COMPLETE {reason: TARGET_REACHED}`, allowed → `[COMPLETE]` |
| `START_SUPER_OVER` not tied | 409 `"Super Over can only be started if the scores are tied."` ✅ |
| `COMPLETE` | 200 — `match.status: 3`, `winner_team_id: 2097`, `result: WIN` ✅ |

### Events emitted (verified in `runtime.events[]` + `last_event`)
`MATCH_STARTED`, `INNINGS_STARTED`, `BATTER_REPLACED`, `BOWLER_CHANGED`, `OVER_STARTED`, `STRIKE_ROTATED`, `BALL_RECORDED`, `WICKET_RECORDED`, `OVER_COMPLETE`, `INNINGS_COMPLETE`, `INNINGS_CHANGED` ✅

`BALL_RECORDED` payload is rich: `event_code, value, display, legal, legal_delivery, delivery_runs, runs_total, wickets, striker_user_id, non_striker_user_id, bowler_user_id, over_number, ball_in_over`.

---

## 2. Issues found (minor / polish)

### 2.1 `MATCH_COMPLETED` event is NOT emitted on `COMPLETE` ❌
After `PUT {"action":"COMPLETE"}` (200, match completed, winner resolved), `last_event` still showed `INNINGS_COMPLETE` and no `MATCH_COMPLETED` event appears in `events[]`. Expected: `MATCH_COMPLETED {winner_team_id, result_status: "WIN"}` as the newest event.

### 2.2 6th-ball `BALL_RECORDED` is stamped after over rollover
For the last ball of an over the event arrives **after** `STRIKE_ROTATED (OVER_END)` and shows the *next* over:
```
event 8:  STRIKE_ROTATED {reason: OVER_END}
event 9:  BALL_RECORDED  {over_number: 1, ball_in_over: 0, bowler_user_id: null, ...}   ← the 6th ball
event 10: OVER_COMPLETE {over: 1}
```
Expected order: `BALL_RECORDED {over_number: 0, ball_in_over: 6, bowler_user_id: 12239}` → `STRIKE_ROTATED {OVER_END}` → `OVER_COMPLETE`. Same applies to a wicket on the 6th ball (event 29 in the log: `over_number: 2, ball_in_over: 0, bowler_user_id: null`). This breaks ball-by-ball feed rendering for that delivery.

### 2.3 Wrong 409 message after innings complete
After `INNINGS_COMPLETE (ALL_OUT)`, an `ADD_EVENT` returned:
`409 "A replacement batter is required before the next delivery."`
Should say something like `"Innings is complete. Use END_PERIOD."`

### 2.4 `next_action` shows `SET_BATTERS` during an active over
After `SET_BOWLER`, `next_action: "SET_BATTERS"` even though batters are set and `ADD_EVENT` is accepted. Expected `"ADD_EVENT"` (or `null`).

### 2.5 `UNDO_LAST` also reverts `SET_BOWLER`
`UNDO_LAST` after `SET_BOWLER` reverted the bowler (back to `awaiting_bowler: true`, `OVER_STARTED` removed). Their doc says "Reverts the last ADD_EVENT or END_PERIOD". Confirm intended semantics.

### 2.6 `events[]` window
The list is capped at the most recent **50** events (final match had exactly 50; the earliest `MATCH_STARTED`/first-ball events were trimmed). Fine if documented; otherwise expose paging or raise the cap.

---

## 3. Retest request (small)

1. Emit `MATCH_COMPLETED` (with winner + result) on `COMPLETE`; make it the `last_event`.
2. Stamp the final ball of an over correctly (`over_number` before increment, `ball_in_over: 6`, bowler id set) and emit it **before** `STRIKE_ROTATED (OVER_END)` / `OVER_COMPLETE`.
3. Fix the post-innings 409 message.
4. `next_action: "ADD_EVENT"` while the over is live.
5. Confirm UNDO semantics + document the `events[]` cap.

Everything else is verified and ready for the app to consume 🎉
