# Referee New UI - Backend Gaps Report

Date: 2026-10-27
Base URL: `https://app.spotoapp.in/api`
Scope: Referee app Home, Schedule/Matches, Scoring, Before Toss / Start Match

Test accounts used (read-only GETs only, no mutations):

| Role | Mobile | OTP | User ID | Notes |
|---|---|---|---|---|
| Referee | `9133339988` | `1234` | `12419` (SUJITH Reddy) | 36 assigned matches |
| Referee | `8977904104` | `1234` | `12447` (Test Partner) | 0 assigned matches |
| Partner | `8977904104` | `1234` | - | used for read-only comparison |

Test data:

| Match | Tournament | State | Used for |
|---|---|---|---|
| `4065` | `395` Sporto Referee Cup Final 2026 | status `1`, toss `TOSS_PENDING` | Before toss / upcoming cards |
| `4056` | `387` Bro Super Over Tie TEST 2 | status `3`, completed after super over | Final result / scorecard |
| `4050` | `383` Pro Cricket League | status `3`, completed | Completed card data check |
| `4061` | `393` Sporto QA T20 Cup 2026 | status `1`, `TOSS_BLOCKED` | Blocked card check |

---

## 1. Executive Summary

The core match, toss, scoring, and scorecard data is now largely available. The new UI is mainly blocked by four missing backend areas:

1. Match Start/End OTP and session APIs do not exist.
2. Referee dashboard/wallet/earnings/online-status APIs do not exist.
3. User/partner booking request data (source, customer, fee, distance, booking status) does not exist.
4. Match list and score responses lack summary/display fields needed by the new cards and headers.

Additionally, `GET /v1/referee/matches/{id}/scorecard` exists on the backend and works, but it is not documented in Postman and is not integrated in the Flutter app.

---

## 2. Endpoint Status Matrix

| Endpoint | Status | Notes |
|---|---|---|
| `GET /v1/referee/profile` | Works | No rating, wallet, or online status |
| `GET /v1/referee/matches` | Works | No scores, no booking fields, no match code |
| `GET /v1/referee/match-requests` | Works but empty | Items are match-assignment shaped, not bookings |
| `GET /v1/referee/matches/{id}` | Works | No booking/fee/session fields |
| `GET /v1/referee/matches/{id}/toss` | Works | `starting_roles` is empty |
| `GET /v1/referee/matches/{id}/score` | Works | Missing `overs_per_innings` and display metadata |
| `GET /v1/referee/matches/{id}/scorecard` | Works | Exists but unused; missing player of the match/result text |
| `GET /v1/referee/dashboard` | 404 | Needed for Home |
| `GET /v1/referee/wallet` | 404 | Needed for Home |
| `GET /v1/referee/earnings` | 404 | Needed for Home |
| `GET /v1/referee/bookings` | 404 | Needed for user bookings |
| `GET /v1/referee/booking-requests` | 404 | Needed for Incoming Requests |
| `GET /v1/referee/matches/{id}/session` | 404 | Needed for Start/End Match |
| `GET /v1/referee/matches/{id}/session/otp` | 404 | Needed for Start/End Match |
| `GET /v1/referee/matches/{id}/start-otp` | 404 | Needed for Start/End Match |
| `GET /v1/referee/matches/{id}/end-otp` | 404 | Needed for End Match |
| `GET /v1/referee/matches/{id}/verify` | 404 | Needed for Verify Teams |
| `GET /v1/referee/availability/status` | 404 | Needed for Online/Offline |
| `GET /v1/referee/status` | 404 | Needed for Online/Offline |
| `GET /v1/referee/matches/{id}/result` | 404 | No result detail endpoint |
| `GET /v1/referee/matches/{id}/result-summary` | 404 | No result margin/message endpoint |

---

## 3. Existing APIs - Missing Fields

### 3.1 `GET /v1/referee/profile`

Currently returns:

- `profile`: `id`, `application_number`, `status`, `name`, `email`, `mobile_number`, `address`
- `sports[]`: `id`, `name`
- `experience`: `experience_years`, `highest_qualification`
- `availability`: `availability[]` (weekdays), `preferred_city`, `travel_radius`
- `application`: `status`, `submitted_at`

Missing for Home:

| Field | Used by |
|---|---|
| `is_available` / `accepting_matches` | Referee Status ON/OFF toggle |
| `status_label` / `status_message` | "Ready for your next match" / "Not taking new matches" |
| `rating` | Header badge `500` |
| `wallet_balance` | Wallet card |
| `total_earned` | Wallet card |
| `pending_earnings` | Wallet card |
| `profile_photo_url` | Header avatar |

Suggested addition:

```json
{
  "profile": {
    "id": 12419,
    "name": "SUJITH Reddy",
    "profile_photo_url": null,
    "rating": 4.8,
    "is_available": true,
    "status_label": "Ready for your next match",
    "status_message": "New referee requests can reach you."
  },
  "wallet": {
    "balance": 3650,
    "total_earned": 5150,
    "pending": 0,
    "currency": "INR"
  }
}
```

---

### 3.2 `GET /v1/referee/matches`

Currently each item has:

- `id`, `match_number`, `status`
- `can_officiate`, `blocking_code`, `blocking_reason`
- `tournament`: `id`, `name`, `code`, `status`
- `stage`: `id`, `name`
- `round`: `id`, `name`
- `group`
- `participants.team_a` / `team_b`: `id`, `name`, `logo_url`
- `schedule`: `date`, `start_time`, `end_time`, `venue { id, name, location }` (nullable)
- `assignment`: `id`, `status`, `role`, `assigned_at`
- `result`: `winner_team_id`, `is_walkover`
- `participants_state`: `ready`, counts, slots
- `toss`: `enabled`, `state`, `is_started`, `is_result_decided`, `is_completed`, `winner_team_id`, `decision`, `next_action`, `completed_at`

Missing for Home and Schedule cards:

| Field | Used by | Why |
|---|---|---|
| `match_code` | `SP-10245` | `match_number` is `1`, tournament `code` is not per-match |
| `booking_source` / `booked_by_type` | `by User` / `by Partner` | Not present anywhere |
| `customer_name` / `booked_by_name` | Request card name | Not present |
| `fee` / `expected_earnings` / `referee_fee` | Request/earnings cards | Not present |
| `distance_km` | Request card | No lat/long or distance |
| `duration_minutes` | Request card | Only derivable if `schedule` exists |
| `booking_status` | "Request Received" | Not present |
| `team_a_score` / `team_b_score` / `team_a_wickets` / `team_b_wickets` / `overs` | Schedule cards | Team objects only have `id/name/logo_url` |
| `current_batter` / `current_bowler` | Live/Upcoming cards | Only available via `/score` |
| `winner_team_name` | Completed card | Only `winner_team_id` present |
| `result_message` / `result_margin` | "won by 18 runs" | Not present |
| `delay_reason` / `weather` | "Delayed - Heavy Rain" | Not present |
| `resume_at` / `resume_time` | "Resume Time 4:00 PM" | Not present |
| `teams_verified` / `ground_ready` | Checklist | `participants_state.ready` is not the same |
| `verified_at` | Checklist | Not present |
| `status_label` | Live/Upcoming/Completed badges | Only numeric `status` |

Current item shape (verified live):

```json
{
  "id": 4065,
  "match_number": 1,
  "status": 1,
  "can_officiate": true,
  "blocking_code": null,
  "blocking_reason": null,
  "tournament": { "id": 395, "name": "Sporto Referee Cup Final 2026", "code": "DZDNEWOMAM", "status": 2 },
  "stage": { "id": 366, "name": "Knockout Stage" },
  "round": { "id": 508, "name": "Semi-Final" },
  "participants": {
    "team_a": { "id": 2170, "name": "Demo T395 Team 1", "logo_url": null },
    "team_b": { "id": 2173, "name": "Demo T395 Team 4", "logo_url": null }
  },
  "schedule": {
    "date": "2026-11-06",
    "start_time": "14:30",
    "end_time": "16:00",
    "venue": { "id": 531, "name": "Sporto Referee Ground 2", "location": "Kukatpally, Hyderabad" }
  },
  "assignment": { "id": 2464, "status": 2, "role": "Main Referee", "assigned_at": "2026-10-27T06:39:08+00:00" },
  "result": null,
  "toss": { "enabled": true, "state": "TOSS_PENDING", "next_action": "CALL" }
}
```

Requested addition (suggested):

```json
{
  "id": 4065,
  "match_code": "SP-10245",
  "booking_source": "partner",
  "customer_name": "Rahul Kumar",
  "fee": 1500,
  "currency": "INR",
  "distance_km": 8.4,
  "duration_minutes": 90,
  "status_label": "Upcoming",
  "score": {
    "team_a": { "runs": 90, "wickets": 2, "overs": "10.0" },
    "team_b": { "runs": 85, "wickets": 3, "overs": "10.0" }
  },
  "current_batter": "Rahul",
  "current_bowler": "Amit",
  "winner_team_name": "Hyd Highlanders",
  "result_message": "Hyd Highlanders won by 18 runs",
  "delay_reason": null,
  "resume_at": null,
  "teams_verified": true,
  "ground_ready": true
}
```

---

### 3.3 `GET /v1/referee/match-requests`

Live result for both test referees:

```json
{
  "success": true,
  "message": "Match requests retrieved successfully.",
  "data": { "items": [], "current_page": 1, "last_page": 1, "total": 0 }
}
```

All 36 assignments for `9133339988` have `assignment.status = 2` (accepted), so no pending request exists to test this endpoint.

The Flutter request cards expect these raw keys which are not present in the match/assignment shape:

- `booking_source`, `booked_by_type`, `source`
- `booked_by`, `customer_name`, `user_name`, `booked_by_name`
- `fee`, `expected_earnings`, `amount`, `price`, `payment_amount`
- `distance_km` / `distance`
- `duration_hours` / `duration`
- `booking_status`

Recommendation: either add these to match-request items or create a dedicated booking-request API.

---

### 3.4 `GET /v1/referee/matches/{id}`

Verified for match `4065`:

- Has `tournament`, `stage`, `round`, `participants`, `schedule`, `assignment`, `participants_state`, `toss`
- `result` is `null` for upcoming

Missing:

- `match_code`
- `booking_source` / `customer_name` / `fee` / `distance_km` / `duration_minutes`
- session/OTP data
- verification/checklist data
- `started_at` / `session_started_at`

---

### 3.5 `GET /v1/referee/matches/{id}/toss`

Verified for `4065` and `4056`.

Available:

- `enabled`, `method`, `decision_options`, `result_methods`
- `state`, `calling_team_id`, `called_side`, `landed_side`, `winner_team_id`, `decision`
- `starting_setup`, `completed_at`, `is_started`, `is_result_decided`, `is_completed`
- `next_action`, `allowed_actions`, `can_update`, `blocked_reason`
- `batting_team`, `bowling_team`
- `runtime`
- `teams[]` with full `members[]`

Missing / contract issue:

- `starting_roles` is always `[]`
- `SET_STARTING_PLAYERS` is not advertised in `allowed_actions`
- Toss completes at `SET_DECISION`, so the "set openers" step cannot run
- No match code or session fields

Observed completed toss (`4056`):

```json
{
  "state": "TOSS_COMPLETED",
  "winner_team_id": 2156,
  "decision": "BAT_FIRST",
  "starting_setup": null,
  "is_completed": true,
  "next_action": null,
  "allowed_actions": [],
  "starting_roles": []
}
```

Decision needed from backend:

1. Restore `starting_roles` and allow `SET_STARTING_PLAYERS` after decision, or
2. Confirm openers must be set through `PUT /score` (`SET_BATTERS` / `SET_BOWLER`), or
3. Remove the starting-players step from the UI contract.

---

### 3.6 `GET /v1/referee/matches/{id}/score`

Verified root keys for `4065` and `4056`:

```text
match, tournament, sport, format, teams, schedule, scoring, toss, result
```

`match` only has:

```json
{ "id": 4056, "status": 3, "match_number": 1, "winner_team_id": 2156, "is_walkover": false }
```

`scoring` keys:

```text
enabled, method, period_type, periods_count, current_period,
available_events, expected_payload, allowed_actions, next_action, runtime, score
```

`format` only has `id` and `name` (`T20`).

Missing:

| Field | Used by |
|---|---|
| `scoring.overs_per_innings` | `Over 4/5` display |
| `scoring.balls_per_over` | Ball counters (currently assumed 6) |
| `scoring.max_wickets` | All-out detection / UI |
| `match_code` | Header `SP-10245` |
| `booking_source` | Header `by Partner` |
| `round` / `stage` | Header `Quarter Final` |
| `status_label` | `Ongoing` / `Live Now` |
| `result.message` / `result_margin` | `won by 18 runs` |

Important: `format.name` says `T20`, but the test match is actually 2 overs. Total overs must come from `scoring.overs_per_innings`, not format name.

`result` currently:

```json
{ "status": "WIN", "winner_team_id": 2156, "message": null }
```

Requested:

```json
{
  "result": {
    "status": "WIN",
    "winner_team_id": 2156,
    "winner_team_name": "Demo T387 Team 1",
    "message": "Demo T387 Team 1 won by 3 runs",
    "margin": { "type": "RUNS", "value": 3 }
  }
}
```

What already works (confirmed live):

- `runtime.current_over`, `current_ball`
- `runtime.current_over_deliveries[]`
- `runtime.current_batting_team`, `current_bowling_team`
- `runtime.current_striker`, `current_non_striker`, `current_bowler`, `current_wicket_keeper`
- `runtime.awaiting_batter`, `awaiting_bowler`, `innings_complete`
- `runtime.dismissed_batters[]`
- `runtime.is_super_over`, `super_over_round`
- `runtime.target`, `runs_required`
- `runtime.events[]`, `last_event`
- `scoring.score.teams[teamId] = { score, wickets, legal_balls, overs, extras }`
- `scoring.score.super_over.regulation_teams`
- `available_events` now includes `is_legal_delivery`, `wicket_types`, `base_runs`, `additional_runs_optional`

Bugs observed:

- `runtime.dismissed_batters` was `[]` on completed match `4056` even though 2 wickets were recorded in the super over.
- Fresh match `4065` returns `scoring.score` as `{}` instead of `{ "teams": {}, "super_over": null }`.
- Fresh match runtime has no `current_over`, `current_ball`, `events`, or awaiting flags; client must tolerate missing keys.
- `scoring.overs_per_innings` is absent even though `period_type` and `periods_count` are present.

Note: The Flutter models do not parse these new fields yet, but the backend is already sending them:

- `available_events[].is_legal_delivery`
- `available_events[].base_runs`
- `available_events[].additional_runs_optional`
- `available_events[].wicket_types`

---

### 3.7 `GET /v1/referee/matches/{id}/scorecard`

This endpoint exists and works. Example for `4056`:

```text
data_availability, innings[], super_overs[], team_totals, super_over_totals
```

`innings[]` contains:

- `innings_number`, `innings_type`, `super_over_round`
- `batting_team_id`, `batting_team_name`, `bowling_team_id`, `bowling_team_name`
- `totals`: `runs`, `wickets`, `legal_balls`, `overs`, `extras`
- `batting[]`: `player_id`, `name`, `runs`, `balls_faced`, `fours`, `sixes`, `strike_rate`, `status`, `dismissal`
- `bowling[]`: `player_id`, `name`, `legal_balls`, `overs`, `runs_conceded`, `wickets`, `maidens`, `dot_balls`, `wides`, `no_balls`, `economy_rate`
- `fall_of_wickets[]`: `wicket_number`, `score`, `player_id`, `player_name`, `over_number`, `ball_number`, `event_sequence`

Missing:

| Field | Used by |
|---|---|
| `player_of_match` | Full scorecard screen |
| `result` / `result_message` / margin | Final result |
| `winner_team_name` | Result header |

Shape bug:

- Completed match `4056`: `team_totals` is an object keyed by team ID.
- Fresh match `4065`: `team_totals` is `[]`.

It should always be an object (or always an array with a documented schema).

Example fresh match response:

```json
{
  "data_availability": {
    "event_count": 0,
    "active_event_count": 0,
    "reversed_event_count": 0,
    "status": "UNAVAILABLE",
    "reason": "NO_LEDGER_EVENTS",
    "message": "No ball-by-ball player data was recorded for this match. Player statistics are not inferred from team totals."
  },
  "team_totals": [],
  "super_over_totals": null,
  "innings": [],
  "super_overs": []
}
```

Integration note: this endpoint is not present in `SportoApiEndpoints`, not in Postman, and not wired into the referee app.

---

## 4. New APIs Required

### 4.1 `GET /v1/referee/dashboard`

Home should not have to combine 4 APIs and still show hardcoded values.

Suggested response:

```json
{
  "success": true,
  "message": "Referee dashboard retrieved successfully.",
  "data": {
    "profile": {
      "id": 12419,
      "name": "SUJITH Reddy",
      "profile_photo_url": null,
      "rating": 4.8
    },
    "availability": {
      "is_available": true,
      "status_label": "On",
      "message": "Ready for your next match"
    },
    "stats": {
      "live_matches": 1,
      "upcoming_matches": 4,
      "completed_matches": 6,
      "pending_requests": 5
    },
    "wallet": {
      "balance": 3650,
      "total_earned": 5150,
      "pending": 0,
      "currency": "INR"
    },
    "today_match": { "...": "same shape as GET /matches item" },
    "recent_requests": []
  }
}
```

### 4.2 `PUT /v1/referee/availability/status`

```json
{ "is_available": true }
```

Response should include `is_available`, `status_label`, `message`.

### 4.3 Wallet / Earnings

```text
GET /v1/referee/wallet
GET /v1/referee/earnings?status=paid|pending&page=1&per_page=20
```

Minimum fields:

```json
{
  "balance": 3650,
  "total_earned": 5150,
  "pending": 0,
  "currency": "INR",
  "items": [
    {
      "match_id": 4056,
      "match_code": "SP-10245",
      "amount": 1500,
      "status": "paid",
      "paid_at": "2026-10-27T12:00:00+00:00"
    }
  ]
}
```

### 4.4 Booking Requests

Either extend `GET /v1/referee/match-requests` or add:

```text
GET  /v1/referee/booking-requests
GET  /v1/referee/booking-requests/{id}
POST /v1/referee/booking-requests/{id}/accept
POST /v1/referee/booking-requests/{id}/reject
```

Minimum item shape:

```json
{
  "id": 123,
  "source": "user",
  "sport": "Cricket",
  "match_code": "SP-10245",
  "tournament": "Hyderabad Corporate Cricket Tournament",
  "customer": {
    "id": 55,
    "name": "Rahul Kumar"
  },
  "venue": {
    "name": "ABC Sports Arena",
    "location": "Madhapur, Hyderabad"
  },
  "distance_km": 8.4,
  "date": "2026-10-13",
  "start_time": "17:00",
  "end_time": "19:00",
  "duration_minutes": 120,
  "fee": 1500,
  "currency": "INR",
  "status": "requested",
  "created_at": "2026-10-12T14:20:00+00:00"
}
```

### 4.5 Match Session / OTP

```text
GET  /v1/referee/matches/{id}/session
POST /v1/referee/matches/{id}/session/start
POST /v1/referee/matches/{id}/session/end
```

Start/end request:

```json
{ "otp": "123456" }
```

Session response:

```json
{
  "session_status": "started",
  "started_at": "2026-10-13T17:02:00+00:00",
  "ended_at": null,
  "started_via": "otp",
  "otp_verified": true
}
```

Required fields for UI:

- `session_status`
- `started_at`
- `ended_at`
- `started_via`
- `otp_verified`

Important current behavior: the app compares the entered OTP against `match_otp` / `session_otp` / `start_otp` / `otp` from the match payload. The backend returns none of those, so OTP verification is skipped entirely.

### 4.6 Team / Ground Verification

```text
POST /v1/referee/matches/{id}/verify
```

Request:

```json
{ "teams_verified": true, "ground_ready": true }
```

Response/fields:

```json
{
  "teams_verified": true,
  "ground_ready": true,
  "verified_at": "2026-10-13T16:50:00+00:00"
}
```

### 4.7 Match Status / Delay

```text
PUT /v1/referee/matches/{id}/status
```

Request:

```json
{
  "status": "delayed",
  "delay_reason": "Heavy Rain",
  "weather": "Rain",
  "resume_at": "2026-10-13T16:00:00+00:00"
}
```

Response should include `status`, `status_label`, `delay_reason`, `weather`, `resume_at`.

---

## 5. Recommended Response Additions Summary

### `GET /v1/referee/matches` item

Add:

```text
match_code
booking_source
customer_name
fee
currency
distance_km
duration_minutes
status_label
score.team_a.{runs,wickets,overs}
score.team_b.{runs,wickets,overs}
current_batter
current_bowler
winner_team_name
result_message
delay_reason
resume_at
teams_verified
ground_ready
```

### `GET /v1/referee/matches/{id}/score`

Add:

```text
match_code
booking_source
round
stage
status_label
scoring.overs_per_innings
scoring.balls_per_over
scoring.max_wickets
result.winner_team_name
result.message
result.margin
```

### `GET /v1/referee/matches/{id}/scorecard`

Add:

```text
player_of_match.{player_id,name,runs,wickets}
result.winner_team_id
result.winner_team_name
result.message
result.margin
```

Fix:

```text
team_totals: always object, never []
```

### `GET /v1/referee/profile`

Add:

```text
is_available
status_label
status_message
rating
profile_photo_url
wallet.balance
wallet.total_earned
wallet.pending
wallet.currency
```

---

## 6. Bugs / Contract Issues

| # | Issue | Endpoint | Impact |
|---|---|---|---|
| 1 | Start/End OTP endpoints and fields do not exist | Match detail/session | OTP screens are no-ops |
| 2 | `starting_roles` is always `[]` and `SET_STARTING_PLAYERS` is not advertised | `GET /toss` | Openers step cannot run |
| 3 | `scoring.overs_per_innings` missing | `GET /score` | `Over x/5` cannot render |
| 4 | `scorecard.team_totals` is object for completed but `[]` for fresh | `GET /scorecard` | Client parsing breaks |
| 5 | `runtime.dismissed_batters` empty despite wickets | `GET /score` | Wicket display unreliable |
| 6 | Match list has no score fields | `GET /matches` | Completed/upcoming cards show `—` |
| 7 | Match list has no winner name/result message | `GET /matches` | Only `winner_team_id` available |
| 8 | No match code | match APIs | UI falls back to `SP-{id}` or shows `match_number` |
| 9 | No booking source/customer/fee/distance | match/request APIs | Incoming request cards cannot be filled |
| 10 | No delay/weather/resume fields | match APIs | Delayed card cannot be filled |
| 11 | No verify/checklist fields or endpoint | match APIs | Verify Teams is local-only |
| 12 | No wallet/earnings/dashboard | profile/dashboard | Home values are hardcoded |
| 13 | `schedule` is `null` on some assigned matches | `GET /matches`, detail | Start time/venue missing |
| 14 | `result.message` is `null` | `GET /score` | No `won by X runs` text |
| 15 | Scorecard has no player of the match | `GET /scorecard` | Full scorecard screen incomplete |
| 16 | Scorecard endpoint missing from Postman/docs/client | `GET /scorecard` | Integration risk |

---

## 7. Priority Order

### P0 - Blocks new flows

1. Match start/end OTP + session APIs.
2. Referee dashboard + wallet/earnings + online status.
3. Booking request data (source, customer, fee, distance, status) or dedicated booking APIs.
4. Match code in match responses.
5. Match list score summary.
6. `scoring.overs_per_innings`.

### P1 - Needed for pixel-complete cards

7. Winner name + result message/margin.
8. `current_batter` / `current_bowler` in match list.
9. Delay/weather/resume fields + status API.
10. Teams verified/ground ready fields + verify API.
11. Player of the match in scorecard.
12. Fix `scorecard.team_totals` shape.
13. Fix `dismissed_batters`.

### P2 - Contract cleanup

14. Decide `SET_STARTING_PLAYERS` / `starting_roles` contract.
15. Document `GET /scorecard` in Postman.
16. Add `balls_per_over` and `max_wickets`.
17. Populate `schedule` consistently on assigned matches.
18. Return `{teams:{}}` instead of `{}` for a fresh score.

---

## 8. Raw Test Evidence

All of these returned `200`:

```text
GET /v1/referee/profile
GET /v1/referee/matches?page=1&per_page=50
GET /v1/referee/match-requests?page=1&per_page=50
GET /v1/referee/matches/4065
GET /v1/referee/matches/4065/toss
GET /v1/referee/matches/4065/score
GET /v1/referee/matches/4065/scorecard
GET /v1/referee/matches/4056
GET /v1/referee/matches/4056/toss
GET /v1/referee/matches/4056/score
GET /v1/referee/matches/4056/scorecard
GET /v1/referee/matches/4050/score
GET /v1/referee/matches/4061/score
```

These returned `404`:

```text
GET /v1/referee/dashboard
GET /v1/referee/wallet
GET /v1/referee/earnings
GET /v1/referee/bookings
GET /v1/referee/booking-requests
GET /v1/referee/matches/{id}/session
GET /v1/referee/matches/{id}/session/otp
GET /v1/referee/matches/{id}/start-otp
GET /v1/referee/matches/{id}/end-otp
GET /v1/referee/matches/{id}/verify
GET /v1/referee/matches/{id}/result
GET /v1/referee/matches/{id}/result-summary
GET /v1/referee/availability/status
GET /v1/referee/status
GET /v1/referee/earnings/summary
GET /v1/referee/dashboard/stats
```

For comparison, the partner side already has a dashboard:

```text
GET /v1/partner/dashboard -> 200
```

It returns `summary` counts and `total_revenue`, which is the pattern the referee dashboard should follow.
