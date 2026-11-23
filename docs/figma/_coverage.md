# Coverage — resolved / approximated / blocked

Scope: Tournaments tab (export 09, 10, 14, 36; card variants from 05; artboards 39–43).

## Resolved

| Item | Where |
|---|---|
| Header plate 94 px: `#0A0E12` + `#6075FF0A → #274D4D0A` wash, 20 px bottom radius, 18/700 title, 44 px row | `TournamentScreenHeader` (extended) |
| Create pill 73×27, r10, blue gradient, 10 px plus, 12/700 | `TournamentActionPill` (reused) |
| Filter pills 25 px, r50, gradient hairline border, selected green + `#090C10` 700, live dot | `TournamentDotTab` (extended) + `GradientBorder` |
| Card 350×160, r16, pad 10, gap 8, `#17191E` | `TournamentListCard` (restructured) |
| Status badge 23 px, r80, gradient text over a 6 % gradient fill | `TournamentStatusChip` (extended, `textGradient`) |
| Fade divider 0.8 px (`#666` 30 % at centre) | `TournamentDivider` (extended, `gradient`) |
| 50×50 avatar, r10, `#28A166` on 10 % tint, 24/700 | `TournamentAvatar` (reused) |
| Progress: 2 px track + 3 px fill | `TournamentProgressTrack` (new) |
| Registration block: `Registration Open` / `42/64 Teams Registered` / `slots left` | `_ProgressBlock` |
| Meta strip `date · ₹entry · ₹prize` (10/400) | `TournamentMetaStrip` (new) |
| Champion ticket (4-layer gradient, medal 17 px) | `TournamentChampionTicket` (new, wired to `champions`) |
| Inline admin note + Edit pill 64×31 | `TournamentCardNote` + `_EditPill` (new) |
| Map-pin / plus / edit / medal SVGs | `packages/ui_kit/assets/tournament_icons/` via `SportoTournamentIcons` |
| Multi-fill nodes (`MULTIPLE_FILLS`: header plate, champion ticket) | reproduced as stacked `DecoratedBox` layers, not flattened |

## Approximated (declared)

| Item | Reason |
|---|---|
| `BACKGROUND_BLUR` on cards | Figma glass effect over an opaque `#17191E`; invisible in the render, so a plain fill is used |
| Edit pill label | export paints it with the blue gradient; a solid `#4FBAF0` is used (1 gradient text mask skipped for a 22 px label) |
| Badge gradient fill | export renders ~6 % alpha over the card; reproduced with the same stops at 6 % |
| Card avatar initials | derived from the tournament name (`MS`), the export shows a logo-based `MC` |

## Blocked — data the API does not return

| Export field | API status | What the screen does |
|---|---|---|
| `63 matches scheduled` | no scheduled-match count on `PartnerTournamentResponse`; would need a per-tournament matches call | field omitted |
| `Champions — Hyd Highlanders` (completed) | no winner/champion on the tournament, prizes or a list-level endpoint | ticket component renders only when `champions` is non-null; the completed card shows the meta strip instead |
| `Venue could not be verified…` (rejected) | no rejection reason field | note renders only when a message exists; the Edit action is kept |
| `Admin Requested Changes …` (changes requested) | no admin remark field (`PartnerTournamentReviewData` has only financial summary + `can_submit`) | note omitted, Edit kept |
| `2 awaiting referee` | referee assignments per match are not loaded on the list | removed (the previous pass hard-coded it) |

Making any of these appear requires a backend field or an N+1 fetch; the screen never invents a value.

## Prize Pool (07)

### Resolved

Header (36 px back, 16/700 title, 11 subtitle with `code · name`), gold status strip, identity card
(name + green venue + pink/blue wash + blue vertical hairline), prize panel (amber total pill,
"Prize Pool", Edit →), special-prize tiles, ranked list with gold/green/orange top-3 ranks and
`#090C10` separators, shimmer + error + retry states.

### Approximated

| Item | Reason |
|---|---|
| Number grouping | the app's `formatCurrency` uses Indian grouping (`₹1,50,000`); the export sample shows western (`₹150,000`). The app convention is kept — same value, different grouping |
| Trophy | the export uses a `🏆` text node; rendered as text (system emoji font). Headless goldens show tofu because the test font set has no emoji |
| Edit arrow | export draws an 11×7 vector; reuses `SportoHomeRedesignIcons.arrowRight` tinted blue |
| Edit action | no prize-edit route exists; keeps the previous snackbar hint |
| Sponsors section | dropped from this screen: the export puts sponsors on the detail **Info** tab (03/06/08/12) where the app already renders them, so the data is not lost |

### Blocked

| Item | Reason |
|---|---|
| Placement vs award split | `PartnerTournamentPrizeResponse.category` is a display label, not an enum, so rows are split by title (`Winner`/`Runner-up`/`…Place`/`…finalist` → ranked, everything else → special tile) |
| Rank numbers | renumbered sequentially from the API order (`displayOrder`); the export sample skips #5, which is sample data, not a rule |
| Prize editing | no backend endpoint wired in the app |

## Tournament detail / Info (02, 03, 06, 08, 12)

### Resolved

Header, status strip, community card, `Tournament Details` panel (identity + sponsor + teams/fee +
start/deadline), prize banner, sponsor card with contribution tiles, venue & schedule card with the
**rounds ladder from `getRounds(id)`** and the venue carousel (`venueName`, `location`, `groundType`,
`dailyMatchCapacity`), financial summary from `review.financialSummary`, shimmer/error/retry,
pull-through navigation to Prize Pool and Venue & Schedule.

### Blocked — no API fields

| Export block | Why | Result |
|---|---|---|
| Rules line: `Knockout Format`, `Leather Ball · 3 Overs · 3 Balls/over · 5 Players/team · 20 mins Match · 10 mins Buffers` | the tournament payload has no rule values; `cricketFormConfig` only returns field *definitions* (key/name/default), not the chosen values | omitted |
| `Match Configuration` card: match duration, start time, break, lunch break | same — no per-tournament match config in the response | card omitted |
| Venue rows `Round of 64 · 32 Matches`, `Match Date`, `Start Time` | live in the workflow allocations (`rounds/{id}/allocations`), one request per round; not loaded on the Info tab | omitted (Venue & Schedule pass should load `getPlannedVenues`) |
| Admin change message (08/12) | no admin-remark field; the app detects "change/revision" in the description (pre-existing rule) | banner renders only when that text exists |

### Deviation

The app keeps its **Info / Matches / Teams / Stats / Financials** tab row, which none of the export
artboards show. Removing it would lose navigation between five working screens, so it stays — and it
accounts for a constant 44 px offset in the pixel diff.

## Venue & Schedule (04, 13, 48)

### Resolved

Header, status strip, identity card, schedule panel (teams + bracket ladder), stacked venue cards
with `Venue N` + Edit, `round_name · matchCount Matches`, venue name, city, ground type, match
date and start time — all from `tournament_venues` and `getRounds(id)`.

### Blocked / approximated

| Item | Reason |
|---|---|
| Matches per venue | the response gives `round_name` per venue but not a per-venue match count; the card shows the round's total (`round.matchCount`) |
| Bracket chip labels | the export samples team counts (`64 Teams`, `32 Teams`); the app shows the real round names from the workflow API |
| Venue editing | no edit route wired — keeps the previous snackbar hint |

## Pass 5 — Live / Assign / Player / tabs

### Resolved

Live counts (upcoming/live/completed from the tournament list), live card fields, matches tab
(filters from real rounds, bracket from `getRounds`, cards from `/matches`), teams tab (registrations
with roster size + status), financial summary (collection, sponsorship, fee, prize, net), registered
player roster.

### Blocked — no API

| Export block | Reason |
|---|---|
| Stats leaderboards (18–28) | no partner stats endpoint; only referee `/matches/{id}/scorecard` |
| Player performance figures (19) | same — no per-player stats source |
| Financial income/prize/expense ledgers (30–34) | no ledger endpoint; only `/review` summary |
| "2 awaiting referee" (01) | referee assignments are per-match; the list screen does not load matches |

### Fixed while here

`team_a_name` / `team_b_name` are now read by the match model (previously only `team_a`/`team1`/`home_team`,
so real payloads with those keys rendered "TBA").

## Not implemented (export artifacts)

| Artboard | Reason |
|---|---|
| `39`–`43_Live/Applications/Approved/Upcoming/Completed-Tournaments` | each is a 749–965 × 223 frame containing **one text node**; there is no design to build |
| `37`, `38_Cricket-Match` | tournament-detail content (`Manage Tournament`, bracket, round progress) — outside the chosen scope |
