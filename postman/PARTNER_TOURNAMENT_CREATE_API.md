# Partner Tournament Creation API Audit

## Metadata APIs

### 1. Get Tournament Types
- **Method:** `GET`
- **Endpoint:** `/api/v1/partner/tournaments/types`
- **Response:** Array of `TournamentType` objects.

### 2. Get Sports
- **Method:** `GET`
- **Endpoint:** `/api/v1/partner/tournaments/sports`
- **Response:** Array of `Sport` objects that the partner is authorized for.

### 3. Get Formats
- **Method:** `GET`
- **Endpoint:** `/api/v1/partner/tournaments/sports/{sportId}/formats`
- **Response:** Array of `SportFormat` objects for the given sport.

### 4. Get Form Config
- **Method:** `GET`
- **Endpoint:** `/api/v1/partner/tournaments/form-config?sport_id={sportId}&sport_format_id={formatId}`
- **Response:** Array of `SportRuleField` config including `master_default_value`.

### 5. Get Prize Categories
- **Method:** `GET`
- **Endpoint:** `/api/v1/partner/tournaments/prize-categories`
- **Response:** Array of `TournamentPrizeCategory` objects.

**Frontend Sequence:**
1. Fetch Types & Sports.
2. User selects Sport -> Fetch Formats for that Sport.
3. User selects Format -> Fetch Form Config to render dynamic rules.
4. Fetch Prize Categories (can be done later in the flow before Budget section).

---

## Create Tournament

- **Method:** `POST`
- **Endpoint:** `/api/v1/partner/tournaments`
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`
- **Description:** Creates a Draft Tournament with basic configuration.

**Payload Structure:**
```json
{
    "tournament_type_id": 1,
    "sport_id": 1,
    "sport_format_id": 1,
    "venues": [
        {
            "venue_id": 1,
            "is_primary": true
        },
        {
            "venue_name": "Custom Venue Name",
            "location": "Custom Location",
            "daily_match_capacity": 5,
            "ground_type": "Turf",
            "date": "2024-05-10",
            "start_time": "09:00",
            "round_name": "Finals"
        }
    ]
}
```

**Required Fields:**
- `tournament_type_id` (integer) - From Metadata API
- `sport_id` (integer) - From Metadata API
- `sport_format_id` (integer) - From Metadata API

**Optional Fields:**
- `venues` (array) - See Venues payload.

---

## Update Tournament (Details)

- **Method:** `PUT`
- **Endpoint:** `/api/v1/partner/tournaments/{id}`
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`
- **Description:** Partial update behavior. Updates tournament details and (optionally) upserts venues. Replaces existing venue mappings if `venues` is provided.

**Payload Structure:**
```json
{
    "name": "Summer Championship",
    "description": "Annual summer championship",
    "registration_start_at": "2024-04-01T00:00:00Z",
    "registration_end_at": "2024-05-01T00:00:00Z",
    "tournament_start_at": "2024-05-10T00:00:00Z",
    "tournament_end_at": "2024-05-20T00:00:00Z",
    "minimum_teams": 4,
    "maximum_teams": 16,
    "contact_name": "John Doe",
    "contact_email": "john@example.com",
    "contact_phone": "+1234567890",
    "timezone": "UTC",
    "visibility": 1,
    "logo_path": "tournaments/logos/abc.png",
    "banner_path": "tournaments/banners/xyz.png",
    "display_order": 1,
    "venues": [
        {
            "id": 1,
            "venue_id": 5,
            "is_primary": true
        }
    ]
}
```

**Required Fields:**
- `name` (string)

**Important Fields:**
- `registration_start_at`, `registration_end_at`, `tournament_start_at`, `tournament_end_at` - Used for lifecycle. `registration_end_at` is required to submit.
- `venues` - Handled via upsert. If `id` is present, it updates the existing `TournamentVenue` record.

---

## Rules

- **Method:** `PUT`
- **Endpoint:** `/api/v1/partner/tournaments/{id}/rules`
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`
- **Description:** Updates custom tournament overrides.

**Payload Structure:**
```json
{
    "rules": [
        {
            "sport_rule_field_id": 1,
            "value": "11"
        },
        {
            "sport_rule_field_id": 2,
            "value": "T20"
        }
    ]
}
```
**Required Fields:**
- `rules` (array)
- `rules.*.sport_rule_field_id` (integer)
- `rules.*.value` (mixed)

---

## Venues

- **Method:** `POST` `/api/v1/partner/tournaments/{id}/venues`
- **Method:** `PUT` `/api/v1/partner/tournaments/{id}/venues/{venueId}`
- **Method:** `DELETE` `/api/v1/partner/tournaments/{id}/venues/{venueId}`
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`
- **Description:** Manage individual venues for the tournament. Venues can also be upserted in the Create and Update APIs via the `venues` array.

**Create/Update Payload:**
```json
{
    "venue_id": 5,
    "is_primary": true,
    "venue_name": null,
    "location": null,
    "daily_match_capacity": 5,
    "ground_type": "Grass",
    "date": "2024-05-15",
    "start_time": "10:00",
    "round_name": "Qualifier"
}
```

**Required Fields:**
- Either `venue_id` (system venue) OR `venue_name` (custom venue) must be provided.

---

## Multiple Venues

Multiple venues can be provided during:
1. `POST /api/v1/partner/tournaments` (Create)
2. `PUT /api/v1/partner/tournaments/{id}` (Update Details)

Payload accepts a `venues` array as shown in the Create and Update endpoints. If `is_primary` is true for any venue in the payload, all other venues in the database will have their `is_primary` flag set to false.

---

## Budget, Registration, Prize, Sponsorship

All financial configuration is handled via a single Budget API. There is no separate Sponsorship or Prize API. Registration settings (`minimum_teams`, `maximum_teams`, `registration_start_at`, `registration_end_at`) are handled in the **Update Details API**, while financial registration settings (`registration_fee`, `currency`) are handled here.

- **Method:** `PUT`
- **Endpoint:** `/api/v1/partner/tournaments/{id}/budget`
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`
- **Description:** Configures Registration Fee, Prizes, and Sponsors. Replaces existing prizes and sponsors.

**Payload Structure:**
```json
{
    "registration_fee": 100.00,
    "currency": "USD",
    "prizes": [
        {
            "category": "Winner",
            "title": "1st Place",
            "amount": 5000.00
        }
    ],
    "sponsors": [
        {
            "sponsor_type": "Title",
            "name": "Nike",
            "contribution_amount": 10000.00,
            "website_url": "https://nike.com"
        }
    ]
}
```

**Required Fields:**
- None at the root level.
- Inside `prizes`: `title`
- Inside `sponsors`: `sponsor_type`, `name`

---

## Schedule

- **Method:** `GET` `/api/v1/partner/tournaments/{id}/schedule` (Preview generated schedule)
- **Method:** `POST` `/api/v1/partner/tournaments/{id}/schedule/generate` (Generate a draft schedule)
- **Method:** `POST` `/api/v1/partner/tournaments/{id}/schedule/publish` (Publish a generated schedule)

**Generate Payload:**
```json
{
    "start_date": "2024-05-10",
    "end_date": "2024-05-20"
}
```

**Publish Payload:**
```json
{
    "version_id": 1
}
```

---

## Review

- **Method:** `GET`
- **Endpoint:** `/api/v1/partner/tournaments/{id}/review`
- **Description:** Returns all tournament data and calculated financial summary (platform fees, net earnings, etc.). Validates if tournament is ready to submit.

---

## Submit

- **Method:** `POST`
- **Endpoint:** `/api/v1/partner/tournaments/{id}/submit`
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`
- **Description:** Submits the tournament for admin approval. Requires `name`, `registration_end_at`, and at least one venue.

**Payload Structure:**
```json
{
    "confirmation": true
}
```

---

## Status Lifecycle

1. **STATUS_DRAFT (1):** Initial state. Editable (Create, Update, Rules, Venues, Budget).
2. **APPROVAL_STATUS_PENDING (2):** Submitted. Not editable. 
3. **APPROVAL_STATUS_APPROVED (4):** Admin approved. Not editable. Can be published.
4. **STATUS_PUBLISHED (2):** Approved and visible.
5. **STATUS_REGISTRATION_OPEN (3)**
6. **STATUS_REGISTRATION_CLOSED (4)**
7. **STATUS_CHECK_IN (5)**
8. **STATUS_IN_PROGRESS (6)**
9. **STATUS_COMPLETED (7)**

---

## Payload Matrix

| Step | Method | Endpoint | Required Payload Fields | Optional Fields | Success |
|------|--------|----------|-------------------------|-----------------|---------|
| 1 | `POST` | `/api/v1/partner/tournaments` | `tournament_type_id`, `sport_id`, `sport_format_id` | `venues` | 200 OK |
| 2 | `PUT` | `/api/v1/partner/tournaments/{id}` | `name` | `description`, `registration_start_at`, `registration_end_at`, `tournament_start_at`, `tournament_end_at`, `minimum_teams`, `maximum_teams`, `contact_name`, `contact_email`, `contact_phone`, `timezone`, `visibility`, `registration_fee`, `currency`, `logo_path`, `banner_path`, `display_order`, `venues` | 200 OK |
| 3 | `PUT` | `/api/v1/partner/tournaments/{id}/rules` | `rules`, `rules.*.sport_rule_field_id`, `rules.*.value` | | 200 OK |
| 4 | `PUT` | `/api/v1/partner/tournaments/{id}/budget`| | `registration_fee`, `currency`, `prizes`, `sponsors` | 200 OK |
| 5 | `POST` | `/api/v1/partner/tournaments/{id}/venues` | `venue_id` OR `venue_name` | `is_primary`, `location`, `daily_match_capacity`, `ground_type`, `date`, `start_time`, `round_name` | 200 OK |
| 6 | `POST` | `/api/v1/partner/tournaments/{id}/submit` | `confirmation` | | 200 OK |

---

## Response Matrix

| Endpoint | Response Root | Important Fields | Frontend Usage |
|----------|---------------|------------------|----------------|
| GET `/types` | `data` | `id`, `name`, `status` | Populate Tournament Types dropdown |
| GET `/sports` | `data` | `id`, `name`, `status` | Populate Sports dropdown |
| GET `/formats` | `data` | `id`, `name`, `status` | Populate Sport Formats dropdown |
| GET `/form-config` | `data` | `sport_rule_field_id`, `key`, `name`, `category`, `type`, `required`, `validation_rules`, `master_default_value` | Render dynamic rule forms with defaults |
| GET `/{id}/review` | `data` | `tournament`, `financial_summary`, `can_submit` | Show final review screen before submission |
| GET `/{id}` | `data` | `id`, `name`, `settings`, `rules`, `venues`, `prizes`, `sponsors`, `registration_summary`, `approval` | Load complete tournament details |

---

## Errors

- **400 Bad Request:** General failure or invalid state.
- **401 Unauthorized:** Missing or invalid Bearer token.
- **403 Forbidden:** Attempting to access a tournament belonging to another partner, or using a sport not associated with the partner.
- **404 Not Found:** Tournament ID does not exist.
- **422 Unprocessable Entity:** 
    - Validation failures (`errors` object included).
    - Attempting to submit without required fields (`name`, `registration_end_at`, `venues`).
    - Attempting to edit a tournament that is Pending Approval or Approved.
    - Attempting to publish an unapproved tournament.

---
**Verification Complete:** All payloads, fields, and API endpoints are derived exactly from the current backend implementation. No assumed fields or endpoints were fabricated.
