# Referee Toss & Scoring API — Backend Bug Report

**Date:** 2026-10-11
**Tester:** Frontend (referee app integration) — live API testing
**Base URL:** `https://app.spotoapp.in/api`
**Auth:** `POST /api/v1/referee/verify-otp` with mobile `8977904104` / OTP `1234` → `Authorization: Bearer {{token}}`

---

## Test Setup (live data used)

| Item               | Value                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------- |
| Tournament         | `368` — "QA Toss Score 11 Oct 1205" (Cricket / T20 / Knockout, approved)              |
| Match tested       | `3997` (Semi-Final, Team `2091` "Demo T368 Team 1" vs Team `2094` "Demo T368 Team 4") |
| Other matches      | `3998`, `3999` (published schedule version `67`)                                      |
| Referee account    | user id `5` (referee profile `2`)                                                     |
| Referee assignment | assignment id `2399`, role `Main Referee`, status `1`                                 |
| Players team 2091  | user ids `12157`–`12167`                                                              |
| Players team 2094  | user ids `12190`–`12200`                                                              |
| Venue              | `493` — QA Ground                                                                     |

---

## What already works (for comparison)

```
GET  /api/v1/referee/matches/3997/toss    → 200 (returns teams + members roster)
PUT  /api/v1/referee/matches/3997/toss    {"action":"CALL","called_side":"HEADS","calling_team_id":2091}   → 200 → state TOSS_CALLING
PUT  /api/v1/referee/matches/3997/toss    {"action":"FLIP"}                                                → 200 → state DECISION_PENDING, winner_team_id 2091
PUT  /api/v1/referee/matches/3997/toss    {"action":"SET_DECISION","decision":"BAT_FIRST"}                → 200 → state TOSS_COMPLETED
GET  /api/v1/referee/matches/3997/score   → 200 (state readable)
GET  /api/v1/referee/matches/3997         → 200 (assignment visible, can_officiate: true)
```

---

## Issue #1 — BLOCKER: Every score mutation returns HTTP 500

**Endpoint:** `PUT /api/v1/referee/matches/3997/score`
**Headers:** `Authorization: Bearer {{token}}`, `Accept: application/json`, `Content-Type: application/json`

Every action below returns the **same** response:

```
HTTP/1.1 500 Internal Server Error

{
    "success": false,
    "message": "Call to undefined relationship [venue] on model [App\\Models\\TournamentVenue].",
    "errors": null
}
```

Payloads tested (all → HTTP 500, identical response):

```json
{"action":"START"}
{"action":"SET_BATTERS","striker_user_id":12157,"non_striker_user_id":12158}
{"action":"SET_BOWLER","bowler_user_id":12190}
{"action":"ADD_EVENT","event_code":"RUN","team_id":2091,"player_id":12157,"value":4}
{"action":"ADD_EVENT","event_code":"RUN","team_id":2091,"player_id":12158,"value":1}
{"action":"ADD_EVENT","event_code":"WIDE","team_id":2091}
{"action":"ADD_EVENT","event_code":"NO_BALL","team_id":2091}
{"action":"ADD_EVENT","event_code":"WICKET","team_id":2091,"player_id":12157}
{"action":"UNDO_LAST"}
{"action":"END_PERIOD"}
{"action":"COMPLETE"}
```

**Impact:** Scoring is 100% blocked. `GET /score` still reports `scoring.allowed_actions: ["START"]`, so the client cannot progress at all.

**Suspected cause:** The score-update path eager-loads a `venue` relationship on `App\Models\TournamentVenue` (e.g. `->with('venue')` / `->load('venue')`), but `TournamentVenue` stores `venue_name` inline and apparently has no `venue()` relation defined. The GET /score path maps the venue manually (it returns `schedule.venue` fine), so only the write path crashes.

**Expected:** `PUT /score` should accept the actions and return 200 (e.g. `{"success":true,"message":"Score updated successfully.","data":{...state...}}`) without touching the `venue` relation.

**Repro (curl):**

```bash
curl -X PUT "https://app.spotoapp.in/api/v1/referee/matches/3997/score" \
  -H "Authorization: Bearer {{token}}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"action":"START"}'
```

---

## Issue #2 — `SET_STARTING_PLAYERS` now always fails with 409 after `SET_DECISION`

**Endpoint:** `PUT /api/v1/referee/matches/3997/toss`

**Payload:**

```json
{
  "action": "SET_STARTING_PLAYERS",
  "striker_user_id": 12157,
  "non_striker_user_id": 12158,
  "opening_bowler_user_id": 12190
}
```

**Response:**

```
HTTP/1.1 409 Conflict

{
    "success": false,
    "message": "Match toss has already been completed.",
    "errors": null,
    "data": { "...full toss state...": "", "toss": { "state": "TOSS_COMPLETED", "completed_at": "2026-10-11T06:41:02+00:00", "starting_setup": null } }
}
```

**Behavior change observed:** `SET_DECISION` now immediately moves the toss to `TOSS_COMPLETED`:

```
GET /toss after SET_DECISION:
  toss.state           = "TOSS_COMPLETED"
  toss.next_action     = null
  toss.allowed_actions = []
  toss.starting_setup  = null
  toss.runtime         = { ..., "is_completed": true, "next_action": null, "allowed_actions": [] }
```

The frontend "Set Players" step (striker / non-striker / opening bowler) is only reachable after the decision, and its confirm button sends `SET_STARTING_PLAYERS` — which can now never succeed. The roster IS returned by `GET /toss` (`teams[].members[]`, 11 players per team), so the UI can display/select players, but the save always 409s.

**Question for backend / expected contract:** either

1. keep the toss open for `SET_STARTING_PLAYERS` after `SET_DECISION` (state e.g. `DECISION_DONE`/`STARTING_PLAYERS_PENDING`), or
2. confirm the step is removed from the contract and openers should be set via `PUT /score {"action":"SET_BATTERS"/"SET_BOWLER"}` instead (which is currently blocked by Issue #1), or
3. auto-derive openers server-side and drop the client step.

Note: rule field `toss_configuration` returns `"starting_roles": []`, which suggests the backend no longer models this step — but the action still exists and returns 409 rather than a clear "unsupported action" validation error.

---

## Issue #3 — `GET /v1/referee/matches` does not list an assigned match

```
GET /api/v1/referee/matches?page=1&per_page=50 → 200

{
    "success": true,
    "message": "Assigned matches retrieved successfully.",
    "data": {
        "items": [],
        "current_page": 1,
        "last_page": 1,
        "total": 0
    }
}
```

At the same time, the assignment exists and is fully readable:

```
GET /api/v1/referee/matches/3997 → 200

{
  "data": {
    "id": 3997,
    "status": 1,
    "can_officiate": true,
    "tournament": { "id": 368, "name": "QA Toss Score 11 Oct 1205", "status": 2 },
    "round": { "id": 443, "name": "Semi-Final" },
    "participants": { "team_a": {"id":2091,...}, "team_b": {"id":2094,...} },
    "assignment": { "id": 2399, "status": 1, "role": "Main Referee", "assigned_at": "2026-10-11T06:41:01+00:00" },
    "toss": { "enabled": true, "state": "TOSS_PENDING", "next_action": "CALL", ... }
  }
}
```

**Impact:** The referee app home list stays empty, so the referee can't navigate to the match from the list.

**Expected:** match `3997` (assignment `2399`, status 1) should appear in the assigned matches list. (Assignment was created via `POST /api/v1/partner/tournaments/368/matches/3997/referees {"referee_id":5,"role":"Main Referee"}` → 201.)

---

## Issue #4 — Minor: GET /score returns wrong message

```
GET /api/v1/referee/matches/3997/score → 200

{
    "success": true,
    "message": "Score updated successfully.",
    ...
}
```

A GET returns "Score updated successfully." — should be "Score retrieved successfully." (cosmetic, but the frontend maps messages to toasts).

---

## Issue #5 — Minor: stale/inconsistent toss runtime inside `GET /score`

`GET /toss` (correct after completion) vs `GET /score` (stale) for the same match, same moment:

```
GET /toss:
  toss.state           = "TOSS_COMPLETED"
  toss.next_action     = null
  toss.allowed_actions = []
  runtime: { "is_completed": true, "next_action": null, "allowed_actions": [] }

GET /score data.toss:
  toss.state           = "TOSS_COMPLETED"       (top-level is fine)
  toss.starting_setup  = {}                     (empty object vs null)
  runtime: {
    "state": "TOSS_COMPLETED",
    "is_completed": false,                      ← WRONG
    "next_action": "SET_DECISION",              ← WRONG / stale
    "allowed_actions": ["SET_DECISION"],        ← WRONG / stale
    "can_update": true
  }
```

If the app resumes from `GET /score`, it will think the toss still needs `SET_DECISION` and will re-try it (or show the wrong step). Expected: same runtime values as `GET /toss`.

---

## Frontend Integration Guide mismatches (for confirmation)

1. Guide says drive buttons from `scoring.allowed_actions` — provided by backend, but no action can execute (Issue #1).
2. Guide states toss actions include `SET_STARTING_PLAYERS` — no longer reachable (Issue #2).
3. Guide/code expects `GET /toss` to keep the toss open until starting players are set — backend now completes at `SET_DECISION`.

---

## Retest checklist for backend after fix

1. `PUT /score {"action":"START"}` → 200, state becomes live (`allowed_actions` moves to `SET_BATTERS`/`SET_BOWLER`).
2. `PUT /score SET_BATTERS` + `SET_BOWLER` → 200.
3. `ADD_EVENT` RUN/WIDE/NO_BALL/WICKET → 200 and score updates in `GET /score`.
4. `UNDO_LAST`, `END_PERIOD`, `COMPLETE` accepted in the right states and rejected with 4xx (not 5xx) in wrong states.
5. Toss: decide once more on match `3998` and confirm the intended sequence for starting players (fix per decision above).
6. `GET /v1/referee/matches` lists match `3997` for user 5.
7. `GET /score` returns read message + non-stale `toss.runtime`.
