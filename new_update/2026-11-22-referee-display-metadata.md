# Referee tournament and match display metadata — 2026-11-22

This change addresses the six display fields in `REFEREE_BACKEND_API_REMAINING_2026-11-19 (1).md`. It populates match organizer names and real coordinate-backed distances where the stored sources exist, and makes unsupported or missing values explicit. All existing HTTP methods, paths, authentication, assignment ownership and pagination stay intact. Examples below are illustrative response excerpts, not captured production responses or updates to tournament 433 / matches 4204–4209.

## Affected reads

Use `Authorization: Bearer <referee_token>`, `Accept: application/json`, and `Content-Type: application/json`. These GET requests have no body; existing pagination remains in the query string.

| Request | Row path |
|---|---|
| `GET /api/v1/referee/tournaments` | `data.items[]` |
| `GET /api/v1/referee/tournaments/{tournamentId}` | `data` |
| `GET /api/v1/referee/matches` | `data.items[]` |
| `GET /api/v1/referee/matches/{matchId}` | `data` |
| `GET /api/v1/referee/match-requests` | `data.items[]` |

Dashboard match previews reuse the match serializer and therefore return the same display fields. Independent `/bookings/requests` resources are separate and are not changed by this match-card contract.

## Tournament city, level and referee fee

| Field | Available value | Unavailable handling |
|---|---|---|
| `city` | Explicit stored tournament city; `city_source` is `TOURNAMENT` | `city:null`, `city_source:null`, `city_unavailable_reason:CITY_NOT_CONFIGURED` |
| `level` | Explicit configured Local, District, State, National or International | `level:null`, `level_unavailable_reason:LEVEL_NOT_CONFIGURED` |
| `referee_fee` | No per-tournament referee fee agreement is modeled | `referee_fee:null`, `referee_fee_unavailable_reason:TOURNAMENT_REFEREE_FEE_NOT_SUPPORTED` |

`city_unavailable_reason` and `level_unavailable_reason` are null when their corresponding values are present. No city is inferred by splitting arbitrary venue addresses, and no tournament is automatically classified as Local. Tournament `fee` / `registration_fee` remain the entrant registration price. `earnings_total` remains the current referee's actual PAID booking earnings in tournament currency. Neither supplies a missing referee fee.

Illustrative configured tournament excerpt:

```json
{
  "city": "Hyderabad",
  "city_source": "TOURNAMENT",
  "city_unavailable_reason": null,
  "level": "Local",
  "level_unavailable_reason": null,
  "referee_fee": null,
  "referee_fee_unavailable_reason": "TOURNAMENT_REFEREE_FEE_NOT_SUPPORTED"
}
```

## Match customer and fee

`customer_name` resolves the first nonempty real name from the following sources, in order:

| Name source | `customer_name_source` |
|---|---|
| Assignment's booking customer | `ASSIGNMENT_BOOKED_BY` |
| Linked booking's customer | `BOOKING_BOOKED_BY` |
| Tournament partner's name | `TOURNAMENT_PARTNER` |
| Tournament `contact_name` | `TOURNAMENT_CONTACT` |
| Tournament organization name | `TOURNAMENT_ORGANIZATION` |

No phone-number fallback is used. Contact email, contact phone, OTPs and payment-provider details are not added to the projection. If no name source exists, `customer_name` and `customer_name_source` are null and `customer_name_unavailable_reason` is `CUSTOMER_NAME_NOT_CONFIGURED`. When a name exists, its unavailable reason is null. A tournament organizer is a display identity, not proof that that person made a referee booking/payment; use the source field when choosing a UI label.

Match `fee` uses only the linked booking's frozen `referee_fee`, represented as a decimal string with the existing `currency`. `fee_source` is `REFEREE_BOOKING`, and `fee_unavailable_reason` is null when that value exists. A legitimate frozen `"0.00"` is available. Otherwise `fee` and `fee_source` are null with `fee_unavailable_reason:NO_REFEREE_FEE_AGREEMENT`. No current pricing estimate, registration fee, prize pool or wallet balance is substituted. Reads do not create earnings or credit a wallet.

## Stored-location distance

`distance_km` is the straight-line distance from the assigned referee account's saved `UserProfile.latitude/longitude` to the published match venue's latitude/longitude. If no scheduled venue is selected, linked booking coordinates can supply the destination. A selected venue whose coordinates are missing/invalid does not silently switch to a different booking location.

On success, `distance_km` is a number rounded to two decimal places, `distance_basis` is `STORED_PROFILE_STRAIGHT_LINE`, and `distance_unavailable_reason` is null. It is not live GPS, road distance or travel duration. The result reflects the saved profile coordinates, which may be older than the user's present location. Zero coordinates and a distance of zero are valid; test null separately from zero.

When unavailable, both `distance_km` and `distance_basis` are null. The reason is one of:

| `distance_unavailable_reason` | Meaning |
|---|---|
| `REFEREE_COORDINATES_NOT_CONFIGURED` | The referee's saved coordinate pair is missing/incomplete |
| `REFEREE_COORDINATES_INVALID` | The saved referee pair is not a valid finite latitude/longitude |
| `VENUE_NOT_CONFIGURED` | No selected venue or eligible booking destination exists |
| `VENUE_COORDINATES_NOT_CONFIGURED` | The selected destination's coordinate pair is missing/incomplete |
| `VENUE_COORDINATES_INVALID` | The selected destination pair is invalid |

An illustrative match excerpt, using a fixture with saved coordinates `(0, 0)` and venue `(0, 0.01)`, is:

```json
{
  "customer_name": "Fixture Organizer",
  "customer_name_source": "TOURNAMENT_PARTNER",
  "customer_name_unavailable_reason": null,
  "fee": null,
  "fee_source": null,
  "fee_unavailable_reason": "NO_REFEREE_FEE_AGREEMENT",
  "currency": "INR",
  "distance_km": 1.11,
  "distance_basis": "STORED_PROFILE_STRAIGHT_LINE",
  "distance_unavailable_reason": null
}
```

## Configuring real source data

### Tournament metadata

The existing Admin tournament form provides **City** and **Level** controls. The owning Partner's existing create/update APIs accept those fields, with existing approval/edit restrictions. An authorized Partner can update confirmed values through:

```http
PUT /api/v1/partner/tournaments/{tournamentId}
Authorization: Bearer <partner_token>
Accept: application/json
Content-Type: application/json
```

```json
{"city":"Hyderabad","level":"Local"}
```

These are illustrative values, not defaults or an instruction to assign them to every tournament. City is limited to 100 characters; level must match the configured supported values. Referee credentials do not grant Partner/Admin editing access. No migration or read endpoint backfills historical metadata.

### Referee saved coordinates

The assigned referee uses the existing authenticated account location endpoint. User and Referee scopes share that account's `UserProfile` storage; the referee application postal address alone does not set latitude/longitude.

```http
PUT /api/v1/user/location
Authorization: Bearer <same_account_token>
Accept: application/json
Content-Type: application/json
```

```json
{"latitude":17.385044,"longitude":78.486671}
```

Send the actual confirmed coordinate pair. Both fields are required, with latitude from -90 through 90 and longitude from -180 through 180; extra fields are rejected. This update does not reverse-geocode or overwrite profile city. The request belongs in the existing **User profile** Postman collection; no cross-role duplicate is added to Referee collections. Refresh the referee match response after saving. Venue coordinates must likewise be stored against the actual selected tournament venue or eligible booking; a venue/address string alone cannot supply distance.

## Frontend and Postman handoff

Remove static `Rahul Kumar`, `₹1500` and `8.4 km` fallbacks. Render the returned name, fee and distance; when null, hide the value or display an appropriate unavailable state based on its reason. A null referee fee is not a free service. Preserve decimal-string money and format known zero values normally.

Canonical collections are updated incrementally:

- `postman/Referee/referee.php.postman_collection.json`: **30 requests retained**, saved responses **42 → 45**. Tournament examples gain reasons; missing metadata gets a separate fixture. Match requests gains 200/401 examples while retaining its 422 pagination example.
- `postman/Referee/match.php.postman_collection.json`: **23 requests retained**, saved responses **69 → 72**. Existing missing-source examples are updated in place; grounded name/distance and frozen-booking-fee examples are added.
- Existing auth, variables, folders, requests and unrelated examples are retained. The match-request script now extracts `matchId` from row `id` and `assignmentId` from row `assignment.id`, matching the API instead of confusing those IDs.

Permanent Feature regressions cover source precedence, missing/invalid coordinates, valid zero values, consistent list/detail/request projection, ownership and absence of read-side financial mutations. Canonical Postman tests cover representative source/reason examples and preserve baseline request/example coverage. Test execution results must be reported from the actual local/CI run; this note does not claim authenticated production verification or deployment.
