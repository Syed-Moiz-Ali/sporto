# Report — Tournaments tab (Figma → Flutter, integration mode)

App:        `apps/partner_app` (melos monorepo; app resolved from the export itself)
Screens:    6 artboards found for this scope → **1 REDESIGN** (4 states) · 0 NEW · 1 ASK answered
Mapping:    `docs/figma/_mapping.md`
Tokens:     14 colours reused · 7 added to `sporto_tournament_tokens.dart` · 3 drifted · 0 conflicts
Components: 5 reused · 5 extended · 5 new (in the existing `widgets/redesign/`)
Assets:     4 SVGs into `packages/ui_kit/assets/tournament_icons/` · 0 missing
Fonts:      existing 2 (Quicksand, Mulish) · added 0 · fallback 0
Scaling:    existing `context.sportoScale` (390 design width, clamp .85–1.16)

## Pixel fidelity (`tool/figma_diff.py`, threshold 6, max-pct 2)

| State | Capture vs export | Full screen | Screen body (excl. shell nav + OS status bar) | Card geometry |
|---|---|---|---|---|
| Approved / registration open (09) | `tournaments_list_approved_390x844.png` | **15.43 %** | 9.7 % | edges 147–299 / 317–469 — **identical to the export** |
| Completed (14) | `tournaments_list_completed_390x844.png` | **21.91 %** | 16.9 % | card 160 vs 141 px (ticket missing — data gap) |
| Rejected / cancelled (36) | `tournaments_list_rejected_390x844.png` | **20.95 %** | 15.8 % | card 177 vs 177 px |

All three **fail the 2 % gate**. What the number is made of (measured bands):

| Band | Diff | Cause |
|---|---|---|
| 790–844 (app navbar) | 99 % | app shell (`partner_main_screen`), not part of this screen; the export artboard includes it |
| 0–40 (status bar) | 11 % | OS status bar icons in the export |
| 94–135 (filter pills) | ~53 % | the app keeps **7** states (Applications/Approved/Draft/Live/Upcoming/Completed/Rejected); the export shows 5, and two different sets in different artboards. Sample counts also differ |
| 135–480 (cards) | 13–27 % | sample data (initials MS vs MC, `22` vs `23` slots, progress width) + the blocked fields below + 1× vs 2× font AA |
| 40–94 (header) | 9.7 % | title/pill geometry matches (±0.5 px); residual is glyph AA and the 2 px header-radius drift |

Not a claimed match: geometry is verified pixel-exact on cards, but content differences keep the
image diff above threshold. The screen itself is honest with the data it has.

## Behaviour preserved

```
flutter test test/partner_tournament_match_model_test.dart test/referee_flow_test.dart \
  test/screens_shimmer_test.dart test/tournament_creation_scheduling_test.dart \
  test/tournament_redesign_test.dart test/widget_test.dart \
  test/figma/tournaments_list_golden_test.dart test/figma/tournaments_responsive_test.dart
→ 46 tests, All tests passed!
```

- Same file, same tab index in `partner_main_screen`, same `PartnerApiBloc` reads, same routes
  (`/`, `/create-tournament`, `/tournaments/:id`, `/tournaments/live`).
- Loading shimmer, error + retry, pull-to-refresh, empty state all kept.
- `flutter analyze apps/partner_app packages/ui_kit` → no issues.

Known unrelated failure: `test/figma/booking_*_golden_test.dart` (21 tests) already fail on
`HEAD` because their golden PNGs were never committed ("non-existent file"). Untouched.

## Responsive integrity

`test/figma/tournaments_responsive_test.dart` — 320×640, 360×800, 390×844, 414×896, 768×1024,
1024×768, 1440×900, 844×390 landscape × `textScaler` 1.0 and 2.0 → **16/16 pass, no overflow**,
no clipping, fixed rows grow via `minHeight` instead of hard heights.

Targets: the export's filter pills are 25 px and the Create pill 27 px. They are kept at the export
size (pixel fidelity); the whole card (160 px) is the primary tap target. This is a declared
deviation from the 44 px guideline.

## Coverage

`docs/figma/_coverage.md` — resolved 16, approximated 4, blocked 5 (all API fields absent from
`PartnerTournamentResponse`), not implemented 7 (empty artboards + out-of-scope detail artboards).

## Pass 2 — Prize Pool (export 07)

| State | Capture | Full screen | Bands |
|---|---|---|---|
| Under Review, 6 ranked + 2 special prizes | `goldens/prize_pool_390x844.png` | **11.52 %** | header 11.2 · strip 8.4 · identity 23.2 · prize panel 17.5 · empty area 0.0 |

Geometry verified: header 45–79, strip 140, identity 162, panel 236–548 against the export's
45–79 / 140 / 162 / 236–546. Residual is 1× vs 2× text antialiasing, the 🏆 glyph (tofu in the
headless capture), Indian vs western rupee grouping, and the panel's rounded-corner AA.

Tests: `flutter test ... test/figma/prize_pool_golden_test.dart` → 48 tests pass (6 sizes × 2
text scalers for this screen included). Fixtures live in `test/figma/prize_pool_golden_test.dart`.

## Pass 3 — Tournament detail / Info (06)

| State | Capture | Full screen | Why it is above 2 % |
|---|---|---|---|
| Under Review, 390×1442 | `goldens/tournament_detail_under_review_390x1442.png` | **58.23 %** | the app keeps its tab row (+44 px offset on every section); the design's rules block, `Match Configuration` card and venue round/date rows have no API fields (~235 px of content); 1×/2× text AA |

Not claimed as a match. Structure and data wiring are correct; closing the gap needs backend fields
(rule values, match configuration) and the workflow allocations for venue rows — both listed in
`docs/figma/_coverage.md`. The bracket ladder and venue metadata that *are* available are now driven
by `getRounds(id)` and the venue payload instead of hard-coded text.

## Pass 4 — Venue & Schedule (13)

| State | Capture | Full screen | Bands |
|---|---|---|---|
| Live, 5 venue rounds, 390×1418 | `goldens/venue_schedule_390x1418.png` | **18.58 %** | header 15.2 · strip 11.7 · identity 20.7 · panel 29.0 · venue cards 16.5 |

Geometry matches the export (header/strip/identity/panel/cards); residual is text AA plus content:
the export samples "Madhapur Night Series" and team-count chips ("64 Teams → 32 Teams"), while the app
renders the real tournament name and the real round names from `getRounds`.

## Pass 5 — Live / Assign / Player / tabs

| Screen | Capture | Diff | Note |
|---|---|---|---|
| Live Tournaments (01) | `live_tournaments_390x844.png` | **41.4 %** | card gradient + missing "awaiting referee" line (no data) |
| Player details (19) | `player_details_390x1118.png` | **64.1 %** | design is all stats; identity only until a stats API exists |
| Matches tab (16) | `detail_tab_matches_390x1117.png` | **50.7 %** | real filters/bracket/cards vs the artboard's sample data |
| Teams tab (17) | `detail_tab_teams_390x1012.png` | **59.3 %** | real registrations vs the artboard's ranked sample teams |
| Stats tab (18) | `detail_tab_stats_390x844.png` | **47.6 %** | empty state by design (no stats API) |
| Financials tab (29) | `detail_tab_financials_390x844.png` | **26.0 %** | summary matches; ledger rows absent |

Demo data removed in this pass: `_demoMatches`, `_demoTeams`, `demoBattingTabs`, the player's hard-coded
innings/stats, and `'2 awaiting referee'`.

## Not done

- Before/after capture: the pre-existing screen has no data-injection seam (it reads the bloc
  directly), so a "before" render needs a bloc harness that this pass did not build. The change is
  documented by `git diff --stat` instead.
- `39`–`43`: artboards contain one text node each; nothing to build.
- Champion ticket, admin reason, scheduled-match count: wired but dormant until the API exposes
  the data (see coverage).
