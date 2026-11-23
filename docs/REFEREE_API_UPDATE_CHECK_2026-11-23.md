# Referee API Update Check — 23 Nov 2026

**Checked endpoints:**

- `GET /v1/referee/tournaments`
- `GET /v1/referee/tournaments/433`
- `GET /v1/referee/matches`
- `GET /v1/referee/matches/4208`
- `GET /v1/referee/match-requests`

The API update described in `new_update/2026-11-22-referee-display-metadata.md` is live.

---

## What changed

The six previously missing display fields now have explicit values **or explicit unavailable reasons**.

### Tournament fields

`GET /v1/referee/tournaments/433`:

```json
{
  "city": null,
  "city_source": null,
  "city_unavailable_reason": "CITY_NOT_CONFIGURED",
  "level": null,
  "level_unavailable_reason": "LEVEL_NOT_CONFIGURED",
  "referee_fee": null,
  "referee_fee_unavailable_reason": "TOURNAMENT_REFEREE_FEE_NOT_SUPPORTED"
}
```

Same fields appear in `GET /v1/referee/tournaments` rows.

### Match fields

`GET /v1/referee/matches/4208`:

```json
{
  "customer_name": "Test Partner",
  "customer_name_source": "TOURNAMENT_PARTNER",
  "customer_name_unavailable_reason": null,
  "fee": null,
  "fee_source": null,
  "fee_unavailable_reason": "NO_REFEREE_FEE_AGREEMENT",
  "distance_km": null,
  "distance_basis": null,
  "distance_unavailable_reason": "REFEREE_COORDINATES_NOT_CONFIGURED"
}
```

Same fields appear in:

- `GET /v1/referee/matches`
- `GET /v1/referee/matches/{matchId}`
- `GET /v1/referee/match-requests`

`customer_name` is now real: `"Test Partner"` from `TOURNAMENT_PARTNER`.
No more `Rahul Kumar` fallback is needed.

---

## Is anything still missing?

**No API keys are missing now.**

The remaining nulls are explicit data/configuration states, not missing API fields:

| Field | Current reason | Action |
|---|---|---|
| `city` | `CITY_NOT_CONFIGURED` | Configure city before publish via Partner/Admin |
| `level` | `LEVEL_NOT_CONFIGURED` | Configure level before publish via Partner/Admin |
| `referee_fee` | `TOURNAMENT_REFEREE_FEE_NOT_SUPPORTED` | Confirm this is permanent; no fee model exists |
| `fee` | `NO_REFEREE_FEE_AGREEMENT` | Expected for this tournament assignment |
| `distance_km` | `REFEREE_COORDINATES_NOT_CONFIGURED` | Save referee coordinates via `PUT /v1/user/location`; venue coordinates also required |

### Important for tournament 433

Trying to set `city` / `level` after publishing returns:

```http
PUT /v1/partner/tournaments/433
{"city":"Hyderabad","level":"Local"}

→ 422
{"message":"Only draft tournaments can be updated."}
```

So for future tournaments, set `city` and `level` **before submitting/publishing**. Existing published tournament 433 cannot be edited with the partner update endpoint.

---

## Frontend impact

The new backend contract explicitly says:

> Remove static `Rahul Kumar`, `₹1500` and `8.4 km` fallbacks.

Current app behavior:

- `customer_name` can now use `"Test Partner"` from the API.
- `fee` is null → should show unavailable, not static `₹1500`.
- `distance_km` is null → should show unavailable/“not configured”, not static `8.4 km`.
- `city`/`level` null → should use unavailable reasons, not fake values.

Frontend integration is still pending for these new fields.

---

## Attached backend files — meaning

1. **`2026-11-22-referee-display-metadata.md`**
   Backend contract for six display fields:
   - tournament `city`, `level`, `referee_fee`
   - match `customer_name`, `fee`, `distance_km`
   - Adds source fields and `*_unavailable_reason` fields.
   - Explains configuration:
     - city/level via Partner update on a draft tournament
     - referee coordinates via `PUT /v1/user/location`

2. **`REFEREE_FRONTEND_INTEGRATION_GUIDE.md`**
   Consumer rules:
   - Remove static fallbacks.
   - Null means unavailable, not zero.
   - Read `*_source` / `*_unavailable_reason`.
   - Fee is a frozen booking fee, not tournament prize/registration fee.
   - Distance is stored-profile straight-line, not road distance/live GPS.
   - Result margin and player-of-match remain nullable until completed/awarded.

---

## Live verification — tournament 434

Created `434` / `M9CRNGVEDB` with `city: "Hyderabad"` and `level: "Local"` before submission.

After approval, team registration and match generation:

```json
{
  "id": 434,
  "status": 2,
  "status_label": "Published",
  "approval_status": 4,
  "city": "Hyderabad",
  "city_source": "TOURNAMENT",
  "city_unavailable_reason": null,
  "level": "Local",
  "level_unavailable_reason": null,
  "teams_registered": 4,
  "teams_capacity": 4,
  "fee": "100.00",
  "prize": "1000.00",
  "earnings_total": "0.00"
}
```

### Match response for 4210

```json
{
  "customer_name": "Test Partner",
  "customer_name_source": "TOURNAMENT_PARTNER",
  "customer_name_unavailable_reason": null,
  "fee": null,
  "fee_source": null,
  "fee_unavailable_reason": "NO_REFEREE_FEE_AGREEMENT",
  "distance_km": null,
  "distance_basis": null,
  "distance_unavailable_reason": "REFEREE_COORDINATES_NOT_CONFIGURED",
  "currency": "INR"
}
```

### Important schedule finding

`GET /v1/partner/tournaments/434/matches` returned schedules, but
`GET /v1/referee/match-requests` returned `schedule: null` until the schedule
version was published.

The generated schedule version was:

```json
{
  "id": 134,
  "version_number": 1,
  "status": 2,
  "published_at": null
}
```

After:

```http
POST /v1/partner/tournaments/434/schedule/publish
{"version_id":134}
```

the referee match-request schedule populated correctly with local times:

```json
{
  "local_date": "2026-12-01",
  "local_start_time": "09:00",
  "local_end_time": "10:30",
  "venue": {
    "name": "SPORTO QA Ground 4",
    "location": "Kukatpally, Hyderabad"
  }
}
```

So generating a schedule is not enough — the schedule version must also be
published before referees can see match dates/times/venues.

### Frontend verification

- Static `Rahul Kumar`, `₹1500`, and `8.4 km` fallbacks removed.
- Home request cards now render `Test Partner` and real schedule/venue.
- Fee and distance are hidden when API returns null.
- Tournament cards use real venue/date/teams/level/earnings.
- `flutter analyze` clean, 199 tests passed, web build OK.

### Remaining data/config states

- `referee_fee` is unsupported by the model.
- `fee` is null because no frozen booking fee agreement exists.
- `distance_km` is null because referee profile coordinates are not configured;
  venue coordinates are also required for a successful distance.
- Active tournament 434 is visible in the referee API only after at least one
  assignment is accepted. The current My Tournaments screen only shows
  Completed/Cancelled, so active tournaments are still a frontend gap.

---

## Verdict

- Backend update is **live and matches the attached contract**.
- City/level and customer name are now working with real data.
- No missing API keys remain for these six fields.
- Schedule publishing is a separate required step for match-request visibility.
- Remaining work is:
  1. Configure referee and venue coordinates if real distance is required.
  2. Decide whether referee fee should remain unsupported or become a real model.
  3. Add an Active filter to the app's My Tournaments screen.
