# Referee API Recheck — After Backend Update

**Rechecked:** 19 Nov 2026  
**Test tournament:** `431` / `ZBYV5BTSUU`  
**Referee:** `12447` — Test Partner  
**Assignments:** `2535`, `2536`, `2537` — accepted

---

## Result Summary

| Area | Status |
|---|---|
| Referee tournament list — venue/date/teams/status | ✅ Added |
| Referee tournament list — fee/prize/level/city/earnings | ❌ Still missing |
| Referee tournament detail endpoint | ❌ Still `404` |
| Tournament status filters | ❌ Still ignored |
| Match top-level `venue_name` / `location` | ✅ Fixed |
| Match schedule — date/time/venue | ✅ Present |
| Match local time vs UTC time | ⚠️ Inconsistent |
| Match `distance_km` | ❌ Still `null` |
| Match `fee` / `customer_name` | ❌ Still `null` |
| Result margin / player of match | ⏳ Expected null while upcoming |
| Notification preferences GET + PUT | ✅ Added and working |
| Wallet transaction rows | ❌ Still empty |
| Partner create minimal payload | ❌ Still returns 500 |
| Partner flattened approval fields | ❌ Still null |
| Tournament slug after rename | ❌ Still old slug |
| Bank full number / re-verify | ⚠️ Not testable — no bank row |
| Booking request detail | ⚠️ Not testable — no pending booking |

---

## 1. Referee tournaments — partially fixed

`GET /v1/referee/tournaments?per_page=50`

Tournament `431` now returns:

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
  "start_date": "2026-11-25",
  "end_date": "2026-11-27",
  "timezone": "Asia/Kolkata",
  "venue_name": "SPORTO QA Ground 2",
  "location": "Kukatpally, Hyderabad",
  "city": null,
  "venues": [
    {
      "id": 596,
      "name": "SPORTO QA Ground 2",
      "location": "Kukatpally, Hyderabad"
    }
  ],
  "teams_registered": 4,
  "teams_capacity": 4,
  "fee": null,
  "prize": null,
  "level": null,
  "can_manage": false,
  "earnings": []
}
```

### Fixed
- `status_label`
- `approval_status`
- `approval_status_label`
- `start_date`
- `end_date`
- `timezone`
- `venue_name`
- `location`
- `venues`
- `teams_registered`
- `teams_capacity`

### Still missing
- `fee` is still `null` even though the tournament registration fee is ₹100.
- `prize` is still `null` even though the partner tournament has a ₹1,000 prize.
- `level` is still `null`.
- `city` is still `null` (location is available, so this can be derived or populated).
- `earnings` is `[]`; the Figma tournament card needs a numeric earning value or a documented summary object.

Please add/confirm:

```json
"fee": 100.00,
"prize": 1000.00,
"level": "Local",
"city": "Hyderabad",
"earnings_total": 0.00
```

---

## 2. Referee tournament detail — still missing

```http
GET /api/v1/referee/tournaments/431
→ 404 Not Found
```

Response:

```json
{
  "success": false,
  "message": "Resource not found.",
  "errors": null
}
```

Still required: a detail endpoint or full tournament payload in the list.

---

## 3. Tournament filters — still ignored

Tested:

```http
GET /v1/referee/tournaments?status=active
GET /v1/referee/tournaments?status=completed
GET /v1/referee/tournaments?status=cancelled
GET /v1/referee/tournaments?status=2
GET /v1/referee/tournaments?filter=active
```

Every request returned all 4 tournaments:

```text
431 (Published), 423 (Completed), 422 (Completed), 421 (Published)
```

The filters are not applied. Either implement `status` filtering or document that the client must filter locally.

---

## 4. Referee matches — venue fixed, time contract still inconsistent

`GET /v1/referee/matches` now returns top-level:

```json
"venue_name": "SPORTO QA Ground 2",
"location": "Kukatpally, Hyderabad"
```

This is fixed.

Schedule is present:

```json
"schedule": {
  "date": "2026-11-25",
  "start_time": "05:15",
  "end_time": "06:45",
  "scheduled_start_at": "2026-11-25T05:15:00+00:00",
  "scheduled_end_at": "2026-11-25T06:45:00+00:00",
  "timezone": "Asia/Kolkata",
  "local_date": "2026-11-25",
  "local_start_time": "10:45",
  "local_end_time": "12:15",
  "venue": {
    "id": 596,
    "name": "SPORTO QA Ground 2",
    "location": "Kukatpally, Hyderabad"
  }
}
```

### ⚠️ Time inconsistency
`start_time` / `scheduled_start_at` are UTC (`05:15` +00:00), while the actual local match time is `10:45` (`local_start_time`, Asia/Kolkata).

The app now prefers `local_start_time` / `local_end_time`, so it displays:

```text
Wed, 10:45 AM — 12:15 PM
```

Please either:
1. Make `start_time` / `end_time` local to the tournament timezone, or
2. Document that clients must use `local_start_time` / `local_end_time`.

Do not leave both ambiguous.

### Still null
```json
"distance_km": null,
"fee": null,
"customer_name": null,
"result_margin": null,
"player_of_match": null
```

- `distance_km` — still no real distance/coordinates.
- `fee` / `customer_name` — confirm these are intentionally null for tournament assignments, or add the tournament organiser/fee projection.
- `result_margin` / `player_of_match` — null while upcoming; must populate after completion.

### Match data that is working
- `assignment.id`, `assignment.status = 2`, `role`
- `tournament` name/code/status
- `participants`
- `participants_state`
- `toss`
- `duration_minutes = 90`
- `currency = INR`

### Final match 4206
Still blocked as expected:

```json
"can_officiate": false,
"blocking_code": "PARTICIPANTS_NOT_RESOLVED",
"participants_state": {
  "ready": false,
  "code": "PARTICIPANTS_NOT_RESOLVED"
}
```

This should clear automatically after semi-finals 4204 and 4205 are completed. Confirm.

---

## 5. Notification preferences — fixed

`GET /v1/referee/notification-preferences` now returns categories:

```json
{
  "categories": [
    { "id": "match", "title": "Matches", "description": "...", "is_enabled": false },
    { "id": "tournament", "title": "Tournaments", "description": "...", "is_enabled": false },
    { "id": "team", "title": "Teams", "description": "...", "is_enabled": false },
    { "id": "payments", "title": "Payments", "description": "...", "is_enabled": false },
    { "id": "others", "title": "Others", "description": "...", "is_enabled": false }
  ]
}
```

`PUT /v1/referee/notification-preferences` works with:

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

Response: `Notification preferences updated.`  
Re-fetch confirmed the value persisted. This gap is closed.

---

## 6. Wallet transactions — still empty

`GET /v1/referee/wallet/transactions?per_page=20`

```json
{
  "items": [],
  "total": 0,
  "current_page": 1,
  "last_page": 1
}
```

`GET /v1/referee/earnings?per_page=20`

```json
{
  "items": [],
  "total": 0,
  "total_earned": "0.00",
  "pending_earnings": "0.00",
  "simulated_unfunded_earnings": "0.00",
  "currency": "INR"
}
```

Still needed:
- A populated transaction row so the client contract can be verified.
- Documented row schema: `id`, `reference`, `type`, `category`, `direction`, `amount`, `currency`, `status`, `status_label`, `description`, `tournament`, `match_id`, `match_code`, `booked_by`, `paid_at`, `created_at`, `payment_method`.
- `GET /v1/referee/wallet/transactions/{id}`.
- Withdraw flow.
- Statement download.

Endpoint is alive; data and detail contract are still missing.

---

## 7. Partner create — still 500 without min/max teams

Retested the documented minimal payload:

```json
{
  "tournament_type_id": 1,
  "sport_id": 1,
  "sport_format_id": 1
}
```

Response:

```json
{
  "success": false,
  "message": "Tournament round structure could not be generated. minimum_teams or maximum_teams is required and must be at least 2 for structural generation.",
  "errors": null
}
```

Adding `minimum_teams` and `maximum_teams` still fixes it. Either update the documentation or add defaults (for example `2` / `4`).

---

## 8. Partner approval fields — still inconsistent

`GET /v1/partner/tournaments/431` still returns:

```json
"approval_status": null,
"submitted_at": null,
"approved_at": null,
"approved_by": null,
"approval": {
  "status": 4,
  "submitted_at": "2026-11-19T16:21:45.000000Z",
  "approved_at": "2026-11-19T16:22:16.000000Z",
  "approved_by": { "id": 1, "name": "Administrator" }
}
```

Please flatten:

```json
"approval_status": 4,
"submitted_at": "2026-11-19T16:21:45.000000Z",
"approved_at": "2026-11-19T16:22:16.000000Z",
"approved_by": { "id": 1, "name": "Administrator" }
```

Also `total_prize_money` is still `null` while `prizes[0].amount = 1000`. Please populate it.

---

## 9. Tournament slug — still stale

Tournament 431 was renamed from `Draft Tournament` to `SPORTO Referee Submit QA 2026-11-19`, but it still returns:

```json
"slug": "draft-fhxel4jo4a"
```

Regenerate on name change, or confirm slug is immutable by design.

---

## 10. Not testable in this account

### Bank
No bank row exists, so full-number reveal and re-verify could not be tested. The original request remains:
- Step-up endpoint for full account number.
- Re-verify endpoint.
- UPI/BANK-only confirmation.

### Booking detail
`GET /v1/referee/bookings/requests` returned `total: 0`, so `GET /bookings/requests/{assignment_id}` could not be rechecked. The expected missing fields remain `booked_by`, full address, competition name and `match_code`.

---

## 11. Verified working

- Partner auth
- Tournament create/update/budget/venue/submit
- Admin approval
- Team registration
- Schedule generation
- Partner referee assignment
- Referee availability slot creation
- Referee assignment acceptance
- Referee matches include tournament 431
- Match schedule + nested venue
- Match top-level venue/location (fixed)
- Referee stats/profile/availability
- Notification preferences GET/PUT (fixed)
- Bank CRUD per earlier runs

---

## 12. Still required from backend — shortest list

1. Referee tournament list: `fee`, `prize`, `level`, `city`, numeric `earnings` / `earnings_total`.
2. Referee tournament detail: `GET /v1/referee/tournaments/{id}` → currently 404.
3. Tournament filters: apply `status=active|completed|cancelled`.
4. Match time contract: make `start_time` local, or document `local_start_time` as required.
5. Confirm `distance_km`, `fee`, `customer_name` null policy for tournament matches.
6. Wallet transaction rows + row schema + transaction detail + withdraw/statement.
7. Partner create: make min/max teams optional with defaults, or fix docs.
8. Partner approval: flatten `approval_status` / timestamps / approver, and populate `total_prize_money`.
9. Partner slug: regenerate after rename or document immutability.
10. Bank step-up/re-verify, and booking-detail contract once a booking exists.
