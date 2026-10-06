# Partner Tournament - Frontend Integration Guide

This document outlines the canonical API integration flow for the Partner Tournament creation and scheduling process. The Sporto backend relies on strict validation and structural locking to guarantee data integrity. Frontend applications **must not** bypass these steps or hardcode backend logic (like sport formats, rule limits, or round structures).

---

## Tournament Lifecycle (Conceptual Flow)

1.  **Metadata Loading:** Fetch Types, Sports, Formats, and dynamic Form Config (Rules).
2.  **Draft Creation:** Initialize a tournament draft.
3.  **Details & Configuration:** Update dates, limits, and match configuration.
4.  **Rules & Budget:** Define sport-specific rules, prizes, and sponsors.
5.  **Venue Management:** Add physical venues with capacities.
6.  **Registrations:** Manage participating teams/players.
7.  **Round Generation:** Create the match structure (Brackets/League) based on approved registrations.
8.  **Round Venue Allocation:** Map specific dates and times to specific rounds at specific venues.
9.  **Schedule Generation:** Auto-assign exact times to matches based on round allocations and match duration logic.
10. **Review & Publish:** Publish the schedule and submit the tournament for admin approval.

---

## Step 1: Loading Tournament Metadata

Before showing the creation form, load the required dropdown data.

### 1.1 Load Tournament Types
**Endpoint:** `GET /api/v1/partner/tournaments/types`
**Returns:** List of types (e.g., Knockout, League).

### 1.2 Load Partner Sports
**Endpoint:** `GET /api/v1/partner/tournaments/sports`
**Returns:** Sports enabled for the logged-in Partner.

### 1.3 Load Sport Formats
**Endpoint:** `GET /api/v1/partner/tournaments/sports/{sportId}/formats`
**Returns:** Formats associated with the selected sport (e.g., T20, 5-a-side).

### 1.4 Load Dynamic Form Rules
**Endpoint:** `GET /api/v1/partner/tournaments/form-config?sport_id={sportId}&sport_format_id={formatId}`
**Returns:** The dynamic `sport_rules` fields (e.g., Overs per Innings, Ball Type) with their data types, min/max bounds, and options. **The frontend MUST render the rules form using this JSON.**

---

## Step 2: Creating the Draft

Initialize the tournament.

**Endpoint:** `POST /api/v1/partner/tournaments`
**Payload:**
```json
{
    "tournament_type_id": 1,
    "sport_id": 1,
    "sport_format_id": 1,
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
*Note: A primary venue is required at creation.*

---

## Step 3: Updating Tournament Details

Update dates, team limits, and match configurations.

**Endpoint:** `PUT /api/v1/partner/tournaments/{id}`
**Payload:**
```json
{
    "name": "Pro League 2026",
    "description": "Professional T20 knockout cricket tournament",
    "registration_start_at": "2026-10-01T09:00:00+05:30",
    "registration_end_at": "2026-10-08T20:00:00+05:30",
    "tournament_start_at": "2026-10-10T09:00:00+05:30",
    "tournament_end_at": null,
    "minimum_teams": 4,
    "maximum_teams": 16,
    "contact_name": "Organizer",
    "contact_phone": "+919999999999",
    "timezone": "Asia/Kolkata",
    "match_configuration": {
        "match_duration_minutes": 90,
        "break_between_matches_minutes": 15,
        "lunch_break_from": "13:00",
        "lunch_break_to": "14:00"
    }
}
```
**Constraint Warning:** Once `rounds` have been generated (Step 7), structural fields (e.g., dates, team limits) are **locked** and cannot be modified.

---

## Step 4: Rules & Budget Management

### 4.1 Update Rules
**Endpoint:** `PUT /api/v1/partner/tournaments/{id}/rules`
**Payload:**
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
*Note: Use the IDs returned from `form-config`.*

### 4.2 Update Budget
**Endpoint:** `PUT /api/v1/partner/tournaments/{id}/budget`
**Payload:**
```json
{
    "registration_fee": 2500,
    "currency": "INR",
    "prizes": [
        { "category": "Winner", "title": "Winner", "amount": 50000 }
    ],
    "sponsors": [
        { "sponsor_type": "Title", "name": "Main Sponsor", "contribution_amount": 100000 }
    ]
}
```
*Note: Sending `prizes` or `sponsors` arrays will replace the existing entries entirely.*

---

## Step 5: Additional Venues

If the tournament spans multiple venues, add them.

**Endpoint:** `POST /api/v1/partner/tournaments/{id}/venues`
**Payload:**
```json
{
    "venue_name": "Gachibowli Stadium",
    "location": "Gachibowli",
    "ground_type": "Turf",
    "daily_match_capacity": 6,
    "is_primary": false
}
```
**Important Architectural Note:** Venues **do not** contain `date` or `start_time`. Time-bound scheduling is handled via Round Venue Allocations (Step 8).

---

## Step 6: Managing Registrations

Before rounds can be generated, teams must register (via User app) and be approved.

- **List:** `GET /api/v1/partner/tournaments/{id}/registrations`
- **Approve:** `PUT /api/v1/partner/tournaments/{id}/registrations/{registrationId}/approve`
- **Reject:** `PUT /api/v1/partner/tournaments/{id}/registrations/{registrationId}/reject` (requires `reason`)

---

## Step 7: Round Generation

Once registrations are closed and the minimum required teams are approved, generate the bracket/structure.

**Endpoint:** `POST /api/v1/partner/tournaments/{id}/rounds/generate`
*(Empty Payload)*

**What happens:** The system generates `TournamentStage`, `TournamentRound`, and unscheduled `TournamentMatch` records.
**Locking:** After this succeeds, structural fields in `updateDetails` are locked.

---

## Step 8: Round Venue Allocations (Crucial for Scheduling)

Instead of hardcoding dates on venues, the Partner assigns **specific Rounds** to **specific Venues** on **specific Dates**.

**Endpoint:** `POST /api/v1/partner/tournaments/{id}/rounds/{roundId}/allocations`
**Payload:**
```json
{
    "tournament_venue_id": 5,
    "date": "2026-10-10",
    "start_time": "09:00"
}
```
*Repeat this for all rounds (e.g., Round 1 on Oct 10, Quarter-Finals on Oct 11, Semi-Finals on Oct 12).*

**Constraint:** You cannot allocate more matches to a venue on a given date than its `daily_match_capacity` allows. The API validates this.

---

## Step 9: Schedule Generation

Once rounds are mapped to venue-dates, ask the auto-scheduler to assign precise match times.

**Endpoint:** `POST /api/v1/partner/tournaments/{id}/schedule/generate`
**Payload (Optional):**
```json
{
    "overwrite": true
}
```
*(Use `overwrite: true` if regenerating an existing draft schedule).*

**What happens:** The system cascades match times using the round allocations and the `match_configuration` (match duration, breaks, lunch hour) set in Step 3.

**Preview:** Retrieve the generated schedule using `GET /api/v1/partner/tournaments/{id}/schedule`.

---

## Step 10: Publish & Submit

### 10.1 Publish Schedule
Lock the schedule making it visible to players.
**Endpoint:** `POST /api/v1/partner/tournaments/{id}/schedule/publish`

### 10.2 Review & Submit Tournament
Check readiness: `GET /api/v1/partner/tournaments/{id}/review`
Submit for Admin approval:
**Endpoint:** `POST /api/v1/partner/tournaments/{id}/submit`
**Payload:**
```json
{
    "confirmation": true
}
```

---
## Summary of Constraints to Handle in Frontend
1. **No Dates on Venues:** Do not send dates when creating/updating Venues. Use Allocations.
2. **Structural Locking:** Disable editing of `tournament_start_at`, `minimum_teams`, etc., if the tournament has Rounds.
3. **Allocation Limits:** Warn the user if they try to allocate a round to a venue whose `daily_match_capacity` cannot fit all matches in that round.
