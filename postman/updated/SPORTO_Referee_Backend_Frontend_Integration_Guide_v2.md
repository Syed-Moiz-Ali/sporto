# SPORTO Referee — Backend API Integration Guide

**Date:** 2026-11-15  
**Scope:** API contract and integration instructions only. **No Flutter, Dart, UI, or frontend source code was changed.**  
**Backend repository:** https://github.com/spvn81/sporto-backend  
**API base:** `https://<your-backend-host>/api/v1/referee`  
**Authentication:** `Authorization: Bearer <referee_token>`  
**Accept:** `application/json`  
**Mutations:** raw JSON with `Content-Type: application/json` (except document uploads)

> This guide describes the Referee backend contracts from merged PRs #104 and #105. GitHub confirms the PR #105 deployment workflow succeeded; independent authenticated live smoke tests have not been performed here.

## 1. Import the existing, canonical Postman collections

Do not create duplicate Postman collections. Import the five files from the repo's [`postman/Referee/`](https://github.com/spvn81/sporto-backend/tree/main/postman/Referee) directory:

| Collection file | Coverage | GitHub source |
|---|---|---|
| `referee.php.postman_collection.json` | OTP/login, onboarding, profile, dashboard, earnings, statistics, tournaments, wallet history | [View collection](https://github.com/spvn81/sporto-backend/blob/main/postman/Referee/referee.php.postman_collection.json) |
| `match.php.postman_collection.json` | Match assignments, toss, start/end, scoring, scorecard, results; **Player of the Match POST (PR #105 merged)** | [View collection](https://github.com/spvn81/sporto-backend/blob/main/postman/Referee/match.php.postman_collection.json) |
| `referee-booking.postman_collection.json` | Independent booking requests, acceptance/rejection, booking sessions | [View collection](https://github.com/spvn81/sporto-backend/blob/main/postman/Referee/referee-booking.postman_collection.json) |
| `weekly_availability.postman_collection.json` | Availability days, slots, toggles and clearing | [View collection](https://github.com/spvn81/sporto-backend/blob/main/postman/Referee/weekly_availability.postman_collection.json) |
| `bank.php.postman_collection.json` | Bank/UPI details, default account, update/deactivation | [View collection](https://github.com/spvn81/sporto-backend/blob/main/postman/Referee/bank.php.postman_collection.json) |

Set Postman variables `referee_base_url` (host before `/api`) and `referee_token` (authorized test-referee token). Use valid server-returned identifiers for `matchId`, `assignmentId`, `bookingId` and `player_user_id`. Never commit access tokens or real OTPs to GitHub.

## 2. Standard response and error contract

Successful HTTP responses are JSON envelopes:

```json
{
  "success": true,
  "message": "...",
  "data": {}
}
```

Use HTTP **401** for no/expired auth, **403** for forbidden action, **404** for other-user/unowned records, **409** for stale lifecycle or conflicting award, **422** for field validation/unsupported player or sport, and **429** for rate/OTP attempts. Treat a nullable value as **unavailable**, not zero. Always read `data` rather than the top-level payload. Refresh the authoritative GET endpoint after a successful POST/PUT.

## 3. Home and profile

| Method | Path after `/api/v1/referee` | Consumer mapping |
|---|---|---|
| GET | `/dashboard` | `data.profile`, `data.stats`, `data.availability`, `data.wallet`, `data.today_match`, `data.today_matches`, `data.today_bookings`, `data.recent_requests`, `data.recent_booking_requests` |
| GET | `/wallet` | `data.balance`, `data.reserved_balance`, `data.total_earned`, `data.pending_earnings`, `data.simulated_unfunded_earnings`, `data.currency` |
| GET | `/earnings?status=all&page=1&per_page=20` | Own earning rows and state: `EXPECTED_NOT_PAID`, `PAID`, simulated/unfunded, pending, etc. Do not equate fee with spendable balance |
| GET | `/profile` | `data.profile.total_matches`, `rating`, `disputes_count` (nullable), plus application/profile/availability |
| GET | `/statistics` | `live_matches`, `upcoming_matches`, `completed_matches`, `pending_tournament_requests`, `pending_booking_requests`, `total_matches`, `bookings`, `rating` |
| GET | `/tournaments?page=1&per_page=20` | Paginated accepted tournament participation |
| GET | `/wallet/transactions?page=1&per_page=20` | Paginated own wallet ledger rows; never expose unmasked internal metadata |
| GET/PUT | `/availability/status` | PUT raw JSON `{"is_available": false}` |

`today_matches.items` and `today_bookings.items` are separate datasets; Partner booking may also have a match, so do not blindly sum these counts. Both use India-local date filtering. The dashboard's `recent_requests` and `recent_booking_requests` are different assignment types. Rating is null when no visible review exists; disputes count is null because the product has no recorded referee dispute data source. Currency amounts may be decimal strings.

## 4. Match list, assignments and booking requests

| Method | Endpoint | Notes |
|---|---|---|
| GET | `/matches?page=1&per_page=20` | Accepted tournament matches; `include_pending=1` optionally includes not-yet-accepted assignments |
| GET | `/matches/{matchId}` | Scoped match details and score metadata |
| GET | `/match-requests` | Pending tournament scoring assignments, paginated |
| POST | `/match-requests/{assignmentId}/accept` | Accept tournament assignment |
| POST | `/match-requests/{assignmentId}/reject` | Reject; optional `{"reason":"..."}` |
| GET | `/bookings/requests` | Pending independent booking invitations, paginated |
| GET | `/bookings/requests/{assignmentId}` | Booking invitation detail |
| POST | `/bookings/requests/{assignmentId}/accept` | Accept independent booking invitation |
| POST | `/bookings/requests/{assignmentId}/reject` | Reject independent booking invitation |
| GET | `/bookings?filter=completed` | Completed standalone/Partner bookings |

Match cards may expose `match_code`, `booking_source`, `booked_by_type`, `customer_name`, `fee`, `currency`, `duration_minutes`, `score.team_a/team_b`, `current_batter`, `current_bowler`, `winner_team_name`, `result_message`, `result_margin`, `delay_reason`, `weather`, `resume_at`, `teams_verified`, `ground_ready`, and `verified_at`. **`distance_km` is null** without trustworthy referee/venue coordinates; never replace it with `8.4 km` or another sample. Do not synthesize fees/customer names/venue/status.

For booking invitations use `assignment_id` to accept/reject, `booking_id` for booking-session APIs and `match_id` for match scoring. Do not confuse these IDs. Top-level `fee`, `currency`, `duration_minutes`, `created_at`, `expires_at` supplement authoritative nested `booking.referee_fee`, `booked_by.display_name` and venue information.

## 5. Match operations, OTP and Cricket scoring

| Method | Endpoint | JSON / notes |
|---|---|---|
| GET/POST | `/matches/{matchId}/verify` | POST `{"teams_verified":true,"ground_ready":true}` |
| GET | `/matches/{matchId}/session` | Session/readiness/timestamps/status; never returns a valid OTP |
| POST | `/matches/{matchId}/session/start` | `{"otp":"123456"}` using actual owner-issued code |
| POST | `/matches/{matchId}/session/end` | `{"otp":"123456"}` using actual owner-issued code |
| POST | `/matches/{matchId}/session/withdraw` | Withdraw pending final scoring submission; invalidates End OTP |
| PUT | `/matches/{matchId}/status` | Delay: `{"status":"delayed","delay_reason":"Ground unsafe","weather":"Rain","resume_at":"2026-11-15T12:30:00Z"}`; resume: `{"status":"resumed"}` |
| GET/PUT | `/matches/{matchId}/toss` | Follow server `allowed_actions`, `next_action`, `starting_roles`; do not force SET_STARTING_PLAYERS on empty roles |
| GET/PUT | `/matches/{matchId}/score` | Server-defined `available_events`, `allowed_actions`, `next_action`, `scoring.overs_per_innings`, `balls_per_over`, `max_wickets`; use stable UUIDs on delivery retries |
| GET | `/matches/{matchId}/score/events` | Permanent scoring ledger, scoped to match/referee |
| GET | `/matches/{matchId}/scorecard` | Cricket team totals are always a JSON object, e.g. `{}`, with nullable `player_of_match` |
| GET | `/matches/{matchId}/result` | Persisted canonical winner/status, nullable margin and player award |

Tournament and independent booking sessions are distinct flows. The booking routes are `GET /bookings/{bookingId}/session` and `POST /bookings/{bookingId}/session/{toss|start|end}/verify` with real phase/permission checks. Ordinary User bookings do not require a toss. Referees must not receive raw OTPs through read-only APIs.

## 6. Player of the Match award (PR #105 — merged and deployed)

The PR #105 API is merged and the production deployment workflow has succeeded:

```http
POST /api/v1/referee/matches/{matchId}/player-of-match
Authorization: Bearer <referee_token>
Accept: application/json
Content-Type: application/json
```

Raw JSON payload:

```json
{"player_user_id": 123}
```

Representative success response:

```json
{
  "success": true,
  "message": "Player of the Match awarded.",
  "data": {
    "match_id": 501,
    "player_of_match": {
      "user_id": 123,
      "team_id": 101,
      "name": "Player Name",
      "awarded_at": "2026-11-15T12:00:00+00:00",
      "awarded_by_referee_id": 42
    }
  }
}
```

An **accepted assigned referee** may award an **active accepted match-roster player** **once**, **after Cricket match completion**. The identical retry returns 200 without a second write. A different player replacement returns 409; wrong roster 422; unassigned referee 404; pending match 409. Award is stored in existing match configuration; no payment, wallet or scoring ledger mutation. Read it later via `GET /matches/{matchId}/result` (`data.player_of_match`), `/scorecard` and `/matches/{matchId}`. No automatic MVP choice or re-award workflow is assumed.

## 7. Exact match margin (PR #105 — merged and deployed)

For eligible **completed regulation Cricket** matches, `result.margin` may become a documented string, e.g. `"10 runs"` or `"2 wickets"`. The result projection also exposes `margin_type` (`RUNS` or `WICKETS`) and positive integer `margin_value`. On match cards the field is `result_margin`.

Calculation is conservative: requires a recorded scoring ledger version, finished second innings, explicit chase `target`, team score totals, a recorded winner, and a valid effective wicket cap for wickets results. Legacy/manual, unfinished, walkover or Super Over situations continue to return `null`. Do not display a made-up margin. A generic winner message is still possible when the winner exists.

## 8. Onboarding, weekly availability and bank details (exact existing methods)

Onboarding: `GET /application` reads draft; `POST /application/personal` writes personal details; `PUT /application/address`, `PUT /application/sports`, `PUT /application/availability` save corresponding sections; `POST /application/documents` uploads, `DELETE /application/documents/{id}` removes; `GET /application/review`, `GET /application/status`, `POST /application/submit`. **Do not send POST for address/sports/availability**.

Weekly availability: `GET /availability/days`, `GET/POST /availability`, `PUT/DELETE /availability/{slotId}`, `PUT /availability/days/{day}` with `{"is_enabled":true}`, `DELETE /availability/days/{day}` to clear slots. **Do not use POST `/toggle` or POST `/clear` aliases**.

Bank: `GET /bank/list-bank-details`, `POST /bank/add-bank-details`, `PUT /bank/update-bank-details/{bankDetail}`, `POST /bank/set-default-bank/{bankDetail}`, `DELETE /bank/delete-bank-details/{bankDetail}`. Do not call `/bank-account` (noncanonical).

## 9. Explicitly out of scope / unresolved

- No Flutter source inspection, changes or UI regression testing performed.
- No new fake notifications, global search, referee dispute records, ads, CMS/support/legal endpoints.
- No forced geocoding, location tracking or synthesized distance values; `distance_km` remains nullable.
- No change to OTP issuance/verification, financial payout/settlement logic, scoring event attribution or existing Postman auth variables.
- GitHub CI is not a substitute for authenticated production smoke tests. Validate safe read responses and a controlled test match, never change live customer data while testing.

## 10. Backend delivery verification

For the baseline Referee gap work: [PR #104](https://github.com/spvn81/sporto-backend/pull/104) was merged into `main` at `9f5ebd0857372146ba5bc92967182f018f102d93`, with successful [main CI](https://github.com/spvn81/sporto-backend/actions/runs/43698143399) and [production workflow](https://github.com/spvn81/sporto-backend/actions/runs/43698313563).

The additional award/margin implementation was merged in [PR #105](https://github.com/spvn81/sporto-backend/pull/105) at `41dd8e86d6fac91d4795ad3936663cf46ddaaac8`. Its [main-commit CI](https://github.com/spvn81/sporto-backend/actions/runs/43710977154) and [production deployment workflow](https://github.com/spvn81/sporto-backend/actions/runs/43711068905) succeeded. This is workflow-level evidence, not an authenticated runtime smoke test.
