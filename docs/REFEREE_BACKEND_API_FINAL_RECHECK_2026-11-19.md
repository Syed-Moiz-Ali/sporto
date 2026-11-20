# Referee API Final Recheck — After Second Deployment

**Rechecked:** 19 Nov 2026  
**Test tournament:** `431` / `ZBYV5BTSUU`  
**Test referee:** `12447` — Test Partner  
**Assignments:** `2535`, `2536`, `2537` — accepted

---

## 1. What backend fixed

### ✅ Referee tournament list — `GET /v1/referee/tournaments`

Tournament 431 now returns:

```json
{
  "id": 431,
  "name": "SPORTO Referee Submit QA 2026-11-19",
  "code": "ZBYV5BTSUU",
  "status": 2,
  "status_label": "Published",
  "currency": "INR",
  "approval_status": 4,
  "approval_status_label": "Approved",
  "submitted_at": "2026-11-19T16:21:45+00:00",
  "approved_at": "2026-11-19T16:22:16+00:00",
  "approved_by": { "id": 1, "name": "Administrator" },
  "start_date": "2026-11-25",
  "end_date": "2026-11-27",
  "timezone": "Asia/Kolkata",
  "venue_name": "SPORTO QA Ground 2",
  "location": "Kukatpally, Hyderabad",
  "teams_registered": 4,
  "teams_capacity": 4,
  "fee": "100.00",
  "registration_fee": "100.00",
  "prize": "1000.00",
  "total_prize_money": "1000.00",
  "prize_totals": [
    { "currency": "INR", "amount": "1000.00" }
  ],
  "earnings": [],
  "earnings_total": "0.00",
  "sport_name": "Cricket",
  "sport_format": "T20",
  "tournament_type": "Knockout"
}
```

Fixed:
- `status_label`
- `approval_status` / `approval_status_label`
- `submitted_at` / `approved_at` / `approved_by`
- `start_date` / `end_date` / `timezone`
- `venue_name` / `location` / `venues`
- `teams_registered` / `teams_capacity`
- `fee` / `registration_fee`
- `prize` / `total_prize_money` / `prize_totals`
- `earnings_total`
- `sport_name` / `sport_format` / `tournament_type`

### ✅ Tournament detail fixed

```http
GET /api/v1/referee/tournaments/431
→ 200 OK
```

Now also includes `assigned_matches`:
```json
"assigned_matches": [
  { "id": 4204, "match_code": "SP-4204", "status": 1 },
  { "id": 4205, "match_code": "SP-4205", "status": 1 },
  { "id": 4206, "match_code": "SP-4206", "status": 1 }
]
```

### ✅ Tournament status filters fixed

```http
GET /v1/referee/tournaments?status=active    → 431, 421
GET /v1/referee/tournaments?status=completed → 423, 422
GET /v1/referee/tournaments?status=cancelled → 0 rows
```

### ✅ Match list filters fixed

```http
GET /v1/referee/matches?status=upcoming  → 5 upcoming
GET /v1/referee/matches?status=completed → 2 completed
```

### ✅ Match top-level venue fixed

`GET /v1/referee/matches` now returns:

```json
"venue_name": "SPORTO QA Ground 2",
"location": "Kukatpally, Hyderabad"
```

`GET /v1/referee/matches/4205` also returns them at the top level.

### ✅ Match time contract documented

Schedule now includes:

```json
"time_basis": "UTC",
"start_time": "05:15",
"scheduled_start_at": "2026-11-25T05:15:00+00:00",
"timezone": "Asia/Kolkata",
"local_start_time": "10:45",
"local_end_time": "12:15"
```

The app now uses `local_start_time` / `local_end_time` and displays:
- `SP-4205` → **10:45 AM – 12:15 PM**
- `SP-4206` → **12:30 PM – 2:00 PM**

No further backend change needed if `time_basis: UTC` is the final contract.

### ✅ Notification preferences fixed

`GET /v1/referee/notification-preferences` returns all 5 categories.

`PUT /v1/referee/notification-preferences` accepts:

```json
{
  "preferences": [
    { "id": "match", "is_enabled": true },
    { "id": "tournament", "is_enabled": false },
    { "id": "team", "is_enabled": false },
    { "id": "payments", "is_enabled": false },
    { "id": "others", "is_enabled": false }
  ]
}
```

Response: `Notification preferences updated.` Re-fetch persisted correctly.

### ✅ Partner approval fields fixed

`GET /v1/partner/tournaments/431` now returns:

```json
"approval_status": 4,
"submitted_at": "2026-11-19T16:21:45.000000Z",
"approved_at": "2026-11-19T16:22:16.000000Z",
"approved_by": { "id": 1, "name": "Administrator" },
"total_prize_money": "1000.00"
```

### ✅ Slug issue resolved

`slug_is_immutable: true` is now returned. Slug `draft-fhxel4jo4a` staying unchanged is documented behaviour, not a bug.

---

## 2. What is still missing or needs confirmation

### 2.1 Tournament `city` and `level`

Still null:

```json
"city": null,
"level": null,
"city_source": null,
"referee_fee": null
```

Please confirm:
- `city` should be derived from venue/location or populated.
- `level` needs a real data source if the Figma tournament card should show it. Otherwise confirm it can be removed.
- `referee_fee` is null for tournament matches; confirm intentional.

`earnings` is still `[]`, but `earnings_total: "0.00"` is present. If the card uses `earnings_total`, no action is needed. If it expects `earnings` to be a number, change it.

### 2.2 Match `distance_km`, `fee`, `customer_name`

Still null on matches 4204/4205/4206:

```json
"distance_km": null,
"fee": null,
"customer_name": null
```

Please confirm these are intentionally null for tournament assignments. If the Figma card must show distance/fee, a real value or a documented fallback policy is required.

`result_margin` and `player_of_match` are null while upcoming — expected. They must populate after completion.

Final match 4206 is still blocked correctly:

```json
"can_officiate": false,
"blocking_code": "PARTICIPANTS_NOT_RESOLVED"
```

Confirm it clears automatically after semi-finals 4204 and 4205 are completed.

### 2.3 Wallet transactions

`GET /v1/referee/wallet/transactions` still returns:

```json
{
  "items": [],
  "total": 0,
  "current_page": 1,
  "last_page": 1
}
```

`GET /v1/referee/earnings` also returns `items: []`.

Endpoint is alive but there is no row to verify the schema. Still needed:
- A populated transaction row (or documented row contract).
- `GET /v1/referee/wallet/transactions/{id}`.
- Withdraw flow.
- Statement download.

Current blocker is test data/schema documentation, not the endpoint itself.

### 2.4 Partner create still requires min/max teams

Retested minimal documented payload:

```json
{
  "tournament_type_id": 1,
  "sport_id": 1,
  "sport_format_id": 1
}
```

Now returns **422**, not 500:

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "minimum_teams": ["The minimum teams field is required when maximum teams is not present."],
    "maximum_teams": ["The maximum teams field is required when minimum teams is not present."]
  }
}
```

Better error handling, but the docs still say these are optional for create. Either:
- update the docs to make them required, or
- add backend defaults (`minimum_teams: 2`, `maximum_teams: 4`).

### 2.5 Bank

No bank row exists on this account, so full-number reveal and re-verify could not be tested.

Still to verify:
- Step-up/re-auth endpoint returning the full account number.
- Re-verify endpoint.
- UPI vs BANK-only decision.

### 2.6 Booking request detail

`GET /v1/referee/bookings/requests` returned `total: 0`, so detail could not be rechecked. The original contract issue remains unverified:
- `booked_by`
- full address
- competition name
- `match_code`

---

## 3. Current verdict

**Backend is now good for:**
- Referee tournament list card
- Referee tournament detail
- Tournament status filters
- Match status filters
- Match venue/location
- Match schedule + local time
- Notifications
- Partner approval fields

**Still needs backend action/confirmation:**
1. `city` and `level` null — populate or confirm removal.
2. `distance_km` / `fee` / `customer_name` null policy for tournament matches.
3. Wallet transaction row schema + transaction detail + withdraw/statement.
4. Partner create min/max teams docs/defaults.
5. Bank full-number/re-verify (needs a bank fixture).
6. Booking detail contract (needs a booking fixture).

**App status:** `flutter analyze` clean, **199 tests passed**, web build OK, local match times now correct.
