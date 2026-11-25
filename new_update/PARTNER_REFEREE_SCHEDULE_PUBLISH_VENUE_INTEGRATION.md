# SPORTO — Partner & Referee frontend integration

**Date:** 24 November 2026  
**Scope:** Explicit schedule publication and venue coordinates only.  
**Source:** Backend PR #111, `spvn81/sporto-backend`; repository guide `docs/PARTNER_REFEREE_SCHEDULE_PUBLISH_VENUE_INTEGRATION.md`.

Use the existing authenticated role's Bearer token and `Content-Type: application/json`. All URLs below include the actual `/api/v1` prefix. IDs and coordinates are examples, not a production data update.

## 1. Partner venue form

```http
POST /api/v1/partner/tournaments/{id}/venues
PUT /api/v1/partner/tournaments/{id}/venues/{venueId}
```

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

HTTP 200 returns `data.id`, `data.venue_name`, `data.location`, `data.latitude`, `data.longitude` and the existing fields. Direct venue endpoint coordinates are JSON numbers when set and null when unset. The same validation applies to nested `venues[]` in tournament create/update; Eloquent decimal serialization may represent nested coordinates as strings.

- Map/search picker should fill both coordinates. Allow manual corrections.
- Latitude must be a finite number between -90 and 90 inclusive. Longitude must be a finite number between -180 and 180 inclusive. Zero is valid.
- When supplied, both must be present. Explicit null, a missing counterpart, or invalid range returns HTTP 422 with field errors.
- Omitting both remains supported for old clients. On an update, omitting both preserves existing coordinates.
- Existing ownership, draft and approval edit restrictions remain. Non-editable tournaments return 422. Do not reopen or invent coordinates for published tournaments.
- No new migration is required; coordinate columns already exist.

Dart validation example:

```dart
final latitude = double.tryParse(latitudeController.text.trim());
final longitude = double.tryParse(longitudeController.text.trim());
final valid = latitude != null && longitude != null &&
    latitude.isFinite && longitude.isFinite &&
    latitude >= -90 && latitude <= 90 &&
    longitude >= -180 && longitude <= 180;
// Show field errors if invalid. Send both numeric values when valid.
```

## 2. Schedule workflow (Partner)

Keep existing Generate and Publish buttons. Do not automatically publish generated schedules.

```http
POST /api/v1/partner/tournaments/{id}/schedule/generate
```

```json
{}
```

Read `data.schedule.version_id` (existing key), `id`, `version_number`, `status`, `published_at`. Generated status is 2 and `published_at` is null. Preserve existing overwrite confirmation/error handling.

```http
GET /api/v1/partner/tournaments/{id}/schedule
GET /api/v1/partner/tournaments/{id}/matches
GET /api/v1/partner/tournaments/{id}/matches/{matchId}
GET /api/v1/partner/tournaments/{id}/matches/cards
GET /api/v1/partner/tournaments/{id}/matches/{matchId}/card
```

The four additional top-level match-row fields are available at `data[]` (list), `data` (detail), `data.cards[]` (cards), and `data.card` (single card).

```json
{
  "schedule_version_id": 134,
  "schedule_status": 2,
  "schedule_is_published": false,
  "schedule_published_at": null
}
```

The Partner can see unpublished preview timings. Do not infer publication from a non-null schedule.

```http
POST /api/v1/partner/tournaments/{id}/schedule/publish
```

```json
{"version_id":134}
```

HTTP 200 example:

```json
{
  "success": true,
  "message": "Schedule published successfully.",
  "data": {
    "id": 134,
    "version_id": 134,
    "version_number": 1,
    "status": 3,
    "published_at": "2026-11-23T06:30:17.000000Z"
  }
}
```

The `version_id` alias is preserved. Refresh schedule and match rows after successful publication. Published assignments take precedence over unpublished previews. Cancelled or superseded assignments do not count as published. No active version assignment returns null ID, status and timestamp, and false.

```json
{
  "schedule_version_id": 134,
  "schedule_status": 3,
  "schedule_is_published": true,
  "schedule_published_at": "2026-11-23T06:30:17.000000Z"
}
```

## 3. Assign referee

```http
POST /api/v1/partner/tournaments/{id}/matches/{matchId}/referees
```

```json
{"referee_id":12447,"role":"main"}
```

No published assignment for that match: HTTP 409.

```json
{
  "success": false,
  "message": "Publish the schedule before assigning referees.",
  "errors": null
}
```

After publication, eligible assignment uses the existing HTTP 201 response and `data.id` assignment identifier. Existing working-hours, overlap, eligibility, ownership and duplicate checks remain. Display the backend error message, rather than automatically retrying. Direct Partner assignment is gated; independent booking and admin workflows are unchanged.

Flutter button logic:

```dart
final canAssignReferee = match.scheduleIsPublished == true;
// Combine with existing permission, eligibility and in-progress guards.
```

## 4. Referee app — no new endpoints

```http
GET /api/v1/referee/match-requests
GET /api/v1/referee/matches
GET /api/v1/referee/matches/{matchId}
GET /api/v1/referee/dashboard
PUT /api/v1/user/location
```

Read match/request rows from `data.items[]`, detail from `data`; dashboard uses the same formatter. Existing legacy invitations remain visible. No active assignment version returns null/null/false/null. A generated but unpublished version exposes its ID/status and false, with tournament schedule null. Once published, the existing schedule object contains `local_date`, `local_start_time`, `local_end_time`, `timezone`, and UTC timestamps.

Save the referee account coordinates using the existing location API:

```json
{"latitude":17.385044,"longitude":78.486671}
```

When the published match venue has valid coordinates, the existing `distance_km` is numeric, `distance_basis` is `STORED_PROFILE_STRAIGHT_LINE`, and `distance_unavailable_reason` is null. Otherwise hide the distance or display its unavailable state. This is straight-line distance from the saved account location, not road distance or live GPS. Existing independent booking-location fallback remains unchanged; unpublished tournament timings and venue coordinates are not exposed as published match data.

```dart
final scheduleVersionId = json['schedule_version_id'] as int?;
final scheduleStatus = json['schedule_status'] as int?;
final scheduleIsPublished = json['schedule_is_published'] == true;
final schedulePublishedAt = DateTime.tryParse(
  json['schedule_published_at']?.toString() ?? '',
);
final distanceKm = (json['distance_km'] as num?)?.toDouble();
final distanceLabel = distanceKm == null
    ? null
    : '${distanceKm.toStringAsFixed(1)} km';
```

## 5. Frontend acceptance checklist

- [ ] `apps/partner_app/lib/features/tournaments/presentation/screens/tournament_workflow_screen.dart`: preserve Generate/Publish; store version ID; refresh on publish; disable Assign Referee until row publication flag is true; handle 409.
- [ ] Editable Partner venue form: map selection and editable coordinate fields; validate both finite numbers, pair and ranges; parse saved coordinate values.
- [ ] Draft venue creation and update return persisted coordinates; sending only latitude returns 422.
- [ ] Generate returns status 2 and null publication date; pre-publication assignment returns 409 and creates no record.
- [ ] Publish returns real ID, version number, status 3 and timestamp; match rows are refreshed.
- [ ] Eligible referee can be assigned after publication (201).
- [ ] Referee app parses metadata and displays published local date/time without adding new APIs.
- [ ] Referee distance is numeric when saved profile and published venue coordinates exist; null reason is handled without hardcoded distance.
- [ ] Existing published venue edit restrictions and independent booking flows remain intact.

## 6. Rollout and QA notes

Test on an editable QA tournament. Existing published tournament 434 / M9CRNGVEDB and matches 4210–4212 are not automatically backfilled by this change. Real coordinates must already be stored, or be corrected through an authorized workflow. No live production data update is performed by this patch.

Regression coverage: `tests/Feature/Partner/Tournament/PartnerSchedulePublishVenueCoordinatesTest.php`; existing assignment lifecycle fixtures updated to include published schedules and valid availability. Postman collections updated under `postman/Partner/` and `postman/Referee/`.

GitHub PR: https://github.com/spvn81/sporto-backend/pull/111
