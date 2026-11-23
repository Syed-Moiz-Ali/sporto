# Referee API consumer reference

Current display metadata: [2026-11-22 match and tournament contract](changes/2026-11-22-referee-display-metadata.md). Earlier UTC, prize and bank policies remain in the [2026-11-19 recheck completion](REFEREE_RECHECK_COMPLETION_2026_11_19.md). Notification preferences are supported through the canonical GET/PUT endpoints; bank number reveal requires fresh OTP step-up.

Owner explicitly excluded Flutter work in this task. No Flutter files were inspected or changed, and FRONTEND INTEGRATED is not claimed. This document records backend parsing/method contracts for any future consumer; REFEREE_API_CONTRACTS.md is the complete backend reference.

| Consumer area | Use | Mapping / null handling |
|---|---|---|
| Home identity | GET /api/v1/referee/dashboard | data.profile.name/profile_photo_url/rating; null rating is unrated |
| Wallet | GET /api/v1/referee/wallet | data.balance, reserved_balance, total_earned, pending_earnings, simulated_unfunded_earnings, currency; decimal strings |
| Home counters | dashboard.stats or GET /statistics | Match counts and bookings.* are different dimensions, never sum them as distinct jobs |
| Today | dashboard.today_matches/today_bookings | items and total; separate match/booking IDs; India date; preview20 |
| Requests | dashboard.recent_requests/recent_booking_requests; paginated canonical feeds | Separate assignment_id/booking_id/match_id; never infer one from another |
| Booking cards | GET /bookings/requests | booking.referee_fee or additive fee; booked_by.display_name; booking.venue_name/city; no sample fallback money/distance/customer |
| Match cards | GET /matches, /matches/{matchId}, /match-requests | customer_name from safe booker/organizer identity; nullable frozen booking fee and stored-profile straight-line distance; read source/basis and unavailable_reason fields |
| Delay | PUT /matches/{matchId}/status | Read actual delay_reason/weather/resume_at; no fake Heavy Rain or start-time fallback |
| Profile | GET /profile | profile.total_matches/rating/disputes_count and statistics; experience_years is not match count |
| History | GET /tournaments, /wallet/transactions | data.items/current_page/last_page/total, validated page/per_page |
| Match operations | Existing verify/session/toss/score paths | Follow allowed_actions/next_action, expiry/replay/conflict errors; never force toss starting roles when empty |
| Scorecard/result | Existing scorecard/result paths | team_totals object; null player_of_match/margin means unavailable, not an invented award/result |
| Bank | Existing /bank/* | Reuse current authorized bank module |
| Availability/onboarding | Existing canonical PUT/DELETE methods | No POST toggle/clear or POST address/sports aliases |

All bodies for non-upload writes are raw JSON with Content-Type: application/json and existing referee authentication. GET pagination uses query parameters. Always distinguish loading, empty, null/unavailable and failed requests. HTTP401 needs reauthentication; 403 forbidden; 404 missing/unowned; 409 invalid/stale state requires refresh; 422 field validation; 429 throttled/attempt-limited. Retry scoring mutations with existing stable event_uuid semantics; never regenerate a UUID to conceal a conflict. Refresh state after successful mutations. Display unknown distance, missing fee, unrecorded players/awards and unavailable disputes honestly.

Unsupported decorative menus (notifications, disputes, global search, CMS/legal/support) must not call invented URLs. Their product/data requirements are outside the confirmed backend model set. Any future client changes need client-source review and UI QA separately.

## Tournament and match display metadata (2026-11-22)

Tournament list/detail retain `city`, `city_source`, `level`, and `referee_fee`. Missing configured city or level now has `city_unavailable_reason:CITY_NOT_CONFIGURED` or `level_unavailable_reason:LEVEL_NOT_CONFIGURED`; those reasons are null when the values are available. Tournament `referee_fee` remains null with `referee_fee_unavailable_reason:TOURNAMENT_REFEREE_FEE_NOT_SUPPORTED`. Tournament `fee` is still registration cost, and `earnings_total` is still actual paid earnings: neither is a substitute for an agreed referee fee. Admin/Partner setup and the existing Partner update payload are documented in the [current contract](changes/2026-11-22-referee-display-metadata.md#configuring-real-source-data).

The shared match card adds `customer_name_source`, `customer_name_unavailable_reason`, `fee_source`, `fee_unavailable_reason`, `distance_basis`, and `distance_unavailable_reason`. The same fields appear in the match list, detail, match requests and dashboard match previews. `customer_name` can now use the actual tournament partner, contact name or organization when there is no named booking customer. Only name fields are used; a missing name never becomes a phone number.

`distance_km` is a rounded numeric straight-line distance between the referee account's **saved UserProfile coordinates** and the published assigned venue. A booking's coordinates are eligible only when no scheduled venue is selected. It is not a road distance or live GPS location. Existing `PUT /api/v1/user/location` saves the authenticated account's latitude/longitude pair; use the existing User profile Postman collection and the same account token. The referee application address alone does not populate those coordinates. All distance source, setup and unavailable-reason rules are in the [current contract](changes/2026-11-22-referee-display-metadata.md#stored-location-distance).

Remove static customer names, rupee amounts and kilometre values from UI fallbacks. A null value renders an unavailable/configuration state; numeric zero remains a valid distance or frozen fee. No historical tournament/match data is backfilled automatically by these read-contract changes.

## Complete backend-only award and result-margin handoff (2026-11-15)

No Flutter, Dart, UI, routing or frontend files were modified. This section is an API consumer contract for later frontend work.

### Cricket match result

`GET /api/v1/referee/matches/{matchId}/result` (Bearer `{{referee_token}}`)

Successful `data` fields include: `match_id`, `match_code`, `match_status`, `status`, `winner_team_id`, `winner_team_name`, `message`, `margin`, `margin_type`, `margin_value`, `is_walkover` and `player_of_match`.

`margin` is `"10 runs"` or `"2 wickets"` only for a completed, non-walkover, non-super-over Cricket match with a recorded ledger-version scoring state, finished second innings, a valid target, trustworthy two-team totals and a recorded winning team. `margin_type` is `RUNS` or `WICKETS`; `margin_value` is the positive integer. Otherwise these fields are `null`, and the winner message stays generic when known. This is deliberately conservative; it does not claim DLS, walkover or Super Over margin inference.

The same nullable `result_margin` and `result_message` are projected on `GET /matches` and `GET /matches/{matchId}`; the Score API retains `data.result.margin`. The scorecard returns `data.result.margin`, `margin_type`, `margin_value`. Frontend must display null as unavailable, not as zero.

### Player of the Match — explicit referee selection, not automatic scoring

`POST /api/v1/referee/matches/{matchId}/player-of-match`

Headers:
```http
Authorization: Bearer <referee_token>
Accept: application/json
Content-Type: application/json
```

Raw JSON request:
```json
{"player_user_id":123}
```

Successful response:
```json
{
  "success": true,
  "message": "Player of the Match awarded.",
  "data": {
    "match_id": 501,
    "player_of_match": {
      "user_id": 123,
      "team_id": 101,
      "name": "Player Name",
      "awarded_at": "2026-11-15T12:00:00+00:00",
      "awarded_by_referee_id": 42
    }
  }
}
```

Only the **accepted referee assigned to this match** may select the award; the Cricket match must be **COMPLETED**, and the player must be an **active, accepted member of one of the two participating team rosters**. A retry with the same player ID returns the award without a second write. A different selection cannot overwrite a saved award (409). An unauthorized user gets 404; missing bearer token gets 401; invalid/unregistered player gets 422; unfinished match gets 409. No payout, wallet credit, ledger mutation or migration is triggered.

Read the resulting nullable `player_of_match` object using:

- `GET /api/v1/referee/matches/{matchId}/result` → `data.player_of_match`
- `GET /api/v1/referee/matches/{matchId}/scorecard` → `data.player_of_match`
- `GET /api/v1/referee/matches/{matchId}` → `data.player_of_match`

Do **not** automatically select the highest scorer or assume `null` means a server error. This API currently does not implement an award correction workflow. A correction requires a separate explicitly authorized business decision.

### Updated Postman collections

Canonical directory: `postman/Referee/`. Import all five collections rather than creating parallel workspaces:

1. `referee.php.postman_collection.json` — dashboard, profile, wallet, earnings, statistics, tournaments, transactions, onboarding.
2. `match.php.postman_collection.json` — match results, **Award Player of the Match** POST, toss, score, scorecard, session and OTP.
3. `referee-booking.postman_collection.json` — booking invitations and service session.
4. `weekly_availability.postman_collection.json` — recurrence/days/slots.
5. `bank.php.postman_collection.json` — bank/UPI details and default.

Set `referee_base_url` to the actual authorized server host and `referee_token` to a test referee's bearer token. Obtain valid `matchId` and `player_user_id` from the referee's match/roster APIs; do not hardcode the illustrative sample IDs.

### Backend still deliberately unresolved

- `distance_km` remains null when valid saved referee/selected-venue coordinates are unavailable; `distance_unavailable_reason` identifies the missing source. Valid coordinates now yield a stored-profile straight-line distance, not road kilometres or live GPS.
- No referee disputes store, push-notification feed, search index, support CMS, or dynamic ads provider was introduced. These require actual product/data requirements and are not dummy endpoints.
- The full Flutter integration has not been performed; the existing app may still use hardcoded labels or unsupported HTTP methods.
- Independent authenticated production request/response smoke tests must be run with non-customer test identities even when GitHub CI/deployment is green.
