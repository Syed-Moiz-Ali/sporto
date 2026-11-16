# SPORTO Referee API — Backend Gaps & Contract Notes

**Date:** 2026-11-16  
**Audience:** Backend team  
**App:** `apps/referee_app` (Flutter)  
**API base:** `https://app.spotoapp.in/api`  
**Verified against:** live authenticated referee account, Postman collections in `postman/updated/`, and Playwright E2E runs on the Flutter web build.

This document lists only **backend data/contract gaps and inconsistencies**. UI-only redesign work is explicitly marked as such.

---

## 0. Verified working (no action needed)

| Area | Endpoints | Result |
|---|---|---|
| Auth / OTP / logout | `POST /v1/referee/send-otp`, `/verify-otp`, `/logout` | Works with live credentials |
| Dashboard | `GET /v1/referee/dashboard` | Returns profile, availability, stats, wallet, today matches/bookings, recent requests |
| Profile | `GET /v1/referee/profile` | Returns profile, statistics, wallet, sports, experience, availability, application |
| Statistics | `GET /v1/referee/statistics` | Works (counts, ratings/disputes nullable) |
| Availability | `/availability/days`, `/availability`, `/availability/status`, `/availability/days/{day}`, `/availability/{slot}` | Daily/hourly CRUD, toggles, clear-day, global online status all work |
| Match list/detail | `/matches`, `/matches/{id}` | Works; teams, scores, winner, tournament, assignment present |
| Match lifecycle | `/toss`, `/score`, `/score/events`, `/session`, `/verify`, `/session/start`, `/session/end`, `/session/withdraw`, `/status`, `/result`, `/scorecard` | Works; scorecard table data is complete |
| Match requests | `/match-requests`, accept/reject | Works |
| Booking requests | `/bookings/requests`, accept/reject, `/bookings`, `/bookings/{id}`, `/bookings/{id}/session`, toss/start/end verify | Works |
| Bank CRUD | `GET /bank/list-bank-details`, `POST /bank/add-bank-details`, `PUT /bank/update-bank-details/{id}`, `POST /bank/set-default-bank/{id}`, `DELETE /bank/delete-bank-details/{id}` | **Live mutations verified** (201/200/200/200/200) |
| Bank masking | `masked_account_number`, `verification_status_label`, `is_default` | Works; app formats `******8888` → `XXXX XXXX 8888` |

### Live mutation evidence (Playwright)
- `POST /bank/add-bank-details` → **201**
- `POST /bank/set-default-bank/2` → **200**
- `PUT /bank/update-bank-details/1` → **200**
- `DELETE /bank/delete-bank-details/1` → **200**
- `DELETE /bank/delete-bank-details/2` → **200**
- `PUT /availability/status` Off → **200**, On → **200**

All test bank accounts were deleted afterwards.

---

## 1. P0 — Wallet transactions (blocks the Wallet History/Receipt UI)

**Endpoints:** `GET /v1/referee/wallet/transactions`, `GET /v1/referee/earnings`  
**Current state:** both return `items: []` for the test account and the row schema is not documented.

Please provide the populated row contract. The app needs:

| UI field | Expected JSON |
|---|---|
| Transaction id / receipt reference | `id` or `reference` / `transaction_ref` |
| Type / category | `type` or `category` (`EARNING`/`WITHDRAWAL`/`PAYOUT`/`REFUND`/…) |
| Direction | `direction` (`CREDIT`/`DEBIT`) or `credit`/`debit` |
| Amount | `amount` (number or decimal string), `currency` |
| Status | `status`, `status_label` (`PAID`, `PROCESSING`, `FAILED`, …) |
| Paid/created timestamp | `paid_at`, `created_at` |
| Payer/source | `booked_by.display_name` / `customer_name` / `source_type` (`USER`/`PARTNER`) |
| Tournament/match context | `tournament.name`, `match_id`, `match_code` |
| Description | `description` / `note` / `title` |
| Payout method | `payment_method` (`Spoto Wallet Credit`, `Bank Payout`, …) |

Also needed:
1. **`GET /wallet/transactions/{id}`** (or equivalent) for the Transaction Details screen. Today there is no way to open a receipt by id.
2. **Withdraw endpoint** (`POST /wallet/withdraw` or documented payout flow) for the Withdraw button.
3. **Statement download** (`GET /wallet/statement` / signed URL) for Download Statement.

Until these exist, the app shows an honest empty/unavailable state and the buttons say “not available yet”.

---

## 2. P0 — Tournaments history is too thin for the Figma card

**Endpoint:** `GET /v1/referee/tournaments?page=1&per_page=20`  
**Current response (live):**

```json
{
  "id": 423,
  "name": "1019 T Cricket League",
  "code": "ITA5TPTBJ3",
  "status": 7,
  "currency": "INR"
}
```

The Figma `My Tournaments` card expects:

- `venue_name` / `city`
- `start_date` / `end_date` (or a display date)
- `teams_registered` and `teams_capacity` (`41/64 Teams`)
- `fee` / `earnings` / `prize` amount
- `level` (`Local`/`State`/…) and approval label
- `status_label` (`Completed`, `Cancelled`)
- filter support: `status=completed|cancelled` (or document that client filters status 7/8)
- actions: View / Manage / Earnings endpoints, or explicit confirmation that referees must not see Manage/Earnings

If these fields are intentionally out of scope, tell the frontend which fields to remove.

---

## 3. P0 — Booking invitation detail is missing fields the list has

**Endpoint:** `GET /v1/referee/bookings/requests/{assignment_id}`  
**Current state:** the saved fixture has `assignment_id`, `booking`, `fee`, `currency`, `duration_minutes`, but **no `booked_by`**. The collection test for the list endpoint asserts `rows[0].booked_by.display_name`, so list and detail are inconsistent.

Please include consistently in both list and detail:

- `booked_by.display_name` (and optional avatar URL)
- `request_type` (`REFEREE_BOOKING`)
- Full venue address (street/locality, not just `venue_name` + `city`)
- Tournament / competition name when the booking is tied to a tournament match
- `match_code` where available
- `distance_km` only if real coordinates exist (see §5)

The app hides missing fields rather than inventing them.

---

## 4. P1 — Match cards are missing schedule / venue / margin / POTM

**Endpoints:** `GET /matches`, `GET /dashboard` (`today_matches`, `recent_requests`), `GET /matches/{id}`

Live completed match example (`SP-4199`) returns:

```json
{
  "schedule": null,
  "fee": null,
  "customer_name": null,
  "distance_km": null,
  "result_margin": null,
  "winner_team_name": "Madhapur Mavericks",
  "result_message": "Madhapur Mavericks won"
}
```

Needed:

1. `schedule` with `date`, `start_time`, `end_time`, `scheduled_start_at` (or tell us it is intentionally null for tournament matches).
2. `venue_name` and `location` on the card (currently the app shows no venue; Figma expects one).
3. `result_margin` / `margin_type` / `margin_value` for completed regulation matches. The live result endpoint also returned `margin: null`, `margin_type: null`, `margin_value: null` for a completed 55/0 vs 51/0 match.
4. `player_of_match` projection on `/result` after award (currently null). The award POST exists; the result endpoint should expose the awarded object.
5. If `fee`, `customer_name`, `distance_km` are intentionally null for tournament assignments, confirm that so the Figma fields can be dropped permanently.

The app now hides these fields when null; no fabricated values.

---

## 5. P1 — Distance / location contract

The integration guide says: **`distance_km` is null without trustworthy coordinates; never synthesize 8.4 km**. Confirmed.  
Current UI hides the distance pill when null. If you want the Figma “8.4 km” pill, provide real `distance_km` (referee ↔ venue) and a documented fallback policy. Do **not** send sample values.

---

## 6. P1 — Bank: full account number and re-verify

| Gap | Impact |
|---|---|
| List/detail return only `******9012` | Figma’s eye reveal cannot show a full number. App keeps it masked and explains. If reveal is required, add a step-up endpoint (re-auth/OTP) that returns the full number for one short-lived use. |
| No re-verify endpoint | “Re-verify Bank Account” button cannot call anything; app says “not available yet”. Add `POST /bank/reverify/{id}` or document the intended flow. |
| UPI update | `POST /bank/add-bank-details` supports `type: UPI`, but the Figma/UI form is BANK-only. If referees can have UPI-only payout rows, add a UPI form; otherwise confirm BANK-only. |
| Bank logo | Not returned; app maps known banks by name or uses a generic icon. Optional. |

---

## 7. P0 — Notification preferences API does not exist

The Figma package `notifications_settings` has 6 screens, but the Postman package has **no notification endpoints**. The app stores toggles in memory for the session only.

Need (minimum):
- `GET /v1/referee/notification-preferences`
- `PUT /v1/referee/notification-preferences`
- Per-category rows (match/tournament/team/payments/others) with stable ids, titles, descriptions, enabled state.

Until then, preferences reset on app restart/logout.

---

## 8. P1 — Analytics endpoints have no UI (not a backend gap)

These work and are wired in the data layer but have no Figma screen yet:

- `GET /matches/{id}/commentary`
- `GET /matches/{id}/graphs`
- `GET /matches/{id}/leaderboards/{category}`

No backend action required unless you want additional fields. UI is a product decision.

---

## 9. Confirmed nullability expectations

No action if intended; please confirm so the frontend can stop asking:

- `profile.rating` / `profile.disputes_count` are null until reviews/disputes exist.
- `dashboard.today_match` can be null.
- `dashboard.today_matches.items` and `today_bookings.items` can be empty.
- `scorecard.player_of_match` is null until awarded.
- `result.margin` is null for super-over/legacy/walkover matches.
- `scorecard.data_availability.status` may be `PARTIAL`/`UNAVAILABLE`; UI handles it.
- `booking.display_status` may differ from `booking_status` (`REQUESTED` vs `PENDING_PAYMENT`).

---

## 10. Manage Availability (new Figma) — **no backend gap**

The existing API already supports the new `redesign/manage_availability` screens:

- Daily mode: `PUT /availability/days/{day}` with `{"is_enabled": true|false}`
- Hourly mode: `GET /availability`, `GET /availability?day=…`, `POST /availability`, `PUT/DELETE /availability/{slotId}`
- Day chips / dots: derived from days + slots
- Add Slot sheet: `POST /availability` with `day`, `start_time`, `end_time`, `is_enabled`
- Clear day: `DELETE /availability/days/{day}`
- Global online: `GET/PUT /availability/status`

**Backend is sufficient.** The new Figma Daily/Hourly UI is now implemented and **live-tested** (day toggle PUT 200, slot toggle PUT 200, create slot POST 201, delete slot DELETE 200). No backend change is required for this screen.

---

## 11. UI/static data note (not a backend request)

To answer “is incoming request static?”:

- **No.** Home incoming requests call `/match-requests` + `/bookings/requests` live, merge into `RefereeIncomingRequestsBundle`, and poll every 20s (retry once after 1.5s when empty/error).
- The **only** static values left in production UI are non-API placeholders: “Ads Banner”, notification preference definitions (no API), profile menu labels, and copy strings.
- Test fixtures and fake models live only under `test/`.
- `BankFigmaData` / `BankAccountsStore` and `MatchLocalDataSource` remain in the repo as legacy/test helpers, but **no production screen renders them**.
- Scoring Tab static fallback names (“Jaipur Super Over”, “Thunder Titans”, etc.) were removed; it now uses the API values only.

---

## 12. Highest-value backend work, in order

1. Wallet transaction row schema + transaction detail endpoint (+ withdraw/statement if those buttons stay).
2. Tournaments row schema/filters (or confirm which fields to drop).
3. Booking detail: `booked_by`, full address, tournament/match label; make list/detail consistent.
4. Match cards: schedule/venue; result margin + player_of_match.
5. Notification preferences API.
6. Bank full-number step-up endpoint and re-verify endpoint (or confirm never needed).
7. Confirm all intentional nulls in §9.
