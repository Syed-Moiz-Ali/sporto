# Backend PR #111 Recheck — 25 Nov 2026

**Reviewed docs:**

- `new_update/PARTNER_REFEREE_SCHEDULE_PUBLISH_VENUE_INTEGRATION.md`
- `new_update/SPORTO_Partner_Referee_Integration_Guide_Updated.md`

**Live checks:** partner + referee API with tournament `434` and new draft `436`.

---

## 1. Schedule metadata — working

`GET /v1/partner/tournaments/434/matches` now returns:

```json
{
  "schedule_version_id": 134,
  "schedule_status": 3,
  "schedule_is_published": true,
  "schedule_published_at": "2026-11-23T06:30:17.000000Z"
}
```

Same four fields are present on:

- referee `/matches`
- referee `/matches/{matchId}`
- referee `/match-requests`
- partner match cards (per contract)

`GET /v1/partner/tournaments/434/schedule` also exposes `published_at`.

Publishing an already-published version returns:

```json
{"message":"Schedule version is already published."}
```

This is acceptable; the earlier missing ID/version response cannot be retested on 434 because it is already published.

**Not live-tested:** pre-publish assignment `409`. No approved tournament with an unpublished schedule was available without admin approval. Backend contract and our 409 handling are in place.

---

## 2. Partner venue coordinates — working

Created draft tournament `436` / `OLVUP16KG5` and venue `600`.

`POST /v1/partner/tournaments/436/venues` returned coordinates:

```json
{
  "id": 600,
  "venue_name": "SPORTO QA Ground 5",
  "location": "Kukatpally, Hyderabad",
  "latitude": 17.494793,
  "longitude": 78.399635
}
```

`PUT /v1/partner/tournaments/436/venues/600` persisted updated coordinates:

```json
{
  "id": 600,
  "latitude": 17.4948,
  "longitude": 78.3997
}
```

Validation verified — sending only latitude returns:

```json
{
  "status": 422,
  "errors": {
    "longitude": ["The longitude field is required when latitude is present."]
  }
}
```

**Frontend matches this contract:** map selection auto-fills both fields, fields are editable, validation checks pair/finite/range, and payload sends numeric values. `PlannedTournamentVenue` parses numeric or string values.

---

## 3. Referee location endpoint — working

`PUT /v1/referee/location` with referee token:

```json
{"latitude":17.385044,"longitude":78.486671}
```

returned:

```json
{
  "message": "Location updated successfully.",
  "data": {
    "profile": {
      "user_id": 12447,
      "latitude": "17.38504400",
      "longitude": "78.48667100"
    }
  }
}
```

The dedicated Referee route works. The User route is separate as documented.

**Frontend note:** the Referee app currently has no location-save screen/call. The endpoint is verified, but the referee must have coordinates stored for distance to become available.

---

## 4. Distance status

Tournament 434 is intentionally not backfilled. Venue `598` still has no coordinates:

```json
{
  "distance_km": null,
  "distance_basis": null,
  "distance_unavailable_reason": "VENUE_COORDINATES_NOT_CONFIGURED"
}
```

Draft `436` has real venue coordinates, but cannot produce a published-match distance until approved and scheduled.

Distance calculation is ready backend-side when:
1. referee profile coordinates are saved through `PUT /v1/referee/location`, and
2. the published match venue has coordinates.

---

## 5. Frontend status

- Partner venue form: coordinates implemented, auto-filled from map, editable, validated, sent on create/update.
- Partner schedule: still manual Generate → Publish; publish state parsed from `published_at` / `schedule_is_published`.
- Assign Referee: hidden in tournament detail until schedule is published; 409 message is surfaced if attempted early.
- Referee schedule: local times parsed from `local_start_time` / `local_end_time`.
- Referee distance: numeric value shown when present; null is hidden.
- Referee location save UI: not implemented yet.

---

## 6. Verdict

Backend PR #111 is live and matches the new docs for:

- venue coordinate persistence and validation
- schedule publication metadata on match rows
- dedicated referee location endpoint

Remaining action is frontend-side only:

- add a referee location-save action using `PUT /v1/referee/location`
- use `schedule_is_published` from match rows where a match-row-based Assign button exists outside tournament detail
- no new backend field is currently required for these flows
