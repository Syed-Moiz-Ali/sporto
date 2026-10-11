# Referee Score API v2 — Test Findings (backend)

**Date:** 2026-10-11
**Tested on:** live API `https://app.spotoapp.in/api`
**Matches:** `4000` (LIVE, tournament 369), `4001` (fresh)
**Teams:** 2096 (Team 1), 2099 (Team 4) — players 12228–12238 / 12261–12271

---

## 1. What's new in v2 and working ✅

### 1.1 Event stream implemented
`data.scoring.runtime` now includes:

```json
{
  "awaiting_batter": true,
  "awaiting_bowler": true,
  "current_over_deliveries": [],
  "innings_complete": false,
  "dismissed_batters": [],
  "is_super_over": true,
  "super_over_round": 1,
  "events": [
    { "type": "BATTER_REPLACED", "sequence": 1, "occurred_at": "2026-10-11T12:00:42+00:00", "data": { "striker_user_id": 12261, "non_striker_user_id": 12262 } },
    { "type": "OVER_STARTED",    "sequence": 2, "occurred_at": "2026-10-11T12:00:42+00:00", "data": { "bowler_user_id": 12228 } },
    { "type": "SUPER_OVER_STARTED","sequence": 3, "occurred_at": "2026-10-11T12:00:43+00:00", "data": { "round": 1 } }
  ],
  "last_event": { "type": "SUPER_OVER_STARTED", "sequence": 3, "occurred_at": "2026-10-11T12:00:43+00:00", "data": { "round": 1 } }
}
```

Observed event types so far: `BATTER_REPLACED`, `OVER_STARTED`, `SUPER_OVER_STARTED`.

### 1.2 Score payload now per-team detailed
```json
"score": {
  "teams": { "2096": { "score": 0, "wickets": 0, "legal_balls": 0, "overs": "0.0" } },
  "super_over": { "regulation_teams": { "2096": { "score": 30 } } }
}
```

### 1.3 New action
`START_SUPER_OVER` exists and responds `200`.

### 1.4 Validation added
`ADD_EVENT` now validates the striker: `422 "Event player must be the current striker."` ✅

---

## 2. BLOCKER — every `ADD_EVENT` returns HTTP 500

**Endpoint:** `PUT /api/v1/referee/matches/{matchId}/score`

Payloads tested (all → **500**):

```json
{"action":"ADD_EVENT","event_code":"RUN","team_id":2099,"player_id":12261,"value":1}
{"action":"ADD_EVENT","event_code":"RUN","team_id":2099,"player_id":12261,"value":0}
{"action":"ADD_EVENT","event_code":"WICKET","team_id":2099,"player_id":12261}
{"action":"ADD_EVENT","event_code":"WIDE","team_id":2099}
{"action":"ADD_EVENT","event_code":"NO_BALL","team_id":2099}
```

Response (identical for all):

```
HTTP/1.1 500 Internal Server Error
{
    "success": false,
    "message": "Undefined array key \"is_legal_delivery\"",
    "errors": null
}
```

**Repro:**
```bash
curl -X PUT "https://app.spotoapp.in/api/v1/referee/matches/4000/score" \
  -H "Authorization: Bearer {{token}}" -H "Content-Type: application/json" \
  -d '{"action":"ADD_EVENT","event_code":"RUN","team_id":2099,"player_id":12261,"value":1}'
```

**Cause:** the new ball-tracking code reads `is_legal_delivery` from the event configuration, but the configured events don't contain it. `GET /score` → `available_events` (both matches) is:

```json
[
  {"code":"RUN","label":"Run","type":"POINT","value":1,"requires_player":true,"variable_value":true,"allowed_values":[0,1,2,3,4,6]},
  {"code":"WICKET","label":"Wicket","type":"OUT","value":0,"requires_player":true,"variable_value":false},
  {"code":"WIDE","label":"Wide","type":"EXTRA","value":1,"requires_player":false,"variable_value":false},
  {"code":"NO_BALL","label":"No Ball","type":"EXTRA","value":1,"requires_player":false,"variable_value":false}
]
```

No `is_legal_delivery` key anywhere.

**Fix options (either works; default is safest):**
1. Backend default when key is missing (recommended — existing tournaments 354–369 store old config overrides):
   - `RUN` → `is_legal_delivery = true`
   - `WICKET` → `is_legal_delivery = true`
   - `WIDE`, `NO_BALL` → `is_legal_delivery = false`
   i.e. `$event['is_legal_delivery'] ?? in_array($eventCode, ['RUN', 'WICKET'], true)`
2. Add the flag to the sport rule config (`scoring_configuration.events[]` master default **and** handle existing tournament overrides, which won't have the key).

**Impact:** scoring is fully blocked in the app — every run/wide/no-ball/wicket fails with 500.

---

## 3. Other issues found

### 3.1 `END_PERIOD` accepted mid-innings (no gate)
Match 4000, innings 2, **0 balls bowled**, `innings_complete: false` → `END_PERIOD` returned `200` and immediately advertised `COMPLETE`.

```
PUT /score {"action":"END_PERIOD"} → 200
  allowed_actions: ["COMPLETE","UNDO_LAST"], next_action: "COMPLETE"
```

Expected: `409` while `innings_complete == false` (require overs exhausted / all out / target passed).

### 3.2 `START_SUPER_OVER` accepted when NOT tied
At that moment regulation scores were **30–0** (not a tie):

```
PUT /score {"action":"START_SUPER_OVER"} → 200
score.teams: {2096: {score:0, legal_balls:0, overs:"0.0"}},
super_over.regulation_teams: {2096: {score:30}},
runtime.is_super_over: true
```

Expected: `409 "Not tied"` unless both regulation innings are finished with equal scores.

### 3.3 `current_over` / `current_ball` still 0
Cannot be verified until the 500 is fixed, but after `SET_BATTERS` + `SET_BOWLER` both remain `0`. Retest after fix.

### 3.4 Undo also reverts `SET_BOWLER` (confirm intended?)
`UNDO_LAST` after `SET_BOWLER 12229` restored `current_bowler = 12228`. If undo should only revert `ADD_EVENT`/`END_PERIOD`, this needs a rule; if it reverts any last mutation, please document it.

### 3.5 Docs don't cover the new runtime fields/events
`v2/REFEREE_MATCH_SCORE_FRONTEND.md` doesn't document `runtime.events[]`, `runtime.last_event`, `awaiting_batter`, `awaiting_bowler`, `current_over_deliveries`, `innings_complete`, `dismissed_batters`, `is_super_over`, `super_over_round`, the per-team `wickets/legal_balls/overs`, or the event type names/payloads. Please document them (frontend will switch on them).

---

## 4. Retest checklist after the `is_legal_delivery` fix

1. `RUN=1` by striker → 200; `current_ball` increments; striker rotates (odd run); `last_event.type == "STRIKE_ROTATED"` (or equivalent).
2. `WIDE` / `NO_BALL` → 200; `current_ball` unchanged; `last_event.type == "EVENT_RECORDED"` (whatever you name it).
3. 6th legal ball → `OVER_COMPLETE` event, `current_bowler` cleared, `awaiting_bowler: true`, `next_action: "SET_BOWLER"`.
4. `WICKET` → dismissed striker cleared, `awaiting_batter: true`, `dismissed_batters` updated, `next_action: "SET_BATTERS"`.
5. `SET_BATTERS` after wicket → `BATTER_REPLACED` event, `awaiting_batter: false`.
6. `END_PERIOD` while `innings_complete == false` → `409`.
7. `START_SUPER_OVER` when not tied → `409`.
8. `UNDO_LAST` after an event → score/ball/strike restored; check `EVENT_UNDONE` event type.
9. `GET /score` after each mutation → `last_event` + `events[]` consistent.
