# Referee App — Backend API Requirements

Generated: 2026-11-15  
Scope: `apps/referee_app`  
Base URL: `/api`  
Source of truth: current Flutter client calls + latest repo reports

This document lists:
- What is already API-backed in the referee app.
- What is still static/hardcoded in the UI.
- Which APIs the backend must implement or complete.
- Required request/response fields per screen.

---

## 1. Status legend

| Symbol | Meaning |
|---|---|
| ✅ | Flutter client already calls this endpoint. Backend must return complete data. |
| 🆕 | New API/endpoint required. |
| ⚠️ | Endpoint exists but fields/contract need verification or fixes. |

---

## 2. Screen → API map

### 2.1 Auth / Onboarding / Application

| Screen/Flow | APIs | Status |
|---|---|---|
| Login / OTP | `POST /v1/referee/send-otp`, `POST /v1/referee/verify-otp` | ✅ |
| Application state | `GET /v1/referee/application` | ✅ |
| Personal info | `GET/POST /v1/referee/application/personal` | ✅ |
| Address | `GET/POST /v1/referee/application/address` | ✅ |
| Sports | `GET/POST /v1/referee/application/sports` | ✅ |
| Availability onboarding | `GET/POST /v1/referee/application/availability` | ✅ |
| Documents | `GET/POST/DELETE /v1/referee/application/documents` | ✅ |
| Review | `GET /v1/referee/application/review` | ✅ |
| Submit | `POST /v1/referee/application/submit` | ✅ |
| Status | `GET /v1/referee/application/status` | ✅ |

### 2.2 Home

| UI block | APIs | Status |
|---|---|---|
| Header wallet balance | `GET /v1/referee/wallet` → `balance`, `currency` | 🆕 |
| Wallet card | `GET /v1/referee/wallet` → `balance`, `total_earned`, `pending` | 🆕 |
| Earnings stat | `GET /v1/referee/earnings` | 🆕 |
| Live/upcoming/completed counts | `GET /v1/referee/matches` | ✅ |
| Incoming request preview | `GET /v1/referee/match-requests`, `GET /v1/referee/bookings/requests` | ✅ |
| Availability toggle | `GET/PUT /v1/referee/availability/status` | ✅ |
| Search | `GET /v1/referee/search?query=` | 🆕 or remove UI |
| Notifications bell | `GET /v1/referee/notifications` | 🆕 or remove UI |
| Ads banner | Ads API | 🆕 or keep static |
| Dashboard totals | `GET /v1/referee/dashboard` | 🆕 recommended |

Current hardcoded values in `referee_home_screen.dart`:
- Header wallet: `500`
- Wallet card: `₹13,650`, `₹15,150`, `₹10`
- Earnings fallback: `₹18,500`
- Search bar and bell have no action
- Ads banner is static

### 2.3 Matches list / Schedule

| UI block | APIs | Status |
|---|---|---|
| Match cards | `GET /v1/referee/matches` | ✅ ⚠️ |
| Booking match cards | `GET /v1/referee/bookings` | ✅ ⚠️ |
| Live score on cards | `GET /v1/referee/matches/{id}/score` | ✅ |
| Update delayed/resume status | `PUT /v1/referee/matches/{id}/status` | ✅ |
| Verify checklist | `GET /v1/referee/matches/{id}/session` or `/verify` | ✅ ⚠️ |

Missing match fields:
```text
match_code
booking_source / booked_by_type
customer_name
fee / expected_earnings
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
result_margin
delay_reason
weather
resume_at
teams_verified
ground_ready
verified_at
```

Current static fallbacks:
- Duration renders `-` because no API field
- Teams Verified / Ground Ready always show checked
- Toss Pending always shows warning
- Delay reason fallback: `Heavy Rain`
- Resume time falls back to match start time

### 2.4 Incoming Requests

| UI block | APIs | Status |
|---|---|---|
| Request list | `GET /v1/referee/match-requests`, `GET /v1/referee/bookings/requests` | ✅ ⚠️ |
| Request detail | `GET /v1/referee/bookings/requests/{assignmentId}` | ✅ ⚠️ |
| Accept | `POST /v1/referee/match-requests/{id}/accept`, `POST /v1/referee/bookings/requests/{assignmentId}/accept` | ✅ |
| Reject | `POST /v1/referee/match-requests/{id}/reject`, `POST /v1/referee/bookings/requests/{assignmentId}/reject` | ✅ |

Required fields for match-request items:
```text
booking_source / booked_by_type
customer.{id,name}
fee
currency
distance_km
duration_minutes
venue.{name,location}
booking_status
created_at
```

Current UI fallbacks:
```text
Booking source  -> "by User"
Customer name   -> "User"
Fee             -> 1500
Duration        -> 2 hr
Distance        -> 8.4 km
Venue           -> "KPHB Indoor Stadium"
Location        -> "ABC Sports Arena, Madhapur, Hyderabad"
Status          -> "Request Received"
```

### 2.5 Request Details / Accept Booking / Booking Confirmed

| UI block | APIs | Status |
|---|---|---|
| Request details | `GET /v1/referee/bookings/requests/{assignmentId}` | ✅ ⚠️ |
| Accept booking | `POST /v1/referee/bookings/requests/{assignmentId}/accept` | ✅ |
| Booking confirmed | Same booking-request detail API | ✅ ⚠️ |

These screens need the same booking fields listed in 2.4.

### 2.6 Booking Session

| UI block | APIs | Status |
|---|---|---|
| Session status | `GET /v1/referee/bookings/{id}/session` | ✅ |
| Toss OTP | `POST /v1/referee/bookings/{id}/session/toss/verify` | ✅ |
| Start OTP | `POST /v1/referee/bookings/{id}/session/start/verify` | ✅ |
| End OTP | `POST /v1/referee/bookings/{id}/session/end/verify` | ✅ |

### 2.7 Match Verification / Start Match

| UI block | APIs | Status |
|---|---|---|
| Match details | `GET /v1/referee/matches/{id}` | ✅ |
| Readiness | `GET /v1/referee/matches/{id}/verify` | ✅ ⚠️ |
| Verify teams/ground | `POST /v1/referee/matches/{id}/verify` | ✅ ⚠️ |
| Session | `GET /v1/referee/matches/{id}/session` | ✅ ⚠️ |
| Start session | `POST /v1/referee/matches/{id}/session/start` | ✅ ⚠️ |
| End session | `POST /v1/referee/matches/{id}/session/end` | ✅ ⚠️ |
| Withdraw session | `POST /v1/referee/matches/{id}/session/withdraw` | ✅ ⚠️ |

Required session fields:
```text
match_code
session_status
started_at
ended_at
started_via
otp_verified
teams_verified
ground_ready
verified_at
toss_otp_verified
toss_verified_at
toss_otp_issued
start_otp_issued
end_otp_issued
delay_reason
weather
resume_at
```

### 2.8 Conduct Toss

| UI block | APIs | Status |
|---|---|---|
| Toss state/actions | `GET/PUT /v1/referee/matches/{id}/toss` | ✅ ⚠️ |
| Starting players | Same toss API | ✅ ⚠️ |

Backend decision required:
1. Return `starting_roles` and allow `SET_STARTING_PLAYERS`, or
2. Confirm openers are set via score `SET_BATTERS` / `SET_BOWLER`, or
3. Remove the starting-players step from the contract.

Current UI shows:
> “Starting players are not available from the match roster yet.”

### 2.9 Live Scoring

| UI block | APIs | Status |
|---|---|---|
| Score state | `GET /v1/referee/matches/{id}/score` | ✅ ⚠️ |
| Score mutation | `PUT /v1/referee/matches/{id}/score` | ✅ ⚠️ |
| Ball-by-ball events | `GET /v1/referee/matches/{id}/score/events` | ✅ |

Required score fields:
```text
scoring.overs_per_innings
scoring.balls_per_over
scoring.max_wickets
match_code
status_label
result.winner_team_name
result.message
result.margin
```

Notes:
- `overs_per_innings` is now parsed by Flutter when present.
- `balls_per_over` is assumed as 6.
- `max_wickets` is derived from roster size instead of backend.
- Fallback run buttons `[0,1,2,4,6]` are used when `available_events` is empty.

### 2.10 Match Result

| UI block | APIs | Status |
|---|---|---|
| Result header | `GET /v1/referee/matches/{id}/result` | ✅ ⚠️ |
| Scorecard | `GET /v1/referee/matches/{id}/scorecard` | ✅ ⚠️ |
| Ball-by-ball | `GET /v1/referee/matches/{id}/score/events` | ✅ |

Required fields:
```text
player_of_match
result.winner_team_id
result.winner_team_name
result.message
result.margin
team_totals (always object, never [])
```

### 2.11 Match History / Scoring Tab

| UI block | APIs | Status |
|---|---|---|
| Completed matches | `GET /v1/referee/matches`, `GET /v1/referee/bookings?filter=completed` | ✅ |
| Winner/scores | `GET /v1/referee/matches/{id}/score` | ✅ |
| Date filters | Client-side | — |

### 2.12 Profile

| UI block | APIs | Status |
|---|---|---|
| Profile data | `GET /v1/referee/profile` | ✅ ⚠️ |
| Matches count | Profile `total_matches` or statistics API | 🆕 |
| Rating | Profile `rating` | 🆕 |
| Disputes | Profile `disputes_count` | 🆕 |
| Statistic | `GET /v1/referee/statistics` | 🆕 |
| My Tournaments | `GET /v1/referee/tournaments` | 🆕 |
| Wallet Transaction | `GET /v1/referee/wallet/transactions` | 🆕 |
| Bank Account | `GET /v1/referee/bank-account` | 🆕 |
| Support / About / Terms / Privacy | CMS/support APIs or static content | 🆕 |

Current static values:
- Matches = `experienceYears`
- Rating = `4.9`
- Disputes = `2`
- Several menu items have no action.

### 2.13 Weekly Availability

| UI block | APIs | Status |
|---|---|---|
| Weekdays | `GET /v1/referee/availability/days` | ✅ |
| Slots | `GET/POST /v1/referee/availability` | ✅ |
| Update/delete slot | `PUT/DELETE /v1/referee/availability/{slotId}` | ✅ |
| Day toggle/clear | `POST /v1/referee/availability/days/{day}/toggle`, `POST /v1/referee/availability/days/{day}/clear` | ✅ |
| Global status | `GET/PUT /v1/referee/availability/status` | ✅ |

---

## 3. New APIs required

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/v1/referee/dashboard` | Home summary, stats, wallet, today match, requests |
| GET | `/v1/referee/wallet` | Balance, total earned, pending, currency |
| GET | `/v1/referee/earnings?status=paid\|pending` | Earnings list |
| GET | `/v1/referee/notifications` | Bell/notifications |
| GET | `/v1/referee/statistics` | Profile statistics |
| GET | `/v1/referee/disputes` | Profile disputes |
| GET | `/v1/referee/tournaments` | My Tournaments |
| GET | `/v1/referee/wallet/transactions` | Wallet transaction history |
| GET | `/v1/referee/bank-account` | Bank account details |
| GET | `/v1/referee/search?query=` | Global search (optional) |
| GET | `/v1/referee/support` | Support/CMS content (optional) |

---

## 4. Recommended response additions

### 4.1 Profile
```json
{
  "profile": {
    "id": 12419,
    "name": "SUJITH Reddy",
    "profile_photo_url": null,
    "rating": 4.8,
    "total_matches": 36,
    "disputes_count": 2,
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

### 4.2 Match list item
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
  "weather": null,
  "resume_at": null,
  "teams_verified": true,
  "ground_ready": true,
  "verified_at": "2026-11-06T14:00:00+00:00"
}
```

### 4.3 Booking request item
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

---

## 5. Backend bugs / contract issues to fix or re-verify

| # | Issue | Endpoint | Impact |
|---|---|---|---|
| 1 | Match session/verify/OTP endpoints were reported missing | `/matches/{id}/session`, `/verify`, `/session/start\|end\|withdraw` | Start Match / Verify Teams broken |
| 2 | `starting_roles` empty and `SET_STARTING_PLAYERS` rejected | `GET/PUT /toss` | Openers step cannot complete |
| 3 | `balls_per_over` / `max_wickets` absent | `GET /score` | Client assumes values |
| 4 | Score mutations previously returned 500 | `PUT /score` | Scoring blocked before fix |
| 5 | `MATCH_COMPLETED` event not emitted | `PUT /score` | Final event feed incomplete |
| 6 | Last-ball event stamped after over rollover | `PUT /score` | Ball-by-ball feed wrong for 6th ball |
| 7 | `team_totals` returns `[]` on fresh match | `GET /scorecard` | Client parsing |
| 8 | Match list misses assigned match | `GET /matches` | Empty Home/Schedule |
| 9 | Match-request shape lacks booking fields | `GET /match-requests` | Cards show fallback values |
| 10 | Delay/weather/resume fields absent | match/session APIs | Delayed card shows `Heavy Rain` |
| 11 | Verify checklist fields absent | match/session APIs | “Teams Verified / Ground Ready” hardcoded |
| 12 | Result endpoint/fields missing | `GET /result` | Result screen incomplete |
| 13 | Player of the match missing | `GET /scorecard` | Result screen incomplete |
| 14 | Profile rating/disputes/wallet missing | `GET /profile` | Hardcoded UI |

---

## 6. Priority checklist for backend

### P0 — blocks new flows
- [ ] Match session + verify + start/end/withdraw + OTP APIs
- [ ] Referee dashboard + wallet + earnings + online status
- [ ] Booking source/customer/fee/distance/duration/status in request APIs
- [ ] `match_code`, score summary, duration in match list
- [ ] `teams_verified`, `ground_ready`, `verified_at`
- [ ] `delay_reason`, `weather`, `resume_at`

### P1 — needed for complete cards
- [ ] Winner name + result message/margin
- [ ] `current_batter` / `current_bowler` in match list
- [ ] `player_of_match` in scorecard
- [ ] Fix `team_totals` shape
- [ ] Fix `dismissed_batters`
- [ ] Toss starting-players contract
- [ ] `balls_per_over` / `max_wickets`

### P2 — profile/extras
- [ ] Profile statistics, rating, disputes
- [ ] Wallet transactions, bank account, tournaments history
- [ ] Notifications
- [ ] Support/legal CMS content
- [ ] Search API (if required)

---

## 7. Notes

- The Flutter client is already wired to most endpoints; the main work is response completeness and missing APIs.
- Some earlier backend-gap items are now parsed by the client (`overs_per_innings`, `starting_roles`, `player_of_match`, `match_code`, `winner_team_name`, session verify/delay fields). Re-verify them on the current backend.
- No new Flutter work is required for fields already modeled; missing fields will light up automatically once the backend returns them.
