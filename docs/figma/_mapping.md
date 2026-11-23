# Screen mapping — Tournaments list

Matched by content, never by file name. Module first, screen second.

## Module

Only one module in `apps/partner_app` owns this flow: `lib/features/tournaments/`.
It already holds every route in the export group (`/` tab, `/create-tournament`,
`/tournaments/:id`) and the `PartnerTournamentResponse` wiring. No other feature folder
scores above 0.30. No new module.

## Export fingerprint (group 09 / 10 / 14 / 36)

| Signal | Content |
|---|---|
| Route | Tournaments tab · Create → `/create-tournament` · card → `/tournaments/:id` |
| Actions (3) | `Create`, `Edit`, open card |
| Fields (13) | status pill, tournament code, date, name, sport, venue, city, teams registered, max teams, progress, slots left, entry fee, prize |
| Copy | `Tournaments`, `Create`, `Draft`, `Live`, `Upcoming`, `Completed`, `Rejected`, `Applications (4)`, `Approved (2)`, `Registration Open`, `Teams Registered`, `slots left`, `Champions`, `Edit` |
| Structure | 94 header (gradient + 18/700 title + blue Create pill) → 25-high scrolling pill row → 160-high cards (r16: status row, fade divider, 50 avatar + 3-line meta, status block) |
| Data | list from `PartnerApiBloc`, `registeredTeams`, `maximumTeams`, `status`, `approvalStatus`, `tournamentVenues`, `registrationFee`, `totalPrizeMoney` |
| Assets | map-pin (9.88×11.2), plus (8×8), edit-2 (14×14), medal (15×15) |

## Candidate scores

Weights: route 3 · actions 2 · fields 1.5 · copy 1 · structure 1 · data 1 · assets 0.5

| Candidate file | route | actions | fields | copy | struct | data | assets | **Score** |
|---|---|---|---|---|---|---|---|---|
| `tournaments_redesign_screen.dart` (routed) | 3/3 | 3/3 | 11/13 | 0.90 | 1 | 1 | 0.5 | **0.94** |
| `tournaments_screen.dart` (legacy, unrouted) | 3/3 | 1/3 | 7/13 | 0.35 | 0.8 | 1 | 0.5 | **0.69** |
| `partner_main_screen.dart` (shell) | 1/3 | 0/3 | 2/13 | 0.20 | 0.5 | 0.5 | 0 | **0.36** |
| `tournament_detail_redesign_screen.dart` | 0/3 | 1/3 | 6/13 | 0.25 | 0.5 | 1 | 0.5 | **0.33** |

Top = 0.94, lead over runner-up = 0.25 (≥ 0.15) → **REDESIGN** `tournaments_redesign_screen.dart`.

`tournaments_screen.dart` scores well on route only because it is the older list for the same
tab; it is referenced by no route (only by `screens_shimmer_test.dart`), uses a 3-tab
`All/Draft/Published` model and a different card. It is not the target and is left untouched.

No screen falls below 0.60 → nothing is NEW.

## Per-artboard mapping

| Export | Content (verified from `text.characters`) | App target | Module | Action |
|---|---|---|---|---|
| `09_Cricket-Match` | Tournaments tab, selected `Approved (2)`, two registration-open cards (`42/64 Teams Registered`, `23 slots left`) | `tournaments_redesign_screen.dart` | tournaments | **REDESIGN done** — header plate, pill row, 160 px card |
| `10_Cricket-Match` | Identical to 09 (same nodes, different canvas x) | same | tournaments | **REDESIGN done** — duplicate variant, no extra page |
| `14_Cricket-Match` | Tournaments tab, selected `Completed`, cards with `Champions — Hyd Highlanders` ticket | same | tournaments | **REDESIGN done** — completed state; ticket dormant (see coverage) |
| `36_Cricket-Match` | Tournaments tab, selected `Rejected`, `Rejected` card with admin note + Edit, `Cancelled` card | same | tournaments | **REDESIGN done** — rejected/cancelled states, meta strip + Edit |
| `05_Cricket-Match` | Card-variant gallery (overlapping frames) | component spec only | tournaments | reference for the status badge / note / submitted variants |
| `39`–`43_*` | Title-only artboards, 749–965 × 223, one `TEXT` node each | — | — | **not implemented** — empty artboards, no design to build |

## Pass 2 — Prize Pool (export 07)

| Export | Content | App target | Action |
|---|---|---|---|
| `07_Prize-Pool` | Header (36 px back, "Prize Pool" 16/700, `code · name`), status strip (Under Review / Cricket / 05 Aug 2026), identity card (name + green venue), prize card (₹150,000 pill, "Prize Pool", Edit →, two special tiles, ranked list with gold/green/orange ranks) | `prize_pool_redesign_screen.dart` (route `/tournaments/:id/prize-pool`) | **REDESIGN done** |

Correction to the first pass: `04_Prize-Pool` and `48_Prize-Pool` are **Venue & Schedule** content
(bracket + venue rounds) despite the folder name — they belong to the Venue & Schedule screen.

## Pass 3 — Tournament detail / Info (02, 03, 06, 08, 12)

| Export | Content | App target | Action |
|---|---|---|---|
| `06_Under-Review`, `02_Live-Now`, `03_Live-Now`, `08/12_Changes-Requested` | Header (36 px back, name 16/700, code 11, Edit chip), status strip, community card, `Tournament Details` panel (identity + sponsor + teams/fee + dates), prize banner, sponsor card, venue & schedule (bracket + venue carousel), financial summary | `tournament_detail_redesign_screen.dart`, `tournament_info_tab.dart` (tabs Info/Matches/Teams/Stats/Financials kept) | **REDESIGN done** |

Added real data during this pass: `getRounds(id)` from the existing workflow API drives the bracket
ladder; venue cards show `groundType` + `dailyMatchCapacity`; the financial summary keeps the
`review.financialSummary` payload.

## Pass 4 — Venue & Schedule (04, 13, 48)

| Export | Content | App target | Action |
|---|---|---|---|
| `13_Venue-Schedule` (+ `04`, `48` scrolled variants) | Header, status strip, identity card, `Venue & Schedule` panel (teams + bracket ladder), stacked venue cards (`Venue N`, round · matches, venue, city, ground type, match date, start time) | `venue_schedule_redesign_screen.dart` (route `/tournaments/:id/venue-schedule`) | **REDESIGN done** |

Real data: `tournament_venues` already carries `round_name`, `date`, `start_time`,
`ground_type`; per-round match counts come from `getRounds(id)`. The old screen faked them
(`'Round of ${maxTeams}'`, `'maxTeams ~/ 2 Matches'`, `'08:00 PM'`).

## Pass 5 — Live Tournaments, Assign Referee, Player details, detail tabs

| Export | Content | App target | Action |
|---|---|---|---|
| `01` Live Tournaments | Header + live card (badge, code, date, teams, slots, Upcoming/Live/Completed strip, Open/Monitor) | `live_tournaments_redesign_screen.dart` | **REDESIGN done** — real counts, fake "awaiting referee" removed |
| `11` Assign Referee | Tournament context + match summary + referee picker | `assign_referee_screen.dart` | **header aligned**; picker flow untouched (already API-wired) |
| `19` Player details | Player header + batting/bowling blocks | `player_details_redesign_screen.dart` | **REDESIGN done** — identity real, stats blocked |
| `16/37/38` Matches tab | Round filters, bracket, match cards | `tournament_matches_tab.dart` | **REDESIGN done** — demo matches removed |
| `17` Teams tab | Team filters + team cards | `tournament_teams_tab.dart` | **REDESIGN done** — demo teams removed |
| `18–28` Stats tab | Leaderboards | `tournament_stats_tab.dart` | **empty state + registered-player list** (no stats API) |
| `29–34/47` Financials | Summary + ledgers | `tournament_financials_tab.dart` | **summary real**, ledgers blocked |

## Route / wiring preserved

Same file, same tab index, same `PartnerApiBloc` reads, same `push` targets. No route table
change.
