# Backend API Integration Report

Date: 2026-08-14
Base URL used: `https://app.spotoapp.in/api`
Postman source: `postman/`

## Summary

All 30 Postman requests were executed against the live backend using the request bodies from the Postman collections.

Result counts:

- `200`: 1 endpoint
- `400`: 1 endpoint
- `401`: 28 endpoints

Raw unauthenticated execution proof is stored in `docs/api-live-sweep.json`.
Raw authenticated execution proof is stored in `docs/api-authenticated-sweep.json`.
Safe authenticated recheck proof is stored in `docs/api-authenticated-recheck.json`.
Full stateful API proof is stored in `docs/api-full-stateful-check.json`.
Affected endpoint recheck proof is stored in `docs/api-affected-recheck.json`.
Common upload proof is stored in `docs/api-upload-check.json`.

## Confirmed Working

### Partner Send OTP

`POST /v1/partner/send-otp`

Request body:

```json
{
  "mobile_number": "9876543210"
}
```

Response:

```json
{
  "success": true,
  "message": "OTP sent successfully.",
  "data": {
    "session_key": "a29366b2-50ef-4370-a3ec-fd377fc6ce68",
    "provider_response": {
      "Status": "Success",
      "Details": "a29366b2-50ef-4370-a3ec-fd377fc6ce68"
    }
  }
}
```

Freezed response models were created only for this confirmed response shape.

### Partner Verify OTP

The user provided a real successful Verify OTP response. Token was redacted in repo files.

Confirmed response shape:

```json
{
  "success": true,
  "message": "Logged in successfully.",
  "data": {
    "token": "<redacted>",
    "is_new_user": true,
    "user": {
      "id": 5,
      "mobile_number": "<redacted_mobile>",
      "status": 1,
      "profile": {
        "id": 4,
        "user_id": 5,
        "full_name": null,
        "email": null,
        "date_of_birth": null,
        "gender": null,
        "city": null,
        "state": null,
        "country": null,
        "profile_photo_path": null,
        "created_at": "2026-08-14T12:01:32.000000Z",
        "updated_at": "2026-08-14T12:01:32.000000Z"
      }
    }
  }
}
```

### Authenticated Partner APIs Returning 200

These endpoints returned real authenticated payloads and now have typed response models:

- `GET /v1/partner/profile`
- `PUT /v1/partner/profile`
- `GET /v1/partner/sports/available`
- `GET /v1/partner/sports`
- `POST /v1/partner/sports`
- `GET /v1/partner/documents`
- `POST /v1/partner/documents`
- `DELETE /v1/partner/documents/1`
- `GET /v1/partner/application`
- `POST /v1/partner/submit`
- `GET /v1/partner/tournaments/types`
- `GET /v1/partner/tournaments/sports`
- `GET /v1/partner/tournaments/sports/1/formats`
- `GET /v1/partner/tournaments/form-config?sport_id=1&sport_format_id=1`

Typed models are in `packages/partner_data/lib/src/models/partner_api_response_models.dart`.

### Common Upload API

`POST /v1/common/upload`

Multipart form-data:

- `file`: selected file
- `folder`: `users/profile` or `users/documents`

Tested with an existing PNG file and bearer token. Response:

```json
{
  "success": true,
  "message": "File uploaded successfully.",
  "data": {
    "path": "users/profile/903ef7f6-62a8-46c2-9a5e-acbb9c74b179.png",
    "url": "https://pub-c94d45e28dfa4bf08b2cd5d22adb73e6.r2.dev/users/profile/903ef7f6-62a8-46c2-9a5e-acbb9c74b179.png"
  }
}
```

Typed model: `UploadFileResponseData` in `packages/core/lib/src/network/models/sporto_api_response.dart`.

## Authenticated Backend Findings

Latest full stateful run result counts:

- `200`: 17 endpoints
- `400`: 1 endpoint
- `403`: 1 endpoint
- `404`: 6 endpoints
- `422`: 4 endpoints

Affected endpoint recheck after correcting request bodies:

- `POST /v1/partner/submit`: `200 Application submitted successfully`
- `POST /v1/partner/tournaments/1/venues`: `404 Resource not found`
- `PUT /v1/partner/tournaments/1/budget`: `404 Resource not found`
- `POST /v1/partner/tournaments/1/submit`: `404 Resource not found`

Important backend/data-state blockers:

- Recheck confirmed `GET /v1/partner/profile` is now working after profile data exists. Earlier `404 Partner profile not found` was state-related before the successful `PUT /v1/partner/profile`.
- `POST /v1/partner/profile` works with a unique valid email. It previously returned `500` only when Postman reused duplicate email `john.partner@example.com`; backend should return a `422` validation error instead of exposing SQL exception details for duplicate email.
- `POST /v1/partner/submit` works after a government ID document is present. Earlier failure was caused by removing the same `government_id` record that the backend reused/upserted.
- Adding `government_id` twice returned the same/active document record behavior in testing; deleting the second test document removed the government ID needed for submission. Backend should confirm whether document type is one-record-per-type and whether duplicate add is an upsert.
- `POST /v1/partner/tournaments/` returned `403 No organization associated with this user`.
- Tournament draft/detail/rules/review/delete endpoints using Postman `tournament_id = 1` returned `404 Resource not found`.
- Venue, budget, and tournament submit bodies were corrected from backend validation feedback, but still return `404 Resource not found` because tournament `1` is unavailable for this authenticated user.

## Tournament Recheck - 2026-08-15

Backend provided a fresh token and reported the organization/tournament access issues as fixed. Recheck was performed against real created draft tournament IDs instead of hardcoded Postman tournament `1`.

Confirmed working:

- `GET /v1/partner/tournaments/types`: `200`
- `POST /v1/partner/tournaments/`: `200 Draft created successfully` with created tournament `id = 7`
- `GET /v1/partner/tournaments/7`: `200 Tournament retrieved`
- `PUT /v1/partner/tournaments/7`: `200 Tournament details updated`
- `PUT /v1/partner/tournaments/7/rules`: `200 Tournament rules updated`
- `POST /v1/partner/tournaments/7/venues`: `200 Venue added successfully`
- `PUT /v1/partner/tournaments/8/venues/2`: `200 Venue updated successfully`
- `DELETE /v1/partner/tournaments/8/venues/2`: `200 Venue removed successfully`
- `PUT /v1/partner/tournaments/7/budget`: `200 Budget and registration updated successfully`
- `GET /v1/partner/tournaments/7/review`: `200 Review data retrieved`
- `POST /v1/partner/tournaments/7/submit`: `200 Tournament submitted successfully`
- `DELETE /v1/partner/tournaments/8`: `200 Tournament draft deleted successfully`

Important request contract observed from live backend:

- Tournament mutation endpoints did not accept JSON request bodies during recheck. JSON body returned validation errors saying required fields were missing.
- The same fields worked when sent as multipart/form-data.
- `PUT` mutation endpoints worked reliably when sent as multipart/form-data with `_method=PUT`.
- `POST /v1/partner/tournaments/{id}/submit` accepted `confirmation=1`. Form value `confirmation=true` returned `422` saying the field must be true or false.
- Venue create/update still require `venue_name`; `venue_id` alone is not enough.
- Budget still requires `prizes[0][category]` and `sponsors[0][sponsor_type]`.
- Duplicate profile email issue is still not fixed: `POST /v1/partner/profile` with `john.partner@example.com` returned `500 Internal Server Error` with SQL unique-key details. Expected response remains `422 Validation failed`.

Frontend integration updated accordingly:

- Tournament mutations now use centralized form-data helper in `SportoApiClient.postForm`.
- Partner tournament datasource sends create/update/rules/venue/budget/submit using form-data and `_method=PUT` where required.
- Added typed tournament response models and status workflow mapping:
  `1 Draft`, `2 Published`, `3 Registration Open`, `4 Registration Closed`, `5 Check In`, `6 In Progress`, `7 Completed`, `8 Cancelled`, `9 Archived`.

## Tournament Creation QA Validation Sweep - 2026-08-15

Scope: tournament create/update/rules/venue/budget/review/submit was retested as a QA flow with both negative validation cases and a full happy path using a real authenticated partner token.

Passing validation/backhandling checks:

- `GET /v1/partner/tournaments/types`: `200 Tournament types retrieved.`
- `GET /v1/partner/tournaments/sports`: `200 Partner sports retrieved.`
- `GET /v1/partner/tournaments/sports/1/formats`: `200 Sport formats retrieved.`
- `GET /v1/partner/tournaments/form-config?sport_id=1&sport_format_id=1`: `200 Form configuration retrieved.`
- `GET /v1/partner/tournaments/form-config?sport_id=999999&sport_format_id=999999`: `422 Validation failed` with clean `sport_id` and `sport_format_id` errors.
- `POST /v1/partner/tournaments/` with empty JSON: `422 Validation failed` with required-field errors for `tournament_type_id`, `sport_id`, and `sport_format_id`.
- `POST /v1/partner/tournaments/` with invalid IDs: `422 Validation failed` with selected-id validation errors.
- `POST /v1/partner/tournaments/` with valid JSON: `200 Draft created successfully.`
- `GET /v1/partner/tournaments/{created_id}`: `200 Tournament retrieved.`
- `GET /v1/partner/tournaments/1`: `404 Resource not found.` This is correct for this test user because tournament `1` is not accessible.
- `PUT /v1/partner/tournaments/{created_id}` with bad date: `422 Validation failed` with `registration_end_at` date error.
- `PUT /v1/partner/tournaments/{created_id}` with valid JSON: `200 Tournament details updated.`
- `PUT /v1/partner/tournaments/{created_id}/rules` with empty rules: `422 Validation failed` with `rules` required error.
- `PUT /v1/partner/tournaments/{created_id}/rules` with valid JSON: `200 Tournament rules updated.`
- `POST /v1/partner/tournaments/{created_id}/venues` with complete JSON including `venue_name`: `200 Venue added successfully.`
- `PUT /v1/partner/tournaments/{created_id}/venues/{venue_id}` with valid JSON: `200 Venue updated successfully.`
- `DELETE /v1/partner/tournaments/{created_id}/venues/{venue_id}`: `200 Venue removed successfully.`
- `PUT /v1/partner/tournaments/{created_id}/budget` with complete JSON including prize `category` and sponsor `sponsor_type`: `200 Budget and registration updated successfully.`
- `GET /v1/partner/tournaments/{created_id}/review`: `200 Review data retrieved.`
- `POST /v1/partner/tournaments/{created_id}/submit` with empty JSON: `422 Validation failed` with `confirmation` required error.
- Full happy path on tournament `12`: create draft, update details, update rules, add venue, update budget, review, submit, and show submitted tournament all returned `200`.
- `POST /v1/partner/tournaments/{created_id}/submit` with JSON `{ "confirmation": true }`: `200 Tournament submitted successfully.`

Current backend/Postman issues found:

- `POST /v1/partner/tournaments/{created_id}/venues` using the current Postman body `{ "venue_id": 1, "notes": "Main ground" }` returns `422 Validation failed` because backend requires `venue_name`. Postman collection should be updated or backend should make `venue_name` optional when `venue_id` is supplied.
- `PUT /v1/partner/tournaments/{created_id}/budget` using the current Postman body fails with `422` because backend requires `prizes.0.category` and `sponsors.0.sponsor_type`. Postman collection should include these fields.
- `POST /v1/partner/tournaments/{created_id}/submit` after deleting all venues returns `422 At least one venue must be configured.` This is valid backend protection and frontend should not allow deleting/removing every venue before final submit.

Frontend validation/backhandling updates:

- Tournament submit now blocks obvious invalid UI data before hitting backend:
  - empty venue name
  - empty venue location
  - invalid or zero daily match capacity
  - invalid entry fee
  - invalid prize pool
- Backend validation errors from `SportoApiException.errors` are now shown as readable first validation messages instead of raw exception text.
- `TournamentVenueRequest` now supports and sends the backend-accepted venue fields from the wizard: `location`, `daily_match_capacity`, `ground_type`, `date`, `start_time`, and `round_name`.

Manual device check:

- ADB detected `Redmi Note 7 Pro`, Android 13.
- Partner app debug build installed and launched successfully on the real device.
- Startup logs showed `SPLASH_GATE started partner profile check` followed by `SPLASH_GATE no stored token, showing login`.
- Authenticated UI/API log testing on the device requires completing OTP login once on that device so Hive contains the bearer token.

## Backend Issues / Blockers

### Initial Postman OTP Run Failed

`POST /v1/partner/verify-otp`

Request body used after reading live `session_key` from Send OTP:

```json
{
  "mobile_number": "9876543210",
  "otp": "1234",
  "session_key": "a29366b2-50ef-4370-a3ec-fd377fc6ce68",
  "device_id": "device-123"
}
```

Response:

```json
{
  "success": false,
  "message": "Invalid API / SessionId Combination - No Entry Exists",
  "errors": null
}
```

Impact:

- The static Postman OTP `1234` did not produce a bearer token.
- Authenticated testing continued only after the user provided a real successful Verify OTP response/token.

Backend needs to confirm one of these:

- Correct test OTP for `9876543210`.
- Whether `1234` is valid on production/staging.
- Whether the SMS provider session key from Send OTP is valid for Verify OTP.
- Whether a staging/test bearer token can be provided for integration.

### Initial Unauthenticated API Sweep

Before a valid token was provided, these endpoints all returned:

```json
{
  "success": false,
  "message": "Unauthenticated.",
  "errors": null
}
```

Blocked endpoints:

- `GET /v1/partner/profile`
- `POST /v1/partner/profile`
- `PUT /v1/partner/profile`
- `GET /v1/partner/sports/available`
- `GET /v1/partner/sports`
- `POST /v1/partner/sports`
- `PUT /v1/partner/sports/1`
- `DELETE /v1/partner/sports/1`
- `GET /v1/partner/documents`
- `POST /v1/partner/documents`
- `DELETE /v1/partner/documents/1`
- `GET /v1/partner/application`
- `POST /v1/partner/submit`
- `GET /v1/partner/tournaments/types`
- `GET /v1/partner/tournaments/sports`
- `GET /v1/partner/tournaments/sports/1/formats`
- `GET /v1/partner/tournaments/form-config?sport_id=1&sport_format_id=1`
- `POST /v1/partner/tournaments/`
- `GET /v1/partner/tournaments/1`
- `PUT /v1/partner/tournaments/1`
- `DELETE /v1/partner/tournaments/1`
- `PUT /v1/partner/tournaments/1/rules`
- `POST /v1/partner/tournaments/1/venues`
- `PUT /v1/partner/tournaments/1/venues/1`
- `DELETE /v1/partner/tournaments/1/venues/1`
- `PUT /v1/partner/tournaments/1/budget`
- `GET /v1/partner/tournaments/1/review`
- `POST /v1/partner/tournaments/1/submit`

## Implemented In Code

- Central API base URL and endpoint classes are in `packages/core/lib/src/network/sporto_api_endpoints.dart`.
- Shared Dio client is in `packages/core/lib/src/network/sporto_api_client.dart`.
- Shared auth session/token storage is in `packages/core/lib/src/network/auth_session_store.dart`.
- Shared auth repository now uses role-specific endpoints through the central endpoint class.
- Exact Postman request body models are in `packages/core/lib/src/network/models/partner_api_requests.dart`.
- Confirmed live response models are in `packages/core/lib/src/network/models/sporto_api_response.dart`.
- Partner onboarding wizard submit is wired through `apps/partner_app/lib/features/auth/presentation/views/auth_flow_view.dart` to:
  - `POST /v1/common/upload`
  - `POST /v1/partner/profile`
  - `POST /v1/partner/sports`
  - `POST /v1/partner/documents`
  - `POST /v1/partner/submit`
- The reusable UI wizard exposes `OnboardingSubmission` and `OnboardingUploadType`; backend calls stay in the partner app/data layer.
- Onboarding upload buttons open a native file picker, upload the selected file through Common Upload, show a spinner while uploading, and only mark the tile uploaded after the backend returns a path.

## Remaining Integration Notes

- Tournament draft/detail/rules/venue/budget/submit success models are implemented from live `200` responses.
- Referee onboarding API integration is pending because the current `postman/` folder only includes partner onboarding endpoints.
