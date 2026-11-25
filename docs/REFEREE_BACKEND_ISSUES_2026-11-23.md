# Referee Backend Issues — 23 Nov 2026

> **Update 25 Nov 2026:** schedule publication metadata, venue coordinate persistence and the dedicated referee location endpoint are implemented in backend PR #111. See `docs/BACKEND_PR111_RECHECK_2026-11-25.md` for live verification. This file remains as the original issue report.

**Context:** tournament `434` / `M9CRNGVEDB`, matches `4210`–`4212`, referee `12447`  
**Scope:** backend/API issues only. UX/UI issues are excluded and will be handled separately.

---

## P0 — Schedule must be published separately

### Observed
`GET /v1/partner/tournaments/434/schedule` returned:

```json
{
  "id": 134,
  "version_number": 1,
  "status": 2,
  "published_at": null
}
```

`GET /v1/partner/tournaments/434/matches` returned match schedules, but:

`GET /v1/referee/match-requests` returned:

```json
"schedule": null
```

After calling:

```http
POST /v1/partner/tournaments/434/schedule/publish
{"version_id":134}
```

the referee match requests started returning the correct schedule and local times.

### Issue
- Match assignment is allowed before the schedule version is published.
- Partner match list shows the draft schedule, but referee match-requests return `schedule: null`.
- The API does not expose an obvious `is_published` flag on assigned matches; the client has to know that schedule publishing is a separate step.

### Expected
One of:
1. Automatically publish the schedule when it is generated for a published tournament, or
2. Block referee assignment until the schedule version is published, or
3. Return an explicit blocking/error state instead of silently returning `schedule: null`.

If manual publishing is intentional, document it clearly and expose `schedule_version_status` / `schedule_published_at` on referee match rows.

---

## P0 — Venue coordinates are not persisted by the Partner venue API

### How the Partner app supplies coordinates

The Partner does **not** normally type coordinates manually.

When the Partner selects the venue through the map/search picker:

```text
Location picker → VenueLocationSelection(address, latitude, longitude)
```

the Partner app auto-fills **Latitude** and **Longitude** from the selected location.
Both fields remain visible/editable for correction, but the normal source is the selected map location.

The create/update payload now includes:

```json
{
  "venue_name": "SPORTO QA Ground 4",
  "location": "Kukatpally, Hyderabad",
  "latitude": 17.494793,
  "longitude": 78.399635
}
```

### Observed
Referee profile coordinates were set successfully:

```http
PUT /v1/user/location
{"latitude":17.385044,"longitude":78.486671}
```

After that, `GET /v1/referee/matches/4210` returned:

```json
{
  "distance_km": null,
  "distance_basis": null,
  "distance_unavailable_reason": "VENUE_COORDINATES_NOT_CONFIGURED"
}
```

A draft tournament venue was created with:

```json
{
  "venue_name": "Coord Test Ground",
  "location": "Kukatpally, Hyderabad",
  "latitude": 17.494793,
  "longitude": 78.399635
}
```

The response omitted both coordinate fields:

```json
{
  "id": 599,
  "venue_name": "Coord Test Ground",
  "location": "Kukatpally, Hyderabad",
  "ground_type": "Turf"
}
```

The venue arrived without coordinates, so distance remains unavailable.

### Issue
- The Partner venue create/update payload does not persist `latitude` / `longitude`.
- Published tournaments cannot be updated to add coordinates:

```http
PUT /v1/partner/tournaments/434/venues/598
→ 422 {"message":"Only draft tournaments can be updated."}
```

### Expected
- Persist `latitude` / `longitude` from the Partner tournament venue create/update payload.
- Return both fields in the venue response so edits reload correctly.
- Validate that both are present together and within valid bounds.
- Use the persisted venue coordinates when calculating `distance_km` from the referee profile coordinates.
- Or document the actual admin-only path for venue coordinates.
- Without this, `distance_km` can never be produced for these tournaments even when referee coordinates exist.

---

## P1 — Partner tournament detail is inconsistent with nested data

`GET /v1/partner/tournaments/434` returns:

```json
{
  "registered_teams": null,
  "venue_name": null,
  "location": null,
  "city_source": null,
  "registration_summary": {
    "registered_teams": 4,
    "maximum_teams": 4
  },
  "venues": [
    {
      "id": 598,
      "venue_name": "SPORTO QA Ground 4",
      "location": "Kukatpally, Hyderabad"
    }
  ]
}
```

The same fields are correct in the referee response:

```json
{
  "city": "Hyderabad",
  "city_source": "TOURNAMENT",
  "teams_registered": 4,
  "teams_capacity": 4,
  "venue_name": "SPORTO QA Ground 4",
  "location": "Kukatpally, Hyderabad"
}
```

### Issue
- Root `registered_teams`, `venue_name`, `location`, and `city_source` are null on partner detail while nested data contains the values.
- Consumers reading the root fields get empty values.

### Expected
Populate the root fields consistently on partner detail/list, or remove them and document `registration_summary` / `venues` as the only source.

---

## P1 — Schedule publish response omits id and version number

`POST /v1/partner/tournaments/434/schedule/publish` succeeded, but returned:

```json
{
  "id": null,
  "version_number": null,
  "status": 3,
  "published_at": "2026-11-23T06:30:17.000000Z"
}
```

### Expected
Return the published version:

```json
{
  "id": 134,
  "version_number": 1,
  "status": 3,
  "published_at": "2026-11-23T06:30:17.000000Z"
}
```

This is needed for client state updates and confirming which version was published.

---

## P1 — Referee fee is not modeled

Tournament response:

```json
{
  "referee_fee": null,
  "referee_fee_unavailable_reason": "TOURNAMENT_REFEREE_FEE_NOT_SUPPORTED"
}
```

Match response:

```json
{
  "fee": null,
  "fee_unavailable_reason": "NO_REFEREE_FEE_AGREEMENT"
}
```

### Decision required
- If referees should see an expected fee for tournament matches, add a real tournament referee-fee model.
- If not supported, keep the explicit reason and remove the field from UI expectations.

This is a product/data-model decision, not a missing serializer field.

---

## Confirmed working — no backend issue

- `city` and `level` persist and return from the referee API (`city_source: "TOURNAMENT"`).
- `customer_name` returns `"Test Partner"` with `customer_name_source: "TOURNAMENT_PARTNER"`.
- Local time fields (`local_start_time`, `local_end_time`) are present and correct.
- Match list/detail/request projections are consistent for customer/fee/distance reasons.
- Tournament assignment and acceptance APIs work.
- Referee tournament list/detail works after at least one assignment is accepted.
- Notification preferences GET/PUT works.

---

## Backend action list

1. Publish schedules automatically, or block referee assignment until schedule publish.
2. Add working venue coordinate storage to Partner create/update and return it.
3. Populate or remove inconsistent root fields on partner tournament detail.
4. Return `id` and `version_number` from schedule publish.
5. Decide whether `referee_fee` needs a real model.
