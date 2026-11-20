# Referee App — Backend API Gap Report

**Verified live:** 19 Nov 2026  
**Test tournament:** `431` / `ZBYV5BTSUU` — approved, 4 teams, 3 matches generated  
**Assignments:** `2535`, `2536`, `2537` — all accepted by referee `12447`

---

## 1. P0 — `GET /v1/referee/tournaments`

**Current response for tournament 431:**

```json
{
  "id": 431,
  "name": "SPORTO Referee Submit QA 2026-11-19",
  "code": "ZBYV5BTSUU",
  "status": 2,
  "currency": "INR"
}
```

**Please add these keys to each row:**

```json
{
  "venue_name": "SPORTO QA Ground 2",
  "city": "Hyderabad",
  "location": "Kukatpally, Hyderabad",
  "start_date": "2026-11-25",
  "end_date": "2026-11-27",
  "teams_registered": 4,
  "teams_capacity": 4,
  "registration_fee": 100.00,
  "total_prize_money": 1000.00,
  "earnings": null,
  "level": "Local",
  "status_label": "Published",
  "approval_status": 4,
  "sport_name": "Cricket",
  "sport_format": "T20",
  "tournament_type": "Knockout",
  "logo_url": null
}
```

Why: the referee tournament card currently has to show static venue/date/teams/fee/level values because this endpoint does not send them.

Also add **`status` filter support**:

```http
GET /v1/referee/tournaments?status=completed
GET /v1/referee/tournaments?status=cancelled
GET /v1/referee/tournaments?status=active
```

Right now the app fetches all rows and filters status `7/8` locally. Published tournament 431 (`status=2`) is hidden because the screen only has Completed/Cancelled tabs. Frontend also needs an active tab, but backend should support the filter.

---

## 2. P0 — `GET /v1/referee/tournaments/{id}`

This endpoint currently returns **404**:

```http
GET /api/v1/referee/tournaments/431
→ 404 Not Found
```

Either add a detail endpoint or return the full tournament object in the list. The app currently cannot open tournament details or show the full approved tournament data.

---

## 3. P0 — Match APIs

Tested:

- `GET /v1/referee/matches`
- `GET /v1/referee/matches/4205`
- `GET /v1/referee/match-requests`

### Good news

Schedule and venue are now present for tournament 431:

```json
"schedule": {
  "date": "2026-11-25",
  "start_time": "05:15",
  "end_time": "06:45",
  "venue": {
    "id": 596,
    "name": "SPORTO QA Ground 2",
    "location": "Kukatpally, Hyderabad"
  }
}
```

`duration_minutes`, `tournament`, `assignment`, `participants` and `toss` are also present. This part is working.

### Still missing / inconsistent

Top-level fields are still null while nested values exist:

```json
"venue_name": null,
"location": null,
"distance_km": null,
"fee": null,
"customer_name": null
```

Please either populate the top-level fields:

```json
"venue_name": "SPORTO QA Ground 2",
"location": "Kukatpally, Hyderabad"
```

or document that `schedule.venue` is the only source of truth.

Also confirm:

- `distance_km` is null because no real referee↔venue coordinates exist. Need a real value or a permanent `null` policy.
- `fee` and `customer_name` are null for tournament assignments. If that is intentional, confirm so the UI fields can be removed; otherwise add the tournament organiser/fee projection.
- `result_margin` and `player_of_match` must be populated after a match is completed. They are null now because matches are upcoming — expected.
- `duration_minutes` is present (90), which is good.

### Final match 4206

Current state:

```json
"participants_state": {
  "ready": false,
  "code": "PARTICIPANTS_NOT_RESOLVED"
},
"can_officiate": false,
"blocking_code": "PARTICIPANTS_NOT_RESOLVED"
```

This is expected until the two semi-finals finish. After both results are saved, the final participants and `can_officiate` must update automatically. Please confirm this happens.

---

## 4. P0 — Booking request detail

Not covered by today's tournament since `/v1/referee/bookings/requests` was empty, but the known gap remains.

`GET /v1/referee/bookings/requests/{assignment_id}` must include the same fields as the list:

```json
{
  "booked_by": {
    "display_name": "Rahul Kumar",
    "avatar_url": null
  },
  "request_type": "REFEREE_BOOKING",
  "venue_name": "ABC Sports Arena",
  "address_line_1": "Madhapur",
  "city": "Hyderabad",
  "state": "Telangana",
  "location": "ABC Sports Arena, Madhapur, Hyderabad",
  "competition_name": "Hyderabad Corporate Cricket Tournament",
  "match_code": "SP-10245",
  "distance_km": null
}
```

List and detail must return the same contract. Currently detail is missing `booked_by` and the list is not guaranteed to match.

---

## 5. P0 — Wallet transaction ledger

`GET /v1/referee/wallet/transactions` and `/earnings` still return empty rows and no documented schema.

Please add the row contract:

```json
{
  "id": 9001,
  "reference": "TXN-2026-1042",
  "type": "EARNING",
  "category": "EARNING",
  "direction": "CREDIT",
  "amount": 1500.00,
  "currency": "INR",
  "status": "PAID",
  "status_label": "Paid",
  "description": "Match Fee - SP-10245",
  "title": "Match Fee - SP-10245",
  "tournament": { "id": 431, "name": "..." },
  "match_id": 4205,
  "match_code": "SP-4205",
  "booked_by": { "display_name": "Rahul Kumar" },
  "paid_at": "2026-11-19T10:30:00Z",
  "created_at": "2026-11-19T10:30:00Z",
  "payment_method": "Spoto Wallet Credit"
}
```

Also needed:

- `GET /v1/referee/wallet/transactions/{id}` — transaction details/receipt
- Withdraw endpoint or documented payout flow
- Statement download endpoint

---

## 6. P1 — Dashboard contract

Current dashboard uses:

```json
"stats": { ... }
```

but other clients/docs refer to `statistics`. Please standardise or return both aliases. The app currently reads `stats` and displays 0 Live / 5 Upcoming / 2 Completed correctly, so this is a consistency issue, not a blocker.

`today_matches` is empty because the assigned matches are on 25 Nov, not today. Not a bug.

`recent_requests` is empty after all 3 assignments were accepted. Not a bug.

---

## 7. P1 — Partner tournament API bugs

### 7.1 Create requires `minimum_teams` / `maximum_teams`

The documented minimal payload:

```json
{
  "tournament_type_id": 1,
  "sport_id": 1,
  "sport_format_id": 1
}
```

returns **500**:

> "Tournament round structure could not be generated. minimum_teams or maximum_teams is required and must be at least 2."

Adding:

```json
"minimum_teams": 2,
"maximum_teams": 4
```

fixes it. Either update the docs or make the fields genuinely optional with defaults.

### 7.2 Approval fields are inconsistent

`GET /v1/partner/tournaments/431` returns:

```json
"approval_status": null,
"submitted_at": null,
"approved_at": null,
"approval": {
  "status": 4,
  "submitted_at": "2026-11-19T16:21:45.000000Z",
  "approved_at": "2026-11-19T16:22:16.000000Z"
}
```

Please flatten these consistently on tournament list/detail:

```json
"approval_status": 4,
"submitted_at": "...",
"approved_at": "...",
"approved_by": { "id": 1, "name": "Administrator" }
```

### 7.3 Tournament slug

Tournament 431 was renamed from `Draft Tournament` to `SPORTO Referee Submit QA 2026-11-19`, but `slug` remained:

```json
"slug": "draft-fhxel4jo4a"
```

Please regenerate or explicitly confirm slug immutability.

---

## 8. P1 — Bank

- List/detail only return a masked number. Need a step-up/re-auth endpoint that returns the full number for one short-lived use.
- `POST /bank/reverify/{id}` or documented re-verification flow is missing.
- Confirm whether referees can have UPI-only payout rows; the UI is currently BANK-only.
- Bank logo is not returned; optional.

---

## 9. P1 — Notification preferences

No backend endpoints exist. Need:

```http
GET /v1/referee/notification-preferences
PUT /v1/referee/notification-preferences
```

With stable category ids, titles, descriptions and enabled flags.

---

## 10. Confirmed working — no action needed

- Partner OTP auth
- Tournament create/update/budget/venue/submit
- Admin approval → status 2 published
- Team registration (4 teams)
- Schedule generation (3 matches)
- Partner referee assignment
- Referee availability slot creation
- Referee match-request acceptance
- `GET /v1/referee/matches` now includes assigned tournament matches
- Match schedule + nested venue are present
- Referee stats, availability, profile
- Bank CRUD/default/delete
- Match scoring/toss/session APIs per previous runs

---

## 11. Suggested acceptance test after backend changes

For tournament 431 and match 4205:

```http
GET /v1/referee/tournaments
→ row includes venue, dates, teams, fee, prize, status_label, approval_status

GET /v1/referee/tournaments/431
→ 200, not 404

GET /v1/referee/matches/4205
→ top-level venue_name/location populated OR documented nested-only contract

GET /v1/referee/matches?status=upcoming
→ returns 4204, 4205, 4206 with assignment.status=2

GET /v1/referee/wallet/transactions
→ at least one documented row after completed match

GET /v1/referee/notification-preferences
→ 200 with preference rows
```

**Highest priority:** tournament list fields + detail endpoint, match top-level venue consistency, booking detail contract, wallet row schema.
