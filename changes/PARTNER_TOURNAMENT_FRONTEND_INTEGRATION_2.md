# Partner Tournament Frontend Integration Guide

Last Updated: 2026-10-06
Backend: Sporto Partner API
Base prefix: `/api/v1/partner`

---

## SECTION 1 — PURPOSE

This document is the definitive frontend integration contract for Partner Tournament Management. It details the complete workflow from initializing a Draft to configuring dynamic Rules, Venues, Budgeting, Round Venue Allocations, Schedule Generation, Referee Assignments, and Final Submission.

---

## SECTION 2 — COMPLETE LIFECYCLE

The frontend must follow this exact logical progression:

Metadata loading
    ↓
Create Draft
    ↓
Update Details
    ↓
Rules (Form Config based)
    ↓
Budget (Prizes & Sponsors)
    ↓
Venues (Physical Locations)
    ↓
Submit Tournament for Admin Approval
    ↓
Admin Approves (Admin workflow, assumed true for next steps)
    ↓
Team Registrations (via User App)
    ↓
Registration Approval
    ↓
Generate Rounds (Knockout/League brackets)
    ↓
Round Venue Allocation (Mapping Rounds to Venue + Date + Capacity)
    ↓
Generate Schedule (Cascade matches based on allocations and duration)
    ↓
Preview Schedule
    ↓
Publish Schedule (Locking version_id)
    ↓
Matches (View matches)
    ↓
Referee Assignments
    ↓
Tournament Execution

*Note: Submission (Step 7) validates the structure and transitions the tournament from Draft to Pending.*

---

## SECTION 3 — AUTHENTICATION

All requests require Partner authentication.

**Headers:**
```
Authorization: Bearer {partner_token}
Accept: application/json
Content-Type: application/json
```

**401 Unauthorized:** Token is invalid or expired.
**403 Forbidden:** The authenticated Partner does not own the requested Tournament. All Tournament child resources are strictly protected.

---

## SECTION 4 — STANDARD API RESPONSE

The backend uses a standard `ResponseHelper` wrapper for all internal APIs.

**Success (HTTP 200/201):**
```json
{
    "success": true,
    "message": "Operation successful.",
    "data": { ... }
}
```

**Validation Error (HTTP 422):**
```json
{
    "success": false,
    "message": "Validation failed.",
    "errors": {
        "field_name": ["Error message describing the issue."]
    }
}
```

- **401/403:** Show access denied or redirect to login.
- **404:** Resource stale/missing. Frontend should reload the Tournament or list.
- **409:** Business logic conflict (e.g., Schedule already exists). Frontend should show a confirmation dialog.
- **422:** Validation or unsatisfiable constraints. Frontend should display field errors or diagnostics.
- **500:** Internal error. Retry or contact support.

---

## SECTION 5 — METADATA

Load these resources before rendering the Draft creation form.

### 5.1 Tournament Types
**Endpoint:** `GET /tournaments/types`
**Purpose:** Tournament type dropdown (e.g., Knockout, League).
**Frontend stores:** `tournament_type_id`

### 5.2 Sports
**Endpoint:** `GET /tournaments/sports`
**Purpose:** Sports enabled for the logged-in Partner.
**Frontend stores:** `sport_id`

### 5.3 Sport Formats
**Endpoint:** `GET /tournaments/sports/{sportId}/formats`
**Purpose:** Valid formats for the selected Sport.
**Frontend stores:** `sport_format_id`

### 5.4 Form Config
**Endpoint:** `GET /tournaments/form-config?sport_id={sportId}&sport_format_id={formatId}`
**Purpose:** Dynamic rules and limits for the selected configuration.
**Warning:** Frontend MUST NOT hardcode configurations like player count, overs, duration, or innings. Use the dynamic definitions returned here to render the Rules form.

### 5.5 Prize Categories
**Endpoint:** `GET /tournaments/prize-categories`
**Purpose:** Get valid categories (e.g., "Winner", "Runner Up") for the Budget screen.

---

## SECTION 6 — TOURNAMENT LIST

**Endpoint:** `GET /tournaments`

**Query Params:**
- `status`
- `search`
- `per_page`

**Response format:** standard paginated response containing `data` and `meta` (current_page, last_page, total).

---

## SECTION 7 — CREATE DRAFT

**Endpoint:** `POST /tournaments`

**Validation (StoreTournamentDraftRequest):**
Primary fields `tournament_type_id`, `sport_id`, `sport_format_id` are required. `venues` array is **optional** at this stage.

**Example Minimum Payload:**
```json
{
    "tournament_type_id": 1,
    "sport_id": 1,
    "sport_format_id": 1
}
```

**Example Full Payload:**
```json
{
    "tournament_type_id": 1,
    "sport_id": 1,
    "sport_format_id": 1,
    "name": "Summer Blast T20",
    "venues": [
        {
            "venue_name": "Sporto Cricket Ground",
            "location": "Hyderabad",
            "ground_type": "Turf",
            "daily_match_capacity": 5,
            "is_primary": true
        }
    ]
}
```

**Frontend Action:** Store the returned `data.id` as `tournament_id`. All subsequent requests depend on this ID.

---

## SECTION 8 — GET TOURNAMENT DETAILS

**Endpoint:** `GET /tournaments/{id}`

Use this to load the Tournament on the Details screen, or to resume an incomplete Draft.

**Returns:**
Tournament properties, nested `tournamentVenues`, nested `rules`, nested `prizes`, nested `sponsors`, `match_configuration`, and `approval_status`.

---

## SECTION 9 — UPDATE DETAILS

**Endpoint:** `PUT /tournaments/{id}`

| Field | Type | Required | Nullable | Description |
|---|---|---|---|---|
| name | string | sometimes | false | Tournament Name |
| description | string | false | true | |
| registration_start_at | string(date) | false | true | |
| registration_end_at | string(date) | false | true | Must be >= registration_start_at |
| tournament_start_at | string(date) | false | true | Must be >= registration_end_at |
| tournament_end_at | string(date) | false | true | Must be >= tournament_start_at |
| minimum_teams | integer | false | true | Min 2 |
| maximum_teams | integer | false | true | Min 2, >= minimum_teams |
| contact_name | string | false | true | |
| contact_email | string(email)| false | true | |
| contact_phone | string | false | true | |
| timezone | string | false | true | Valid timezone |
| visibility | integer | false | true | 1, 2, or 3 |
| registration_fee | numeric | false | true | Min 0 |
| currency | string | false | true | e.g. "INR", length 3 |
| logo_path | string | false | true | |
| banner_path | string | false | true | |
| display_order | integer | false | true | |
| venues | array | false | true | Array of venue objects |
| match_configuration | array | false | true | Nested config object |

**Example Payload:**
```json
{
    "name": "Pro League 2026",
    "description": "Professional T20 knockout cricket tournament",
    "registration_start_at": "2026-10-01T09:00:00+05:30",
    "registration_end_at": "2026-10-08T20:00:00+05:30",
    "tournament_start_at": "2026-10-10T09:00:00+05:30",
    "tournament_end_at": "2026-10-20T20:00:00+05:30",
    "minimum_teams": 4,
    "maximum_teams": 16,
    "contact_name": "Organizer",
    "contact_email": "organizer@example.com",
    "contact_phone": "+919999999999",
    "timezone": "Asia/Kolkata",
    "visibility": 1,
    "match_configuration": {
        "match_duration_minutes": 90,
        "break_between_matches_minutes": 15,
        "lunch_break_from": "13:00",
        "lunch_break_to": "14:00"
    }
}
```

---

## SECTION 10 — MATCH CONFIGURATION

Match configurations dictate schedule generation mathematics. 
Supported fields in `match_configuration`:
- `match_duration_minutes`
- `break_between_matches_minutes`
- `lunch_break_from` (H:i)
- `lunch_break_to` (H:i)

The backend scheduler aggregates these fields with Round Venue Allocations to determine when matches start and end.

---

## SECTION 11 — STRUCTURAL LOCKING

Once Rounds are generated (or Tournament goes Live), structural fields are locked.

| Field/Section | Before Rounds | After Rounds | After Schedule | After Live |
|---|---|---|---|---|
| sport_id | Unlocked | Locked | Locked | Locked |
| sport_format_id | Unlocked | Locked | Locked | Locked |
| tournament_type_id | Unlocked | Locked | Locked | Locked |
| minimum_teams | Unlocked | Locked | Locked | Locked |
| maximum_teams | Unlocked | Locked | Locked | Locked |
| tournament_start_at | Unlocked | Locked | Locked | Locked |
| tournament_end_at | Unlocked | Locked | Locked | Locked |
| venues | Unlocked | Unlocked | Locked | Locked |
| match_configuration| Unlocked | Unlocked | Locked | Locked |

Frontend should disable these inputs if Rounds exist. The backend enforces this strictly.

---

## SECTION 12 — RULES

**Endpoint:** `PUT /tournaments/{id}/rules`

Use the IDs returned from the Form Config endpoint.

**Example Payload:**
```json
{
    "rules": [
        {
            "sport_rule_field_id": 1,
            "value": "2"
        },
        {
            "sport_rule_field_id": 2,
            "value": "11"
        }
    ]
}
```

---

## SECTION 13 — BUDGET

**Endpoint:** `PUT /tournaments/{id}/budget`

| Field | Type | Description |
|---|---|---|
| registration_fee | numeric | Optional entry fee |
| currency | string | 3-char code |
| prizes | array | Array of prizes. **Replaces existing prizes entirely.** |
| sponsors | array | Array of sponsors. **Replaces existing sponsors entirely.** |

**Example Payload:**
```json
{
    "registration_fee": 2500,
    "currency": "INR",
    "prizes": [
        { "category": "Winner", "title": "1st Place", "amount": 50000 }
    ],
    "sponsors": [
        { "sponsor_type": "Title", "name": "Main Sponsor", "contribution_amount": 100000, "website_url": "https://example.com" }
    ]
}
```

---

## SECTION 14 — VENUE ARCHITECTURE

There is a strict separation between physical Venues and Scheduling Allocations:

- **TournamentVenue:** The physical ground, location, and abstract maximum daily match capability.
- **TournamentRoundVenueAllocation:** The specific mapping of a specific Round to a specific Venue on a specific Date.

---

## SECTION 15 — LEGACY VENUE DATE/TIME FIELDS

Legacy fields `date`, `start_time`, and `tournament_round_id` directly on the `TournamentVenue` model have been deprecated and removed from API payloads.

**Frontend MUST NOT send date or start_time when creating or updating Venues.** Time-bound scheduling relies entirely on Round Venue Allocations.

---

## SECTION 16 — CREATE VENUE

**Endpoint:** `POST /tournaments/{id}/venues`

**Example Payload:**
```json
{
    "venue_name": "Gachibowli Stadium",
    "location": "Gachibowli, Hyderabad",
    "ground_type": "Turf",
    "daily_match_capacity": 6,
    "is_primary": false
}
```
**Notes:** `daily_match_capacity` is the theoretical physical limit.

---

## SECTION 17 — UPDATE VENUE

**Endpoint:** `PUT /tournaments/{id}/venues/{venueId}`

Uses partial update semantics. You only need to send the fields you wish to change.

---

## SECTION 18 — DELETE VENUE

**Endpoint:** `DELETE /tournaments/{id}/venues/{venueId}`

Will error (422) if the Venue is actively used in Round Venue Allocations or Scheduled Matches.

---

## SECTION 19 — REGISTRATIONS

Registrations originate from the User flow. Partners review them here.

**List:** `GET /tournaments/{id}/registrations`
**Detail:** `GET /tournaments/{id}/registrations/{registrationId}`
**Approve:** `PUT /tournaments/{id}/registrations/{registrationId}/approve`
**Reject:** `PUT /tournaments/{id}/registrations/{registrationId}/reject` (requires `{"reason": "string"}`)

The count of Approved registrations is used to generate the bracket in the Round generation step.

---

## SECTION 20 — TOURNAMENT-SPECIFIC PLAYERS

`TournamentRegistrationPlayer` represents the tournament-specific roster selected for this event, distinct from `TeamPlayer` which is the generic Team membership. Reviews should focus on `TournamentRegistrationPlayer` data.

---

## SECTION 21 — ROUND GENERATION

**Endpoint:** `POST /tournaments/{id}/rounds/generate`
**Payload:** None `{}`

**Behavior:**
1. Validates structural readiness and minimum approved teams.
2. Creates `TournamentStage`.
3. Creates `TournamentRound`s based on Tournament Type math (e.g. 16 teams -> R16, QF, SF, F).
4. Creates unscheduled `TournamentMatch`es and `TournamentMatchSlot`s with BYEs properly calculated.
5. Triggers structural locks (disabling edit of Team limits and Start/End dates).

---

## SECTION 22 — ROUND ARCHITECTURE

**Hierarchy:**
`Tournament` → `TournamentStage` → `TournamentRound` → `TournamentMatch`

The `TournamentRound` model contains `id`, `name` (e.g. "Quarter Final"), `sequence`, and computed `match_count`.

---

## SECTION 23 — EXAMPLE KNOCKOUT STRUCTURE

*Example only:* 16 Teams -> 15 matches total.
- Round of 16 (8 matches)
- Quarter Final (4 matches)
- Semi Final (2 matches)
- Final (1 match)

The backend determines this math. Frontend MUST NOT generate bracket structures or names locally.

---

## SECTION 24 — ROUND LIST

**Endpoint:** `GET /tournaments/{id}/rounds`

Returns the generated rounds with their `id` and `match_count`. The list is empty before Round Generation.
Frontend uses the returned `round_id` for Venue Allocation.

---

## SECTION 25 — ROUND VENUE ALLOCATION

A single Round can be mapped to multiple Allocations (e.g., Round 1 spans across 2 Venues on the same day). A Venue can be allocated across multiple Rounds.

---

## SECTION 26 — GET ROUND ALLOCATIONS

**Endpoint:** `GET /tournaments/{id}/rounds/{roundId}/allocations`

Returns an array of allocations, including `allocation_id`, `tournament_venue_id`, `date`, `start_time`, `end_time`, and `daily_match_capacity`.

---

## SECTION 27 — CREATE ROUND ALLOCATION

**Endpoint:** `POST /tournaments/{id}/rounds/{roundId}/allocations`

**Example Payload:**
```json
{
    "tournament_venue_id": 5,
    "date": "2026-10-10",
    "start_time": "09:00",
    "daily_match_capacity": 4,
    "is_primary_for_round": true
}
```
**Constraint:** The backend validates that `daily_match_capacity` inside the allocation does not exceed the Venue's abstract `daily_match_capacity`.

---

## SECTION 28 — MULTIPLE VENUES PER ROUND

Example:
Round of 16 has 8 matches.
- Allocation A: Venue 1, capacity 4.
- Allocation B: Venue 2, capacity 4.

The scheduler dynamically distributes matches across these allocations based on capacity and defined start times.

---

## SECTION 29 — UPDATE / DELETE ALLOCATION

**Update:** `PUT /tournaments/{id}/rounds/{roundId}/allocations/{allocationId}`
**Delete:** `DELETE /tournaments/{id}/rounds/{roundId}/allocations/{allocationId}`

---

## SECTION 30 — SCHEDULE GENERATION

**Endpoint:** `POST /tournaments/{id}/schedule/generate`

**Payload:**
```json
{}
```
*Note: The frontend no longer provides `start_date` or `end_date`. The scheduler derives everything from Tournament Dates, Round Allocations, and Match Configuration.*

---

## SECTION 31 — SCHEDULE GENERATE RESPONSE

**Success Response:**
```json
{
    "success": true,
    "message": "Schedule generation started successfully.",
    "data": {
        "schedule": {
            "version_id": 123,
            "status": 1,
            "generation_key": "uuid-...",
            "resolved_start_at": "2026-10-10T09:00:00Z",
            "resolved_end_at": "2026-10-20T20:00:00Z",
            "end_date_source": "derived_from_allocations"
        }
    }
}
```
**Frontend Action:** Store the `version_id`. It is strictly required for Publishing.

---

## SECTION 32 — SCHEDULE OVERWRITE FLOW

If a schedule already exists, the backend prevents accidental replacement.

1. `POST /schedule/generate` with `{}`
2. Backend returns `HTTP 409`:
```json
{
    "success": false,
    "message": "A schedule already exists for this tournament.",
    "errors": { "code": "SCHEDULE_ALREADY_EXISTS" },
    "data": { "requires_overwrite_confirmation": true }
}
```
3. Frontend shows confirmation modal: *"A schedule already exists. Regenerating may replace the current draft schedule. Do you want to continue?"*
4. If User confirms, send:
```json
{
    "overwrite": true
}
```

---

## SECTION 33 — SCHEDULING DIAGNOSTICS

If the auto-scheduler cannot fit the matches, the backend returns `HTTP 422`.

```json
{
    "success": false,
    "message": "Schedule generation failed due to unsatisfiable constraints.",
    "data": {
        "diagnostics": [
            "Venue 1 capacity exceeded on 2026-10-10"
        ]
    }
}
```
Frontend should display these diagnostics to prompt the user to add more Allocations.

---

## SECTION 34 — GET SCHEDULE

**Endpoint:** `GET /tournaments/{id}/schedule`

Returns the `version_id`, `status`, `generated_at`, and the array of `matches` populated with exact `scheduled_start_at`, `scheduled_end_at`, and `tournament_venue_id`.

---

## SECTION 35 — SCHEDULE PUBLISH

**Endpoint:** `POST /tournaments/{id}/schedule/publish`

**REQUIRED Payload:**
```json
{
    "version_id": 123
}
```
This strictly requires the `version_id` obtained from Generate or Get Schedule. It transitions the matches to a visible state.

---

## SECTION 36 — MATCHES

**Endpoint:** `GET /tournaments/{id}/matches`

**Query Filters:**
`status`, `stage_id`, `round_id`, `group_id`, `venue_id`, `date`, `per_page` (max 100).

---

## SECTION 37 — MATCH DETAILS

**Endpoint:** `GET /tournaments/{id}/matches/{matchId}`

Returns nested Stage, Round, Venue, Schedule, Status, and Scoring summary for a single match.

---

## SECTION 38 — REFEREES

- **List:** `GET /tournaments/{id}/matches/{matchId}/referees`
- **Assign:** `POST /tournaments/{id}/matches/{matchId}/referees`
  `{"referee_id": 4, "role": "Umpire 1"}`
- **Detail:** `GET /tournaments/{id}/matches/{matchId}/referees/{assignmentId}`
- **Update:** `PUT /tournaments/{id}/matches/{matchId}/referees/{assignmentId}`
  `{"role": "Umpire 2", "notes": "Changed due to conflict"}`
- **Delete:** `DELETE /tournaments/{id}/matches/{matchId}/referees/{assignmentId}`

---

## SECTION 39 — REVIEW

**Endpoint:** `GET /tournaments/{id}/review`

Returns readiness summary, errors, warnings, and missing configuration sections. Frontend should use this endpoint before enabling the Submit button.

---

## SECTION 40 — SUBMIT

**Endpoint:** `POST /tournaments/{id}/submit`

**Payload:**
```json
{
    "confirmation": true
}
```
**Prerequisites:** Requires a Tournament name, a registration end date, and at least one TournamentVenue. Transitions status to Pending Approval.

---

## SECTION 41 — SUBMIT VS SCHEDULE PUBLISH

- **Submit:** Sends the entire Tournament configuration for Admin Approval. Happens early in the lifecycle.
- **Schedule Publish:** Locks the generated schedule and makes matches public. Happens after rounds are generated and matches are allocated.

---

## SECTION 42 — DELETE TOURNAMENT

**Endpoint:** `DELETE /tournaments/{id}`

Returns `HTTP 422` if the Tournament is already Pending or Approved. Only Drafts can be deleted.

---

## SECTION 43 — FRONTEND PAGE / SCREEN MAPPING

- **Tournament List:** `GET /tournaments`
- **Create Step 1:** Metadata endpoints
- **Create Step 2:** `POST /tournaments` (Draft)
- **Details Screen:** `PUT /tournaments/{id}`
- **Rules Screen:** `PUT /.../rules`
- **Budget Screen:** `PUT /.../budget`
- **Venues Screen:** `POST/PUT /.../venues`
- **Review & Submit Screen:** `GET /.../review` → `POST /.../submit`
- **Registrations Screen:** `GET /.../registrations`
- **Rounds Screen:** `POST /.../rounds/generate` → `GET /.../rounds`
- **Round Scheduling Screen:** `POST /.../allocations`
- **Schedule Screen:** `POST /.../schedule/generate` → `GET /.../schedule`
- **Matches Screen:** `GET /.../matches`
- **Referee Screen:** `POST /.../referees`

---

## SECTION 44 — FRONTEND API SERVICE METHODS

**Suggested mappings:**
`getTournamentTypes()`, `getPartnerSports()`, `getSportFormats(sportId)`, `getTournamentFormConfig(sportId, sportFormatId)`, `getPrizeCategories()`, `getPartnerTournaments(filters)`, `createTournamentDraft(payload)`, `getTournament(id)`, `updateTournament(id, payload)`, `deleteTournament(id)`, `updateTournamentRules(id, payload)`, `createTournamentVenue(id, payload)`, `updateTournamentVenue(id, venueId, payload)`, `deleteTournamentVenue(id, venueId)`, `updateTournamentBudget(id, payload)`, `getTournamentRegistrations(id, params)`, `getTournamentRegistration(id, registrationId)`, `approveRegistration(id, registrationId)`, `rejectRegistration(id, registrationId, payload)`, `generateTournamentRounds(id)`, `getTournamentRounds(id)`, `getRoundAllocations(id, roundId)`, `createRoundAllocation(id, roundId, payload)`, `updateRoundAllocation(id, roundId, allocationId, payload)`, `deleteRoundAllocation(id, roundId, allocationId)`, `generateTournamentSchedule(id, overwrite = false)`, `getTournamentSchedule(id)`, `publishTournamentSchedule(id, versionId)`, `getTournamentMatches(id, filters)`, `getTournamentMatch(id, matchId)`, `getMatchReferees(id, matchId)`, `assignMatchReferee(id, matchId, payload)`, `getMatchRefereeAssignment(id, matchId, assignmentId)`, `updateMatchReferee(id, matchId, assignmentId, payload)`, `deleteMatchReferee(id, matchId, assignmentId)`, `getTournamentReview(id)`, `submitTournament(id, payload)`.

---

## SECTION 45 — ID DEPENDENCY TABLE

| ID | Obtained From | Used By |
|---|---|---|
| tournament_type_id | GET types | Create Draft |
| sport_id | GET sports | Formats/Form Config/Draft |
| sport_format_id | GET formats | Form Config/Draft |
| tournament_id | POST tournaments | All Tournament child APIs |
| venue_id | Venue response | Allocation/update/delete |
| round_id | GET rounds | Round allocation |
| allocation_id | Allocation create/list | Allocation update/delete |
| registration_id | Registration list | Detail/approve/reject |
| version_id | Generate/Get Schedule | Publish Schedule |
| match_id | Match list | Match detail/referees |
| referee_id | Referee source API | Assignment |
| assignment_id | Referee assignment response | Detail/update/delete |

---

## SECTION 46 — FRONTEND STATE EXAMPLE

```json
{
    "tournamentId": null,
    "metadata": {
        "types": [],
        "sports": [],
        "formats": [],
        "formConfig": null,
        "prizeCategories": []
    },
    "tournament": null,
    "rules": [],
    "venues": [],
    "registrations": [],
    "rounds": [],
    "roundAllocations": {},
    "schedule": null,
    "matches": [],
    "review": null
}
```

---

## SECTION 47 — RESUME EXISTING DRAFT

If a user resumes an existing draft, fetch `GET /tournaments/{id}`. Hydrate the local state. **Do not create a new Draft ID.** Keep appending to the existing `tournament_id`.

---

## SECTION 48 — DATA REFRESH RULES

| Action | Refresh Requirement |
|---|---|
| Update details | Refresh Tournament |
| Update rules | Refresh Tournament / effective rules |
| Venue mutation | Refresh Venues / Tournament |
| Registration mutation | Refresh Registrations |
| Generate rounds | GET rounds |
| Allocation mutation | GET allocations / rounds |
| Generate schedule | GET schedule |
| Publish schedule | GET schedule |
| Referee mutation | GET referees |
| Submit | GET Tournament |

---

## SECTION 49 — FRONTEND VALIDATION VS BACKEND VALIDATION

Frontend provides immediate UX feedback. **Backend is authoritative.**
Do not hardcode:
- Sport rules
- Round Brackets
- Schedule Cascading Mathematics
- State Transitions

---

## SECTION 50 — LOADING / BUTTON STATES

- **Generate Rounds:** Disabled/Loading while running.
- **Generate Schedule:** Show spinner.
- **409 SCHEDULE_ALREADY_EXISTS:** Show Overwrite Modal.
- **Publish Schedule:** Disabled unless valid `version_id` exists.
- **Submit:** Disabled if `GET /review` shows errors.

---

## SECTION 51 — COMPLETE END-TO-END EXAMPLE

1. `GET /tournaments/types`
2. `GET /tournaments/sports`
3. `GET /tournaments/sports/1/formats`
4. `GET /tournaments/form-config?sport_id=1&sport_format_id=2`
5. `POST /tournaments`
6. `PUT /tournaments/349`
7. `PUT /tournaments/349/rules`
8. `PUT /tournaments/349/budget`
9. `POST /tournaments/349/venues`
10. `GET /tournaments/349/review`
11. `POST /tournaments/349/submit`
12. (Admin Approves)
13. User Teams register through User flow
14. `GET /tournaments/349/registrations`
15. Partner approves registrations
16. `POST /tournaments/349/rounds/generate`
17. `GET /tournaments/349/rounds`
18. `POST /tournaments/349/rounds/500/allocations`
19. `POST /tournaments/349/schedule/generate`
20. `GET /tournaments/349/schedule`
21. `POST /tournaments/349/schedule/publish` (`{"version_id": 123}`)
22. `GET /tournaments/349/matches`
23. `POST /tournaments/349/matches/99/referees`

---

## SECTION 52 — ROUND + VENUE + SCHEDULE EXPLANATION

```text
Tournament
│
├── Venues (Abstract grounds)
│   ├── Main Stadium
│   └── Ground B
│
└── Stage (Knockout/League)
    │
    ├── Round of 16
    │   ├── Allocation → Main Stadium (Oct 10)
    │   └── Allocation → Ground B (Oct 10)
    │
    ├── Quarter Final
    │   └── Allocation → Main Stadium (Oct 11)
```

**Equation:**
Round structure + Venue Allocations + Match Configuration = Schedule.

---

## SECTION 53 — SCHEDULE VERSIONING

Generating a schedule creates a new version ID.
`POST /schedule/publish` requires this ID to guarantee you are publishing the exact schedule you previewed, preventing race conditions.

---

## SECTION 54 — ERROR RECOVERY

- **409 (Overwrite):** Ask for confirmation and resend with `overwrite: true`.
- **422 (Unsatisfiable):** Show diagnostics, adjust allocations/match config, and retry.
- **403 (Ownership):** Hard failure. Reject access.
- **404:** Resource stale/missing. Reload Tournament.
- **401:** Token expired. Re-authenticate.

---

## SECTION 55 — DO NOT DO THIS

- **DO NOT** hardcode Round names.
- **DO NOT** calculate the bracket on frontend.
- **DO NOT** calculate match schedules on frontend.
- **DO NOT** hardcode Rule IDs or Sport limits.
- **DO NOT** publish schedule without the returned `version_id`.
- **DO NOT** assume `TournamentVenue.date` is valid (it is removed).
- **DO NOT** mix TeamPlayer and TournamentRegistrationPlayer models.
- **DO NOT** generate match IDs locally.
- **DO NOT** assume primary venue is strictly mandatory at Draft creation (it is checked on Submit).

---

## SECTION 56 — API QUICK REFERENCE

| # | Method | Endpoint | Purpose | Request Body | Main Returned ID | Frontend Screen |
|---|---|---|---|---|---|---|
| 1 | GET | /tournaments/types | Get Types | none | tournament_type_id | Create Step 1 |
| 2 | GET | /tournaments/sports | Get Sports | none | sport_id | Create Step 1 |
| 3 | GET | /tournaments/sports/{sportId}/formats | Get Formats | none | sport_format_id | Create Step 1 |
| 4 | GET | /tournaments/form-config | Get Form Rules | none | (form config) | Rules Screen |
| 5 | GET | /tournaments/prize-categories | Get Prize Cats | none | (name) | Budget Screen |
| 6 | GET | /tournaments | List Tournaments | none | tournament_id | List Screen |
| 7 | POST | /tournaments | Create Draft | Types, Sport | tournament_id | Create Step 2 |
| 8 | GET | /tournaments/{id} | Get Detail | none | - | Details Screen |
| 9 | PUT | /tournaments/{id} | Update Details | Details object | - | Details Screen |
| 10 | DELETE | /tournaments/{id} | Delete Draft | none | - | List Screen |
| 11 | PUT | /tournaments/{id}/rules | Update Rules | Rules array | - | Rules Screen |
| 12 | POST | /tournaments/{id}/venues | Create Venue | Venue data | venue_id | Venues Screen |
| 13 | PUT | /tournaments/{id}/venues/{venueId} | Update Venue | Venue data | - | Venues Screen |
| 14 | DELETE | /tournaments/{id}/venues/{venueId} | Delete Venue | none | - | Venues Screen |
| 15 | GET | /tournaments/{id}/rounds/{roundId}/allocations| List Allocations | none | allocation_id | Scheduling Screen |
| 16 | POST | /tournaments/{id}/rounds/{roundId}/allocations| Create Allocation| Allocation data| allocation_id | Scheduling Screen |
| 17 | PUT | /tournaments/{id}/rounds/{roundId}/allocations/{allocationId} | Update Alloc. | Allocation data| - | Scheduling Screen |
| 18 | DELETE | /tournaments/{id}/rounds/{roundId}/allocations/{allocationId} | Delete Alloc. | none | - | Scheduling Screen |
| 19 | PUT | /tournaments/{id}/budget | Update Budget | Budget array | - | Budget Screen |
| 20 | GET | /tournaments/{id}/registrations | List Registrations | none | registration_id| Registrations Screen|
| 21 | GET | /tournaments/{id}/registrations/{registrationId} | Get Registration | none | - | Registrations Screen|
| 22 | PUT | /tournaments/{id}/registrations/{registrationId}/approve| Approve Reg. | none | - | Registrations Screen|
| 23 | PUT | /tournaments/{id}/registrations/{registrationId}/reject| Reject Reg. | `{"reason":""}`| - | Registrations Screen|
| 24 | GET | /tournaments/{id}/rounds | List Rounds | none | round_id | Rounds Screen |
| 25 | POST | /tournaments/{id}/rounds/generate | Generate Rounds | none | - | Rounds Screen |
| 26 | GET | /tournaments/{id}/schedule | Get Schedule | none | version_id | Schedule Screen |
| 27 | POST | /tournaments/{id}/schedule/generate | Generate Schedule| `{overwrite}` | version_id | Schedule Screen |
| 28 | POST | /tournaments/{id}/schedule/publish | Publish Schedule | `{version_id}` | - | Schedule Screen |
| 29 | GET | /tournaments/{id}/matches | List Matches | none | match_id | Matches Screen |
| 30 | GET | /tournaments/{id}/matches/{matchId}/referees | List Referees | none | assignment_id | Referees Screen |
| 31 | POST | /tournaments/{id}/matches/{matchId}/referees | Assign Referee | `{referee_id}` | assignment_id | Referees Screen |
| 32 | GET | /tournaments/{id}/matches/{matchId}/referees/{assignmentId}| Get Referee | none | - | Referees Screen |
| 33 | PUT | /tournaments/{id}/matches/{matchId}/referees/{assignmentId}| Update Referee | `{role, notes}`| - | Referees Screen |
| 34 | DELETE | /tournaments/{id}/matches/{matchId}/referees/{assignmentId}| Delete Referee | none | - | Referees Screen |
| 35 | GET | /tournaments/{id}/matches/{matchId} | Get Match Detail | none | - | Matches Screen |
| 36 | GET | /tournaments/{id}/review | Review Summary | none | - | Submit Screen |
| 37 | POST | /tournaments/{id}/submit | Submit Tournament| `{confirmation}`| - | Submit Screen |

---

## SECTION 57 — REQUEST PAYLOAD QUICK REFERENCE

**Create Draft:** `{"tournament_type_id": 1, "sport_id": 1, "sport_format_id": 1}`
**Update Details:** `{"name": "...", "minimum_teams": 4}`
**Update Rules:** `{"rules": [{"sport_rule_field_id": 1, "value": "2"}]}`
**Create Venue:** `{"venue_name": "Stadium A", "daily_match_capacity": 5}`
**Update Venue:** `{"daily_match_capacity": 6}`
**Update Budget:** `{"registration_fee": 100, "prizes": []}`
**Approve Registration:** Request body: none
**Reject Registration:** `{"reason": "Incomplete roster"}`
**Generate Rounds:** Request body: none
**Create Allocation:** `{"tournament_venue_id": 5, "date": "2026-10-10"}`
**Update Allocation:** `{"date": "2026-10-11"}`
**Generate Schedule:** `{}` or `{"overwrite": true}`
**Publish Schedule:** `{"version_id": 123}`
**Assign Referee:** `{"referee_id": 44, "role": "Umpire"}`
**Update Referee:** `{"role": "Main Umpire"}`
**Submit Tournament:** `{"confirmation": true}`

---

## SECTION 58 — RESPONSE EXAMPLES

**Get Tournament (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Summer Blast",
    "approval_status": 1,
    "tournament_venues": [],
    "match_configuration": { "match_duration_minutes": 90 }
  }
}
```

**Generate Schedule (200):**
```json
{
  "success": true,
  "data": {
    "schedule": {
      "version_id": 123,
      "status": 1,
      "generation_key": "uuid-...",
      "resolved_start_at": "2026-10-10T09:00:00Z",
      "resolved_end_at": "2026-10-20T20:00:00Z"
    }
  }
}
```

**Generate Schedule (409 Conflict):**
```json
{
  "success": false,
  "errors": { "code": "SCHEDULE_ALREADY_EXISTS" },
  "data": { "requires_overwrite_confirmation": true }
}
```

---

## SECTION 59 — POSTMAN CONSISTENCY

This Markdown explicitly aligns 1-to-1 with the `postman/Partner/tournament.php.postman_collection.json` source. 

---

## SECTION 60 — KNOWN CURRENT SCHEDULE CONTRACT

**Schedule Generate:**
Optional input: `{"overwrite": true}`. Returns `version_id`.
**Schedule Publish:**
Mandatory input: `{"version_id": 123}`.
**Conflict:**
Always ask user before sending `{"overwrite": true}`.
