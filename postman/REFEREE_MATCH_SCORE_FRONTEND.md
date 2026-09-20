# Referee Match Score Frontend Integration Contract

This document provides the definitive contract for integrating the Referee Match Score screens. 
It defines the exact API routes, response structures, state transitions, and error handling behaviors as implemented and verified in the backend.

## 1. API Routes
All referee match actions are grouped under the following base route:
`GET /api/v1/referee/matches`

| Action | HTTP Method | Endpoint |
|---|---|---|
| List Matches | GET | `/api/v1/referee/matches` |
| Match Details | GET | `/api/v1/referee/matches/{matchId}` |
| Get Toss | GET | `/api/v1/referee/matches/{matchId}/toss` |
| Update Toss | PUT | `/api/v1/referee/matches/{matchId}/toss` |
| Get Score | GET | `/api/v1/referee/matches/{matchId}/score` |
| Update Score | PUT | `/api/v1/referee/matches/{matchId}/score` |

**Authentication**: All requests require a standard Bearer Token of a User who is assigned as the `ACCEPTED` referee for the match.

## 2. Match Lifecycle & State Machine

| Match State | Toss State | Available Actions | Frontend Screen |
|---|---|---|---|
| `PENDING` | `TOSS_PENDING` (or Calling/Decision/Setup) | `START` blocked | Toss |
| `PENDING` | `TOSS_COMPLETED` (or toss disabled) | `START` | Start Match |
| `LIVE` | — | `ADD_EVENT`, `UNDO_LAST`, `END_PERIOD`, `COMPLETE` | Live Score |
| `COMPLETED` | — | none (Read Only) | Final Result |
| `CANCELLED` | — | none (Read Only) | Read Only |

## 3. GET Score Contract
**Endpoint**: `GET /api/v1/referee/matches/{matchId}/score`

This endpoint returns the entire state necessary to build the live scoring screen. If the app is closed and reopened, this response is authoritative.

### Required Frontend Response Fields

| Path | Type | Required | Usage |
|---|---|---|---|
| `data.match.id` | Integer | Yes | Unique Match ID |
| `data.match.status` | String | Yes | Drives the screen state (`PENDING`, `LIVE`, `COMPLETED`, `CANCELLED`) |
| `data.match.match_number` | Integer | Yes | Display match sequential number |
| `data.match.winner_team_id` | Integer / Null | Yes | Winner if decided, otherwise null |
| `data.tournament.id` | Integer | Yes | Context |
| `data.sport.name` | String | Yes | Display purposes only |
| `data.format.name` | String | Yes | Display purposes only |
| `data.teams[]` | Array | Yes | Lists exactly 2 teams playing |
| `data.teams[].id` | Integer | Yes | `team_id` used in payloads |
| `data.teams[].team_name` | String | Yes | Display team name |
| `data.teams[].players[].user_id` | Integer | Yes | The authoritative `player_id` to use in requests |
| `data.scoring.enabled` | Boolean | Yes | If false, scoring UI is disabled |
| `data.scoring.method` | String | Yes | E.g. `BALL_BY_BALL`, `EVENT_BASED` |
| `data.scoring.period_type` | String | Yes | E.g. `INNINGS`, `HALVES`, `QUARTERS`, `SETS`, `NONE` |
| `data.scoring.periods_count` | Integer | Yes | Total number of periods before complete |
| `data.scoring.current_period` | Integer | Yes | Current active period |
| `data.scoring.available_events[]`| Array | Yes | Renders the event buttons |
| `data.scoring.runtime` | Object | Yes | Internal runtime state (e.g. `current_inning`) |
| `data.scoring.score` | Object | Yes | Authoritative match score (contains `teams` keys) |
| `data.toss` | Object | Yes | Current toss configuration and state |
| `data.result.status` | String | Yes | E.g. `WIN`, `DRAW`, `TIE`, `UNRESOLVED` |

## 4. Scoring Configuration & Available Events
The backend dictates the exact buttons and input fields to render based on `data.scoring.available_events`.

| Field | Type | Description |
|---|---|---|
| `code` | String | Payload identifier (e.g., `RUN`, `WICKET`, `POINT`, `WIDE`). |
| `label` | String | Human readable label for the button. |
| `type` | String | `POINT`, `OUT`, `EXTRA`, `PENALTY`. Used by backend, frontend can use for generic color coding. |
| `requires_player` | Boolean | If true, the frontend MUST open a player selector before firing the event. |
| `variable_value`| Boolean | If true, the event has multiple possible values (e.g. runs 1, 2, 3, 4, 6). |
| `allowed_values`| Array of Int | If `variable_value` is true, this dictates the allowed choices. |

### Event Types
**Fixed Event** (e.g. `WIDE` in Cricket, `WICKET` in Cricket)
- `variable_value` = false
- Frontend sends: `event_code`, `team_id`, (and `player_id` if `requires_player` is true)
- Frontend does NOT send a `value`.

**Variable Event** (e.g. `RUN` in Cricket)
- `variable_value` = true
- Frontend sends: `event_code`, `team_id`, `value`, (and `player_id` if `requires_player` is true).
- Backend strictly validates `value` against `allowed_values`.

## 5. Player and Team Selection
- **Team ID**: Always `data.teams[].id`.
- **Player ID**: The backend expects `player_id` in the payload, but the value sent MUST be the `user_id` from `data.teams[].players[].user_id`. Do NOT invent another player ID.
- Frontend must select players strictly from the roster provided in the `GET Score` response.

## 6. Action Contracts (PUT Score)
**Endpoint**: `PUT /api/v1/referee/matches/{matchId}/score`

| Action | Endpoint | Required Fields | Optional Fields | Success Status | Failure Status |
|--------|----------|-----------------|-----------------|----------------|----------------|
| `START` | `PUT /score` | `action` | | 200 OK | 409 (Toss incomplete / Already Started) |
| `ADD_EVENT`| `PUT /score` | `action`, `event_code`, `team_id` | `player_id`, `value` (if configured) | 200 OK | 422 (Invalid payload) / 409 (Not Live) |
| `UNDO_LAST`| `PUT /score` | `action` | | 200 OK | 409 (No history) |
| `END_PERIOD`|`PUT /score` | `action` | | 200 OK | 409 (Final period ended) |
| `COMPLETE` | `PUT /score` | `action` | | 200 OK | 409 (Periods not finished) |

### Example Payloads
**Start Match**
```json
{ "action": "START" }
```
**Add Fixed Event (e.g. WIDE)**
```json
{ "action": "ADD_EVENT", "event_code": "WIDE", "team_id": 2023 }
```
**Add Variable Event with Player (e.g. 4 RUNS by player)**
```json
{ "action": "ADD_EVENT", "event_code": "RUN", "team_id": 2023, "player_id": 501, "value": 4 }
```
**Undo**
```json
{ "action": "UNDO_LAST" }
```
**End Period**
```json
{ "action": "END_PERIOD" }
```
**Complete Match**
```json
{ "action": "COMPLETE" }
```

## 7. Result & Completion
When `action: COMPLETE` is sent:
- The backend evaluates `periods_count` and current scores.
- Determines the winner or if it's a draw/tie based on Sport Rules.
- Transitions match status to `COMPLETED`.
- Subsequent `PUT` mutations will fail with `409 Conflict`.
- `GET Score` will indefinitely return the final immutable state.

## 8. Errors & Concurrency
- Score mutations utilize `DB::transaction()` and pessimistic locking (`lockForUpdate()`).
- The frontend should NOT blindly retry mutations on failure without verifying state.
- **422 Unprocessable Entity**: Validation failed (e.g., missing player, invalid value).
- **409 Conflict**: Invalid state transition (e.g., ending a period when already finished, starting without toss, modifying completed match).
- **404 Not Found / 403 Forbidden**: Referee is not assigned or match doesn't exist.

## 9. Live Match Resume
If the referee closes the app while the match is `LIVE`:
1. Call `GET /api/v1/referee/matches/{matchId}/score`.
2. Inspect `data.match.status` === 'LIVE'.
3. Re-render the exact score using `data.scoring.score`, current period from `data.scoring.current_period`, and buttons from `data.scoring.available_events`.
4. The frontend MUST NOT calculate state locally from scratch; the backend is always authoritative.
