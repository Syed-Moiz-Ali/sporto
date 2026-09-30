# Referee Score API — Frontend Integration Guide

## Base Endpoint

```http
GET /api/v1/referee/matches/{matchId}/score
PUT /api/v1/referee/matches/{matchId}/score
```

Example:

```http
GET /api/v1/referee/matches/3957/score
PUT /api/v1/referee/matches/3957/score
```

---

# Authentication

All referee score APIs require authentication.

```http
Authorization: Bearer <referee_token>
Accept: application/json
Content-Type: application/json
```

---

# 1. Get Current Score State

## API

```http
GET /api/v1/referee/matches/{matchId}/score
```

Example:

```http
GET /api/v1/referee/matches/3957/score
```

This API should be used by the frontend as the authoritative source for the current match scoring state.

Important response data includes:

```text
match
tournament
sport
format
teams
schedule
scoring
toss
result
```

Inside `scoring`:

```text
enabled
method
period_type
periods_count
current_period
available_events
allowed_actions
next_action
runtime
score
```

Frontend should use:

```text
scoring.allowed_actions
```

to decide which action buttons should be enabled.

Do not guess allowed actions only from local frontend state.

---

# 2. Update Score API

## API

```http
PUT /api/v1/referee/matches/{matchId}/score
```

Example:

```http
PUT /api/v1/referee/matches/3957/score
```

---

# Supported Score Actions

Backend constants:

```php
START
ADD_EVENT
UNDO_LAST
END_PERIOD
SET_BATTERS
SET_BOWLER
SET_WICKET_KEEPER
COMPLETE
```

Authoritative backend constant class:

```php
App\Constants\RefereeScoreAction
```

---

# 3. START Match

Use this action to start scoring the match.

```json
{
  "action": "START"
}
```

The match must normally be in `PENDING` state.

If toss is enabled, toss must be completed before the match can start.

---

# 4. SET_BATTERS

Use this action to set the current striker and non-striker.

```json
{
  "action": "SET_BATTERS",
  "striker_user_id": 101,
  "non_striker_user_id": 102
}
```

Rules:

- Both players must belong to the current batting team.
- Both players must be active/accepted players.
- Striker and non-striker cannot be the same player.

---

# 5. SET_BOWLER

Use this action to select the current bowler.

```json
{
  "action": "SET_BOWLER",
  "bowler_user_id": 201
}
```

The selected player must belong to the current bowling team.

---

# 6. SET_WICKET_KEEPER

Use this action to select the current wicket keeper.

```json
{
  "action": "SET_WICKET_KEEPER",
  "wicket_keeper_user_id": 202
}
```

The selected player must belong to the current bowling team.

---

# 7. ADD_EVENT

All scoring updates such as runs, wickets, wides, and no-balls use:

```text
action = ADD_EVENT
```

The actual scoring event is sent through:

```text
event_code
```

Current Cricket event codes are:

```text
RUN
WICKET
WIDE
NO_BALL
```

Important:

These event codes are dynamic sport scoring configuration values.

Frontend should use:

```text
scoring.available_events
```

returned by the GET Score API whenever possible.

Do not maintain a separate hardcoded event list unless required for UI presentation.

---

# 8. RUN Event

## 1 Run

```json
{
  "action": "ADD_EVENT",
  "event_code": "RUN",
  "team_id": 10,
  "player_id": 101,
  "value": 1
}
```

## 2 Runs

```json
{
  "action": "ADD_EVENT",
  "event_code": "RUN",
  "team_id": 10,
  "player_id": 101,
  "value": 2
}
```

## 3 Runs

```json
{
  "action": "ADD_EVENT",
  "event_code": "RUN",
  "team_id": 10,
  "player_id": 101,
  "value": 3
}
```

## Four

```json
{
  "action": "ADD_EVENT",
  "event_code": "RUN",
  "team_id": 10,
  "player_id": 101,
  "value": 4
}
```

## Six

```json
{
  "action": "ADD_EVENT",
  "event_code": "RUN",
  "team_id": 10,
  "player_id": 101,
  "value": 6
}
```

Current allowed RUN values:

```text
0
1
2
3
4
6
```

Values are validated against the resolved scoring configuration.

---

# 9. WICKET Event

```json
{
  "action": "ADD_EVENT",
  "event_code": "WICKET",
  "team_id": 10,
  "player_id": 101
}
```

Current event type:

```text
OUT
```

---

# 10. WIDE Event

```json
{
  "action": "ADD_EVENT",
  "event_code": "WIDE",
  "team_id": 10,
  "value": 1
}
```

Current event type:

```text
EXTRA
```

A wide should follow the current backend event configuration for legal-delivery handling.

---

# 11. NO_BALL Event

```json
{
  "action": "ADD_EVENT",
  "event_code": "NO_BALL",
  "team_id": 10,
  "value": 1
}
```

Current event type:

```text
EXTRA
```

---

# Important `player_id` Note

For the current API:

```text
player_id
```

means:

```text
users.id
```

of the active TeamPlayer.

It does **not** mean the `team_players` table row ID.

Example:

```json
{
  "player_id": 101
}
```

means:

```text
user_id = 101
```

Frontend must send the player's `user_id`.

---

# 12. UNDO_LAST

Use this to undo the latest supported scoring/runtime action.

```json
{
  "action": "UNDO_LAST"
}
```

Current undo history supports actions such as:

```text
ADD_EVENT
END_PERIOD
SET_BATTERS
SET_BOWLER
SET_WICKET_KEEPER
```

`START` and `COMPLETE` are not currently treated as normal undoable runtime actions.

---

# 13. END_PERIOD

Use this to end the current period/innings.

```json
{
  "action": "END_PERIOD"
}
```

For Cricket with 2 innings:

```text
Innings 1
↓
END_PERIOD
↓
Innings 2

Innings 2
↓
END_PERIOD
↓
Ready for COMPLETE
```

On Cricket innings transition the backend resets:

```text
current_over = 0
current_ball = 0
current_striker_user_id = null
current_non_striker_user_id = null
current_bowler_user_id = null
current_wicket_keeper_user_id = null
```

Batting and bowling teams are also swapped according to the current scoring state.

---

# 14. COMPLETE Match

Use this only after all periods have been ended.

```json
{
  "action": "COMPLETE"
}
```

For a 2-period/2-innings match:

```text
Period 1
↓
END_PERIOD

Period 2
↓
END_PERIOD

Then
↓
COMPLETE
```

Frontend must not send `COMPLETE` while the final period is still active.

---

# END_PERIOD / COMPLETE Important Rule

For `periods_count = 2`:

```text
current_period = 1
END_PERIOD
↓
current_period = 2

current_period = 2
END_PERIOD
↓
current_period = 3

current_period = 3
COMPLETE
↓
Match Completed
```

Therefore:

```text
current_period <= periods_count
```

means there is still an active period.

```text
current_period > periods_count
```

means all periods have ended and the match can be completed.

---

# 15. Score Event Types

Backend currently supports these event types:

```text
POINT
OUT
EXTRA
PENALTY
```

Current Cricket mapping:

| Event Code | Type |
|---|---|
| `RUN` | `POINT` |
| `WICKET` | `OUT` |
| `WIDE` | `EXTRA` |
| `NO_BALL` | `EXTRA` |

`PENALTY` is supported by the scoring calculator, but Cricket currently does not define a `PENALTY_RUN` event.

---

# Events Not Currently Configured

The following Cricket events are currently **not configured**:

```text
BYE
LEG_BYE
PENALTY_RUN
```

Frontend should not send these event codes unless backend scoring configuration is updated to support them.

---

# 16. Recommended Frontend Flow

```text
GET /score
↓
Read scoring.allowed_actions
↓
START
↓
SET_BATTERS
↓
SET_BOWLER
↓
SET_WICKET_KEEPER
↓
ADD_EVENT
↓
ADD_EVENT
↓
ADD_EVENT
↓
...
↓
END_PERIOD
↓
Refresh GET /score
↓
Set players for next innings/period
↓
ADD_EVENT
↓
...
↓
END_PERIOD
↓
Refresh GET /score
↓
COMPLETE
```

---

# 17. Frontend Button Rules

Frontend should primarily use:

```json
{
  "scoring": {
    "allowed_actions": []
  }
}
```

Example pending match:

```json
{
  "allowed_actions": [
    "START"
  ]
}
```

Example live period:

```json
{
  "allowed_actions": [
    "ADD_EVENT",
    "SET_BATTERS",
    "SET_BOWLER",
    "SET_WICKET_KEEPER",
    "END_PERIOD",
    "UNDO_LAST"
  ]
}
```

After final period has ended:

```json
{
  "allowed_actions": [
    "COMPLETE",
    "UNDO_LAST"
  ]
}
```

Completed match:

```json
{
  "allowed_actions": []
}
```

Frontend should hide or disable actions not returned by the backend.

---

# 18. Full Accepted Request Fields

`PUT /score` currently accepts the following request fields:

```json
{
  "action": "ADD_EVENT",
  "event_code": "RUN",
  "team_id": 10,
  "player_id": 101,
  "value": 4,
  "striker_user_id": 101,
  "non_striker_user_id": 102,
  "bowler_user_id": 201,
  "wicket_keeper_user_id": 202
}
```

This is only a reference showing all accepted fields.

Do **not** send every field for every action.

Use only the fields required by the selected action.

---

# 19. Action Payload Summary

| Action | Required Payload |
|---|---|
| `START` | `action` |
| `ADD_EVENT` | `action`, `event_code`, `team_id`, event-specific fields |
| `SET_BATTERS` | `action`, `striker_user_id`, `non_striker_user_id` |
| `SET_BOWLER` | `action`, `bowler_user_id` |
| `SET_WICKET_KEEPER` | `action`, `wicket_keeper_user_id` |
| `UNDO_LAST` | `action` |
| `END_PERIOD` | `action` |
| `COMPLETE` | `action` |

---

# 20. Important Frontend Rules

1. Always call `GET /score` before rendering the scoring screen.

2. Use `scoring.available_events` for scoring event buttons.

3. Use `scoring.allowed_actions` for action buttons.

4. Do not hardcode `RUN`, `WICKET`, `WIDE`, `NO_BALL` as globally supported events for every sport.

5. Do not send `COMPLETE` before the final `END_PERIOD`.

6. Do not send duplicate `END_PERIOD` requests.

7. Disable the button immediately while a score update request is in progress to avoid duplicate API calls.

8. After every successful scoring action, update frontend state using the API response or refresh `GET /score`.

9. `player_id` currently represents `user_id`.

10. Backend scoring configuration is the source of truth.