# Component reconciliation

All target widgets already exist in `apps/partner_app/lib/features/tournaments/presentation/widgets/redesign/`
(the app's tournament design system used by the detail/live/prize screens). Nothing is forked.

| Export component (`central-ui` id) | App widget | Verdict |
|---|---|---|
| `DocCard` 350×160/177/141, r16, pad 10, gap 8 (`cmp-repeat-d9e71e334e` + `d44113d5ff`) | `TournamentListCard` (`tournament_cards.dart`) | **extended** — same class + API, new internals: r16, pad 10, top status row, fade divider, 50 avatar, right-aligned date |
| Status badge 23 h, r80, gradient fill + gradient text (`cmp-repeat-ac8ea6395b`) | `TournamentStatusChip` (`tournament_visuals.dart`) | **extended** — adds `gradient`, `textGradient`, `height`, `padding`; existing solid-bg calls unchanged |
| Filter pill 25 h, r50, gradient hairline border, selected = solid green + `#0E0C08` 700 (`cmp-repeat-…`) | `TournamentDotTab` (`tournament_navigation.dart`) | **extended** — `height`, `radius`, `borderGradient`, selected text weight; dot already supported |
| Create button 73×27, r10, blue gradient, plus 8×8 (`cmp-repeat-e11bd5f681`) | `TournamentActionPill` | **reused** — existing `gradient`/`height`/`radius`/`icon` params |
| Edit pill 64×31, r10, `#090C1050`, edit-2 14×14 (`cmp-repeat-7bc443b9d4`) | `TournamentActionPill` + SVG asset | **reused** |
| Avatar 50×50, r10, `#28A166` on 10 % tint, 24/700 initials | `TournamentAvatar` | **reused** — `size: 50`, `radius`, `color`, `background`, `fontSize` |
| Fade divider (0.8 px, `#666666` 30 %, transparent ends) | `TournamentDivider` (`tournament_visuals.dart`) | **extended** — adds `gradient` |
| Progress: 2 px track `#283040` r10 + 3 px green fill (`cmp-repeat-ea13fea9a7`) | — | **new** `TournamentProgressTrack` (in `tournament_visuals.dart`). `LinearProgressIndicator` cannot render a 3 px fill inside a 2 px track. |
| Champion ticket (`SIGNATURE: MATCH TICKET`, `cmp-repeat-8ff5baca50`) — 4 layered gradients, 15×15 medal, `Champions` + winner | — | **new** `TournamentChampionTicket` (in `tournament_cards.dart`) |
| Meta strip: `date · ₹entry · ₹prize` with 2 px dots | — | **new** `TournamentMetaStrip` (in `tournament_cards.dart`), used by rejected/cancelled/completed variants |
| Admin note: 11/500 title + 10/400 body + inline Edit (`cmp-repeat-d2b80c6449`) | `TournamentBanner` exists but is a bordered 12 px panel used by the detail screen | **new** `TournamentCardNote` (inline row, no panel). Extending `TournamentBanner` with a third variant would change its detail-screen look. |
| Header 94 px, gradient + blur, 18/700 title, Create pill (`cmp-repeat-1a49f8e14c`) | `TournamentScreenHeader` (`tournament_screen_parts.dart`) | **extended** — optional `background`, `bottomRadius`, `minHeight`; defaults keep the detail/live header unchanged |
| Live section pill `Live Tournaments (n)` (screen 05) | `TournamentDotTab` (idle state + dot) | **reused** |
| Loading skeleton | `TournamentListScreenShimmer` | **reused** |
| Bottom navbar (`cmp-figma-5186745dda`, `3bd2902b12`, `22983bad25`) | `partner_main_screen.dart` shell | **untouched** — app shell, outside this screen |

## Pass 2 — Prize Pool

| Export component | App widget | Verdict |
|---|---|---|
| Ranked prize row 31 px, 18×18 r6 rank chip, gold/green/orange top 3 | `TournamentPrizeRow` | **extended** — compact row, gradient rank chip, muted 4+ |
| Prize panel · special-prize tile · status strip · identity card | private compositions in `prize_pool_redesign_screen.dart` (`_PrizeCard`, `_SpecialPrizeTile`, `_StatusStrip`, `_IdentityCard`) | screen-local compositions of shared tokens/chips/rows (not reusable across screens) |
| Header: 36 px back, 16/700 title, 11 subtitle | `TournamentScreenHeader` | **extended** — `titleSize`, `subtitleSize`, `backSize`, `backBackground`, `backGap` (defaults unchanged) |
| Gradient hairline | `GradientBorder` (moved into `tournament_visuals.dart`) | **reused** by the badge and both prize cards |

## Pass 3 — Tournament detail / Info

| Export component | App widget | Verdict |
|---|---|---|
| Status strip (badge · sport · date) | `TournamentStatusStrip` | **new, shared** (extracted from the prize screen; one implementation for detail + prize) |
| Identity card (name + venue + optional sponsor) | `TournamentIdentityCard` | **new, shared** (extracted from the prize screen) |
| Rounds ladder from `getRounds` | `_BracketStrip` | screen-local composition |
| Header with 36 px back / 16 px title / Edit chip | `TournamentScreenHeader` + `TournamentActionPill` | **reused** (extended in pass 2) |

## Pass 4 — Venue & Schedule

| Export component | App widget | Verdict |
|---|---|---|
| Bracket ladder panel | `TournamentBracketStrip` | **extended** — now takes `rounds` from `getRounds` instead of the hard-coded 64→32→16 ladder; used by Info, Venue and Matches tabs |
| Venue card (r12, `#283040@30`, two fade dividers, right-aligned rows) | `TournamentVenueCard` | **extended** — restyled to the export; same parameters |
| Status strip / identity card | `TournamentStatusStrip`, `TournamentIdentityCard` | **reused** (shared from pass 2) |

## Pass 5 — last screens

| Export component | App widget | Verdict |
|---|---|---|
| Live card | `LiveTournamentCard` | **extended** — rows made flexible so 320 px + textScaler 2.0 do not overflow |
| Match card | `TournamentMatchCard` | **extended** — flexible header, referee/action row no longer overflows |
| Team card | screen-local `_TeamCard` (teams tab) | new composition (real fields: name, status, roster size) |
| Stats / financials panels | `tournament_stats_tab.dart`, `tournament_financials_tab.dart` | rewritten with real data + empty states |

## Component totals (this scope)

- Reused as-is: 6 (`TournamentActionPill`, `TournamentAvatar`, `TournamentSurface`, `TournamentListScreenShimmer`, `TournamentScreenHeader` default, `TournamentDotTab` idle)
- Extended: 5 (`TournamentListCard`, `TournamentStatusChip`, `TournamentDotTab`, `TournamentDivider`, `TournamentScreenHeader`)
- New (in the existing widgets folder): 5 (`TournamentProgressTrack`, `TournamentChampionTicket`, `TournamentMetaStrip`, `TournamentCardNote`, `GradientBorder`)

## Kill list (removed from the list screen)

- Inline `LinearProgressIndicator` in the card (replaced by `TournamentProgressTrack`)
- Inline gold "Champions" pill built from `t.gold.withValues(...)` (replaced by `TournamentChampionTicket`)
- Border-box note container (replaced by `TournamentCardNote`)
- `Row`-based card layout (replaced by the export's stacked auto-layout; no `Stack`/`Positioned` flattening)
- Hard-coded sample values `63`, `'Hyd Highlanders'`, `'2 awaiting referee'`

**Kept (not killed):** `_LiveSection` — it is the only push to `/tournaments/live`. It is restyled to the
export's `Live Tournaments (n)` pill (screen 05) instead of being deleted with the rest of the old tree.

