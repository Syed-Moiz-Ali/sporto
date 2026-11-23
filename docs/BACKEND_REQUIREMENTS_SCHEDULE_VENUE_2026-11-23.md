# Backend Requirements — Schedule Publish & Venue Coordinates

**Date:** 23 Nov 2026  
**Scope:** only the two backend items that directly affect the current frontend.

**Evidence:** tournament `434` / `M9CRNGVEDB`, matches `4210`–`4212`, referee `12447`.

---

## 1. Schedule publish workflow

### Current behaviour

Partner app already uses:

- `POST /v1/partner/tournaments/{id}/schedule/generate`
- `POST /v1/partner/tournaments/{id}/schedule/publish`
  ```json
  { "version_id": 134 }
  ```

The partner UI has a **Publish schedule** button in:

`apps/partner_app/lib/features/tournaments/presentation/screens/tournament_workflow_screen.dart`

### Observed issue

Generated schedule version:

```json
{
  "id": 134,
  "version_number": 1,
  "status": 2,
  "published_at": null
}
```

At that point:

- `GET /v1/partner/tournaments/434/matches` returned schedules.
- `GET /v1/referee/match-requests` returned `"schedule": null`.

After publishing version 134, referee requests returned the correct schedule and local times.

So the API currently allows **referee assignment before schedule publish**, and silently returns `schedule: null` to the referee.

### Backend required — pick one

**Option A — block assignment until published (preferred)**

`POST /v1/partner/tournaments/{id}/matches/{matchId}/referees` should return:

```http
409 Conflict
```

```json
{
  "success": false,
  "message": "Publish the schedule before assigning referees.",
  "errors": null
}
```

**Option B — auto-publish**

When a schedule is generated for a published tournament, set it live automatically:

```json
{
  "status": 3,
  "published_at": "2026-11-23T06:30:17.000000Z"
}
```

### Also required in match responses

Add explicit schedule state to partner and referee match rows:

```json
{
  "schedule_version_id": 134,
  "schedule_status": 3,
  "schedule_is_published": true,
  "schedule_published_at": "2026-11-23T06:30:17.000000Z"
}
```

This lets the partner app disable/hide **Assign Referee** until publish, and lets the referee app distinguish “no schedule” from “schedule not published”.

### Required in publish response

Current response:

```json
{
  "id": null,
  "version_number": null,
  "status": 3,
  "published_at": "2026-11-23T06:30:17.000000Z"
}
```

Expected:

```json
{
  "id": 134,
  "version_number": 1,
  "status": 3,
  "published_at": "2026-11-23T06:30:17.000000Z"
}
```

### What our frontend will do

**Partner app**
- Keep Generate / Publish schedule buttons.
- Disable **Assign Referee** while `schedule_is_published` is false.
- Show backend 409 message if an assignment is attempted too early.

**Referee app**
- No new API integration needed.
- It will display schedule once the version is published.

### Acceptance checks

```http
POST /schedule/generate → version with published_at=null
GET /referee/match-requests → schedule_is_published=false, schedule=null
POST /matches/{id}/referees → 409 "Publish the schedule..."

POST /schedule/publish → id=134, version_number=1, published_at set
GET /referee/match-requests → schedule populated, schedule_is_published=true
POST /matches/{id}/referees → succeeds
```

---

## 2. Venue coordinates

### Current behaviour

Referee coordinates are saved successfully:

```http
PUT /v1/user/location
{"latitude":17.385044,"longitude":78.486671}
→ 200
```

After that, match `4210` returns:

```json
{
  "distance_km": null,
  "distance_basis": null,
  "distance_unavailable_reason": "VENUE_COORDINATES_NOT_CONFIGURED"
}
```

Creating a tournament venue with coordinates:

```json
{
  "venue_name": "Coord Test Ground",
  "location": "Kukatpally, Hyderabad",
  "latitude": 17.494793,
  "longitude": 78.399635
}
```

returns a venue **without** `latitude` / `longitude`.

Updating a published venue with coordinates returns:

```json
{"message":"Only draft tournaments can be updated."}
```

So there is currently no working way to store venue coordinates through the Partner API.

### Backend required

1. Add `latitude` and `longitude` to Partner tournament venue **create** and **update** payloads.

```json
{
  "venue_name": "SPORTO QA Ground 4",
  "location": "Kukatpally, Hyderabad",
  "ground_type": "Turf",
  "daily_match_capacity": 4,
  "latitude": 17.494793,
  "longitude": 78.399635
}
```

2. Persist and return both fields:

```json
{
  "id": 598,
  "venue_name": "SPORTO QA Ground 4",
  "location": "Kukatpally, Hyderabad",
  "latitude": 17.494793,
  "longitude": 78.399635
}
```

3. Validate:
   - both required together
   - latitude `-90..90`
   - longitude `-180..180`
   - invalid/missing values should return `422` with field errors

4. Allow setting coordinates while the tournament is still draft. Published-tournament restriction can remain.

5. Ensure distance calculation uses the published venue coordinates.

### What our frontend will do

**Partner app**
- Venue latitude / longitude inputs are auto-filled from the map/search location picker.
- Fields remain visible and editable for correction.
- Send both values in create/update venue payload.
- Validate before submit.

**Referee app**
- No new fields needed.
- When `distance_km` is numeric, show it.
- When null, hide/disable using `distance_unavailable_reason`.

### Acceptance checks

```http
PUT /v1/user/location → 200 with saved lat/lng
POST /v1/partner/tournaments/{id}/venues with lat/lng
→ response includes latitude / longitude

GET /v1/referee/matches/{matchId}
→ distance_km is a number
→ distance_basis = "STORED_PROFILE_STRAIGHT_LINE"
→ distance_unavailable_reason = null
```

Failure test:

```http
POST venue with only latitude
→ 422 validation error
```

---

## 3. Not required for these two items

These are intentionally out of scope for this doc:

- Partner tournament detail root-field inconsistencies
- Publish response version fields only (covered above as part of schedule state)
- Referee fee model
- Booking detail contract
- Bank
- Wallet transactions
- Active tournament UI filter

---

## 4. Short backend checklist

- [ ] Block referee assignment until schedule publish, or auto-publish on generate.
- [ ] Add `schedule_is_published` + version metadata to match rows.
- [ ] Return `id` and `version_number` from schedule publish.
- [ ] Accept and persist venue `latitude` / `longitude`.
- [ ] Validate coordinate pairs and return them in venue responses.
- [ ] Use stored venue coordinates in `distance_km`.
