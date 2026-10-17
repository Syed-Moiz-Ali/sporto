# UI Migration Plan — Figma "🏏 SPOTO (Copy) / User App" → Flutter

Date: 2026-10-18
Branch: `new_changes`
Source of truth: `new_screens/SPOTO_(Copy)_Dev_Export*/` (JSON + assets). JSON wins over any eyeballing.
Status: **PLAN ONLY — no app code written yet.** Awaiting Phase 5 quiz answers + explicit approval.

---

## 0. Context / critical findings (read first)

1. **The repo is a Melos monorepo**, not a single app:
   - Apps: `apps/partner_app`, `apps/referee_app`
   - Packages: `packages/ui_kit` (design system), `packages/core`, `packages/shared_domain`, `packages/partner_data`, `packages/referee_data`
2. **State management is `flutter_bloc` (Full Bloc + Equatable), NOT Riverpod.** Routing is `go_router`.
   The task brief said "Riverpod expected" — audit shows Bloc. Plan assumes Bloc unless told otherwise.
3. **There is no `user_app`.** The exported screens belong to the Figma page **"User App"**, which the previous audit (`docs/figma_flutter_ui_audit_report.md`) explicitly **excluded** as "owned by another developer". **Destination app is unresolved — blocking question.**
4. **No backend exists for this flow.** `SportoApiEndpoints` has no booking / sponsorship-booking / payment endpoints. Only tournament-level sponsorship exists (`TournamentSponsorRequest`). So these screens cannot be "wired to existing logic" — there is none. **Data source is a blocking question.**
5. **Palette conflict.** Figma User App is **green-primary** (`#2BB673`, canvas `#090C10`). Centralized `SportoDesignTokens.dark` is **orange-primary** (`#ED7B00`, canvas `#0E0C08`). Existing partner screens already bypass tokens with many hardcoded greys/greens. **Token strategy is a blocking question.**
6. **`flutter_svg` is NOT a dependency.** All Figma icons/illustrations are SVG (+ PNG @2x previews). Must be added.
7. Figma frames embed a **mock status bar** (time "20:23", signal/wifi/battery as `Group 2`, `Group 1000003334`, `20:23`, `Frame 1000003335`). These must **not** be implemented — use the real system status bar.
8. **No loading / error / empty / skeleton designs exist** in any JSON. They must be proposed from existing tokens (Phase 6 rule).

---

## 1. PHASE 1 — Existing app audit (read-only)

### 1.1 Architecture & conventions

| Concern | Finding | Path |
|---|---|---|
| Monorepo tool | Melos 6 | `melos.yaml` |
| Apps | partner_app, referee_app | `apps/*` |
| Design system pkg | `ui_kit` | `packages/ui_kit` |
| State mgmt | flutter_bloc 8.1.3 (Bloc, Equatable) | apps, `packages/core/lib/src/theme/theme_bloc.dart` |
| Routing | go_router 14.8.1, single route table | `apps/partner_app/lib/app/router/app_router.dart` |
| DI | service-locator singleton `DependencyInjector.instance` | `apps/partner_app/lib/core/di/dependency_injector.dart` |
| Feature layout | `features/<feature>/presentation/{screens,widgets}`, `application/` (bloc) | `apps/partner_app/lib/features` |
| HTTP | Dio via `SportoApiClient`, endpoints in one class | `packages/core/lib/src/network/` |
| Fonts | Quicksand (default), Space Grotesk, Inter, Mulish (local .ttf) | `packages/ui_kit/assets/fonts` + pubspec |
| Goldens | `packages/ui_kit/test/figma/` (viewport 390x844, DPR 1) | `melos run test_ui` |
| Analyze | `melos run analyze` → `flutter analyze --no-fatal-infos` | `melos.yaml` |

### 1.2 Existing color tokens — `SportoDesignTokens.dark`
`packages/ui_kit/lib/src/theme/sporto_design_tokens.dart`

| Token | Value | Notes |
|---|---|---|
| canvas | `#0E0C08` | |
| card | `#171717` | |
| cardElevated | `#1C2026` | |
| field | `#1A1F24` | |
| fieldBorder | `#35424E` | |
| fieldBorderFocused | `#4FBAF0` | |
| authFieldBorder | `#31516B` | |
| border | `#283040` | |
| muted | `#92949A` | |
| live | `#FF4B50` | state |
| upcoming | `#FF6C4A` | state |
| assigned | `#3ED48E` | state |
| info | `#54C2F3` | |
| liveCardStart / End | `#3A0E07` / `#28100C` | |
| authBadge | `#E6261808` | |
| actionOrange | `#FF4B00` | |
| navSurface | `#1D1C19` | |
| primaryGradient | `#ED7B00 → #CF9E24` | matches Figma orange gradient |
| ambientGradient | blue/pink subtle radial-ish | |
| authPanelGradient / authBackgroundGradient | dark blends | |

Only a **dark** token set exists (`static const dark`). No light `SportoDesignTokens`.

### 1.3 Theme-level colors — `SportoTheme`
`packages/ui_kit/lib/src/theme/sporto_theme.dart`

| Name | Value |
|---|---|
| _primary | `#ED7B00` |
| _gold | `#CF9E24` |
| _green | `#2BB673` |
| _blue | `#4FBAF0` |
| _red | `#FE464B` |
| light bg/surface | `#F8F9FA` / `#FFFFFF` |
| light onSurface / variant | `#0F172A` / `#475569` |

Runtime: `MaterialApp` sets `theme: SportoTheme.darkTheme` **and** `darkTheme: SportoTheme.darkTheme` → app is always dark.

### 1.4 Layout tokens — `SportoLayoutTokens.figma`
`packages/ui_kit/lib/src/theme/sporto_design_tokens.dart`

- space: 2, 4, 6, 8, 10, 12, 16, 20, 24, 30
- radius: 4, 8, 10, 12, 14, 16, 18, 20
- cardShadow: `0x1A000000, blur 8, offset (0,2)`
- `context.sportoScale` = width/390 clamped (0.92–1.0 below 360, 1.0–1.16 above) → **390 is already the base frame**.
- `context.sportoSize(figmaValue)` = figmaValue * scale.

### 1.5 Typography
`SportoTheme._textTheme`: display 32/26/22, headline/title 18, title 16, body 16/15/13, label 15/14/13 — all Quicksand, weights 500/600. Global **`SportoAppTextScale` lifts all text by ×1.12** (`sporto_screen_shell.dart`).

### 1.6 Shimmer / skeleton (existing)
`packages/ui_kit/lib/src/widgets/sporto_shimmer.dart`
- `SportoShimmer(width, height, borderRadius)` — animated opacity 0.08→0.22, 1000ms, `cs.onSurface` base. **Hardcoded** duration/opacity/curve → must be tokenized per task rule 3.
- `SportoSkeletonCard(height, borderRadius)`

### 1.7 Existing reusable widgets (all in `packages/ui_kit/lib/src/widgets/`, exported from `ui_kit.dart`)

| Widget | File | Relevance to new screens |
|---|---|---|
| SportoCard / GlassContainer | sporto_card.dart, glass_container.dart | card shells (M) |
| SportoScreenShell / SportoAppTextScale / SportoAppBackgroundScope | sporto_screen_shell.dart | page shell (M) |
| SportoResponsiveContent / SportoResponsiveMetrics | sporto_responsive_layout.dart | responsive padding (R) |
| SportoAmbientBackground | sporto_ambient_background.dart | backdrop (R) |
| SportoGradientCard | sporto_gradient_card.dart | gold/green gradient cards (M) |
| SportoSegmentedControl | sporto_segmented_control.dart | "Shape" / booking-type toggle (M) |
| SportoFilterChip | sporto_filter_chip.dart | sort chips, date/time chips (M) |
| SportoTabChip | sporto_tab_chip.dart | Upcoming/Ongoing (M) |
| SportoStatCard | sporto_stat_card.dart | stat chips (M) |
| SportoSectionTitle | sporto_section_title.dart | section headers (R) |
| SportoDivider | sporto_divider.dart | hairlines (R) |
| SportoBadge | sporto_badge.dart | status pills (M) |
| SportoPillButton | sporto_pill_button.dart | |
| PrimaryButton / SecondaryButton | primary_button.dart, secondary_button.dart | CTA (M) |
| SportoTextField | sporto_text_field.dart | location/search fields (M) |
| SportoSelectableBox / SportoCheckBox / SportoCheckCircle | — | sport cards, rating (M) |
| SportoInfoRow / SportoSummaryRow / SportoCounterRow | — | label/value rows (R) |
| SportoBottomNav / SportoBottomTabShell | — | not used by this flow (single screens) |
| SportoQuickAction / SportoBadge / SportoBulletPoint | — | bullet lists (R) |
| SportoStatCard | — | stat chips (R) |
| SportoMatchCard / SportoCricketMatchCard / SportoTeamVerificationCard / SportoRefereeProfile / SportoProfileTab | — | reference patterns only |
| SportoShimmer / SportoSkeletonCard | sporto_shimmer.dart | loading (M) |
| GlassModal / GlassNavBar / SyncIndicatorBadge | — | dialogs (R) |

(M = reuse with modification, R = reuse as-is or reference)

### 1.8 Existing icon/asset model
- `SportoAssets` (`packages/ui_kit/lib/src/assets/sporto_assets.dart`) exposes **PNG-only** icon paths + `SportoAssetIcon`.
- `ui_kit/assets/{icons,images,backgrounds,fonts}`, plus an **empty `assets/booking/`** subfolder (icons/illustrations/images) — a stub awaiting this work.
- No SVG pipeline anywhere.

### 1.9 Convention summary (to mimic)
- Widget files: `sporto_*.dart` (snake_case), one public widget per file, doc comment header.
- Feature screens: `features/<feature>/presentation/screens/<name>_screen.dart`.
- Blocs: `features/<feature>/application/<name>_bloc.dart` (Bloc, not Cubit), Equatable states.
- Tokens accessed via `context.sporto` / `context.sportoLayout` / `context.sportoScale`.
- No comments rule: this repo *does* use comments in tokens/widgets; we will match existing local style where present, but the migration rule "no comments unless asked" will be followed for new screen code.

---

## 2. PHASE 2 — Figma analysis (read-only)

### 2.1 Packages

| Folder | Screens | Totals |
|---|---|---|
| `new_screens/SPOTO_(Copy)_Dev_Export` | 17 | 590 assets (405 svg / 178 composed-svg / 7 raster), 1587 nodes |
| `new_screens/SPOTO_(Copy)_Dev_Export_2` | 4 | 133 assets (83 svg / 46 composed-svg / 4 raster), 410 nodes |

- Figma file: `🏏 SPOTO (Copy)`, page `User App` (`0:1`).
- **Base frame: 390 px wide.** Heights 844 (viewport) / 935 / 976 (scroll states).
- JSON top-level: `schema, packageContext, source, guidance, developerSummary, assetIndex, warnings, assetManifest, variableCollections, variables, nodes`.
- **`variables`/`variableCollections` are empty** → colors/type are inline per node; aggregated via `developerSummary.designSystemObserved`.
- `nodes` is a tree (root frame + nested `children`). `isAsset:true` marks exported asset nodes.

### 2.2 Screen inventory (JSON names are all ambiguous — see proposed identity)

| # | Folder | Figma name | Size | Proposed identity (draft) |
|---|---|---|---|---|
| E1-01 | 01_Referees | Referees | 390x844 | Referee bookings list / "Book A Referee" home |
| E1-02 | 02_Referees | Referees | 390x844 | Referee home — sport summary + status rows |
| E1-03 | 03_Referees | Referees | 390x844 | Select Sport (grid) |
| E1-04 | 04_Referees | Referees | 390x844 | Game Location (unspecified / search) |
| E1-05 | 05_Referees | Referees | 390x844 | Game Location — current location state |
| E1-06 | 06_Referees | Referees | 390x844 | Game Location — venue selected state |
| E1-07 | 07_Referees | Referees | 390x844 | How would you like to book? (Quick/Full day) |
| E1-08 | 08_Your_Sponsorship | Your Sponsorship | 390x844 | Booking type + Date/Time/Duration selectors |
| E1-09 | 09_Confirm_Booking | Confirm Booking | 390x935 | Confirm Booking (booking summary + payment) |
| E1-10 | 10_Payment | Payment | 390x844 | Payment method selection |
| E1-11 | 11_Cricket_Match | Cricket Match | 390x976 | Booking success (sport artwork) |
| E1-12 | 12_Your_Sponsorship | Your Sponsorship | 390x844 | Booking type variant (other toggle default) |
| E1-13 | 13_Your_Sponsorship | Your Sponsorship | 390x844 | Choose Referee (sortable list) |
| E1-14 | 14_Confirm_Booking | Confirm Booking | 390x935 | Referee Profile |
| E1-15 | 15_Confirm_Booking | Confirm Booking | 390x935 | Booking Summary (with OTP) |
| E1-16 | 16_Payment | Payment | 390x844 | Payment variant |
| E1-17 | 17_Cricket_Match | Cricket Match | 390x976 | Booking success variant |
| E2-01 | 01_Booking_Details_-_Upcoming | Booking Details - Upcoming | 390x935 | Booking Details — Upcoming |
| E2-02 | 02_Booking_Details_-_Ongoing | Booking Details - Ongoing | 390x935 | Booking Details — Ongoing |
| E2-03 | 03_Booking_Details_-_Completed | Booking Details - Completed | 390x935 | Booking Details — Completed |
| E2-04 | 04_Booking_Details_-_Completed | Booking Details - Completed | 390x844 | Rate & Review |

### 2.3 Observed design tokens (aggregated across all screens)

**Colors (by frequency):** `#FFFFFF`(512) · `#A0A0A0`(175) · `#090C10`(23) · `#2BB673`(60) · `#1C2026`(42) · `#666666`(27) · `#F4B41A`(13) · `#17191E`(11) · `#090C1033`(15) · `#28A1661A`(11) · `#F3EEE214`(18) · `#0E0C08`(10) · `#12161C`(5) · `#1B2335`(12+alpha) · plus state alphas `#2BB6730F/33`, `#F4B41A0F/14/33`, `#E1263F0F`, `#1C202666`, `#28304080`, `#31313580`, `#00D816`(green status), `#FEFEFE`.

**Typography:** 100% **Quicksand**. Weights 400/500/600/700. Sizes: 10(34) 11(21) 12(155) 13(16) 14(103) 15(9) 16(34) 18(1) 24(2) 28(9) 40(2) 64(2). Line heights in JSON (~1.2–1.4).

**Radii:** 16(65) · 3(34) · 10(28) · 14(26) · 40(24) · 20(13) · 30(9) · 12(3) · 50/60(pills) · 13.16 & 4.44 (derived aspect values).
**Spacing:** 2(136) 4(112) 6(118) 8(100) 10(297) 12(96) 14(148) 16(74) 20(149) 30(7).

**Gradients (authoring `GRADIENT_LINEAR` unless noted):**
- `#7AD3FF → #4FBAF0` (blue accent, 28+9)
- `#FFD572 → #FEBD38` (gold accent, 27+17)
- `#FF58DD → #DC65AC` (pink, 15+8)
- `#ED7B00 → #CF9E24` (orange CTA — equals existing `primaryGradient`, 15)
- `#FF9364 → #F25F33` (5+2)
- `#FE6C6C → #FE464B` (3, export 2)
- radial: `#F2B705` gold glow, `#E1263F` red glow

**Shadows / effects:**
- `BACKGROUND_BLUR 20` (glass cards) — most frequent; `BACKGROUND_BLUR 100` (sticky header)
- `DROP_SHADOW 0,2 blur4 @12%` and `0,1 blur2 @20%` (buttons), `0,2 blur8 @10%` (cards)
- `DROP_SHADOW 2,10 blur30 #ED7B00@35%` (primary CTA glow)
- `DROP_SHADOW 0,2 blur10 #2BB673@50%` (status dot glow)
- `INNER_SHADOW 0,1 blur0 spread1 #FFFFFF@6%` (glass top highlight)

### 2.4 Component / pattern extraction (recurring across screens)

| Figma pattern | Where | Notes |
|---|---|---|
| Mock status bar (`Group 2`,`Group 1000003334`,`20:23`,`Frame 1000003335`) | every screen | **do not implement** |
| Sticky glass header: back button (36x36, r10) + title + optional subtitle; pad 4/20; `BACKGROUND_BLUR 100`; height 90 (incl. status area) | all | → shared `SportoAppBar`/`BookingTopBar` |
| `Controls` CTA (270x48, r16, gradient `#ED7B00→#CF9E24`, glow) | 08,09,10,12,15,16 | primary CTA |
| `DocCard` (glass; variants: fill gradient / `#1C2026` / `#17191E`; r16) | all | → shared `GlassDocCard` |
| Sport/location "SIGNATURE: MATCH TICKET" header card (r20, gradient, sport icon 17x15.6 + name) | 05,06,07,08,09,10,12,13,14,15,16 | → shared `VenueHeaderCard` |
| Booking status pill (`Frame 1261154583` r50 gradient; clock icon + Upcoming/Ongoing/Completed) | 01,02,09? | → `StatusPill` |
| Referee/venue list card (`DocCard` 350x70/73/77/94; 50x50 avatar `#28A166`, r13.16; name; green sport + dots; level; price/distance right column) | 01,02,11,13,14,15,16,17 | → `RefereeListCard` / `VenueListCard` |
| Date/Time/Duration stat chips row (chips r40 `#F4B41A` selected / `#1C2026` unselected) | 08,12 | → `ChoiceChipRow` |
| Sort chip row (r10 pills, green selected) | 13 | → `SortChipRow` |
| Payment method tiles (167x50/350x50 r14/16 `#1C2026`; icon + label) | 10,16 | → `PaymentMethodTile` |
| Payment summary card (label/value rows + hairline + total in gold) | 09,10,11,15,16,17 | → `PriceSummaryCard` |
| Stat chips (107.3x54.6, `STAT CHIPS`) | 14 | → `StatChip` |
| Star rating row (5x 32.7x31.1) | E2-04 | → `StarRating` |
| Selectable tag chips (`Bars / Nav Bars: Large` 283040 bg r14, gradient border) | E2-04, 11, 17 | → `TagChip` |
| Segmented "Shape" toggle (248x46 r60) | 08,12 | → reuse `SportoSegmentedControl` |
| Booking Details sticky header + sections | E2-01..04 | `BookingDetailSection` |
| Booking location row (green pin 18x18 + text) | E2-01..04, 05,06,07 | reuse |

### 2.5 Asset inventory

| Metric | E1 | E2 |
|---|---|---|
| Asset instances | 590 | 133 |
| svg / composed-svg / raster | 405 / 178 / 7 | 83 / 46 / 4 |
| Distinct `nodeName` | 46 (mostly meaningless: `Vector` ×256, `Group …`, `Line n (Stroke)`) | 22 |

**Problems to fix during asset migration:**
- **Generic names** (`Vector`, `Group 1000003334`, `Line 3 (Stroke)`) → must be renamed semantically (`ic_back`, `ic_gps`, `ic_clock`, `ic_chevron_right`, `sport_cricket`, …).
- **Duplicates across screens** — the same clock/gps/back icons are re-exported per screen with different node ids (e.g. `clock` in 6 screens). Must be de-duplicated into one library.
- **Mock status-bar assets** must be dropped (all `Group 2 / Group 1000003334 / 20:23 / Frame 1000003335 / Frame 1000003339 / Line n (Stroke)` under the status group).
- **`composed-svg`** = multi-vector decorative groups → prefer as single SVG (per guide) — e.g. wifi/battery/status, sport icon compositions.
- **Raster**: only one real image — `image-1-c0944a2003.jpg` (1024x1024) used as the referee avatar ("Frame 2", 40/50x50) in ~7 screens. Needs 1x/2x/3x downscales + a neutral placeholder.
- `png/` and `composed/png/` are **@2x previews/debug only** — not for shipping (SVG is the shipping form).

### 2.6 Missing states in Figma (must be proposed, not invented silently)

None of the 21 JSONs contain: **loading / skeleton shimmer, error, empty, offline, retry, pagination, pull-to-refresh, disabled, focused, validation-error** frames. Screens with **data lists** that need these: E1-01 (bookings list), E1-13 (referee list), E1-03 (sports grid), E1-10/16 (payment methods), E2-01..04 (booking detail). Also the whole flow implies async create-booking + payment states (in-progress, success, failure).

---

## 3. PHASE 3 — Token & component mapping

Legend: **MATCH** = reuse existing token; **DIFFERS** = ask (update vs add); **MISSING** = propose new (existing naming style).

### 3.1 Color mapping

| Figma value | Role | Existing token | Verdict |
|---|---|---|---|
| `#0E0C08` | canvas (rare) | `SportoDesignTokens.canvas` | **MATCH** |
| `#090C10` | canvas (dominant) | — | **DIFFERS** vs canvas `#0E0C08` → new token or update? |
| `#1C2026` | cardElevated / surface | `cardElevated` | **MATCH** |
| `#17191E` | card (list rows) | `card` `#171717` | **DIFFERS** |
| `#12161C` | section bg | — | **MISSING** |
| `#1B2335` | panel bg / border | — | **MISSING** |
| `#283040` | border / grey chip | `border` | **MATCH** |
| `#313135` | icon tile bg | — | **MISSING** |
| `#A0A0A0` | text secondary | `muted` `#92949A` | **DIFFERS** |
| `#666666` | text tertiary | — | **MISSING** |
| `#FFFFFF` / `#FEFEFE` | onSurface | `ColorScheme.onSurface` | **MATCH** |
| `#2BB673` | brand green / accent | `SportoTheme._green` (theme-level, not a token) | **DIFFERS** → promote to token? |
| `#28A166` | avatar bg | — | **MISSING** |
| `#F4B41A` | gold (selected chip) | `_gold` `#CF9E24` | **DIFFERS** |
| `#F3EEE2` | warm hairline/border | — | **MISSING** |
| `#00D816` | status dot green | — | **MISSING** (or use `assigned` `#3ED48E`?) |
| `#E1263F` | red (inner glow/avatar) | `live`? `#FF4B50` | **DIFFERS** |
| `#ED7B00 → #CF9E24` | primary CTA gradient | `primaryGradient` | **MATCH** |
| `#7AD3FF → #4FBAF0` | blue accent gradient | — | **MISSING** |
| `#FFD572 → #FEBD38` | gold accent gradient | — | **MISSING** |
| `#FF58DD → #DC65AC` | pink accent gradient | — | **MISSING** |
| `#FF9364 → #F25F33` | orange accent gradient | — | **MISSING** |
| `#FE6C6C → #FE464B` | red accent gradient | — | **MISSING** |

### 3.2 Spacing / radius / shadow / typography

| Figma | Existing | Verdict |
|---|---|---|
| space 2/4/6/8/10/12/16/20/30 | all present | **MATCH** |
| space 14 (148 uses) | *absent* (12→16 gap) | **MISSING** → add `space14` |
| radius 4/8/10/12/14/16/18/20 | all present | **MATCH** |
| radius 40 / 50 / 60 (pills) | — | **MISSING** → add `radiusFull`(pill) or explicit |
| radius 30 | — | **MISSING** |
| radius 13.16 / 10.53 / 4.44 | derived (icon tiles) | keep local (unique values), not tokens |
| card shadow `0,2 b8 @10%` | `cardShadow` `0x1A000000` | **MATCH** (0x1A≈10%) |
| btn shadow `0,1 b2 @20%`, `0,2 b4 @12%`, CTA `2,10 b30 #ED7B00@35%` | — | **MISSING** → add shadow tokens |
| blur 20 (glass), blur 100 (header) | `SportoCard.defaultBlur=14` | **DIFFERS** (14 vs 20) |
| fonts Quicksand 400/500/600/700 | present | **MATCH** |
| sizes 10/11/12/13/14/15/16/18/24/28/40/64 | theme has 13/15/16/18/22/26/32 | **MISSING** for 10,11,12,14,24,28,40,64 → propose a `SportoTextStyles` (or extend TextTheme) |

### 3.3 Component mapping

| Figma pattern | Map to | Verdict |
|---|---|---|
| Sticky glass header | new `SportoBookingAppBar` (uses SportoCard glass + back asset) | create (or extend a shared shell) |
| `DocCard` glass card | `SportoCard` | reuse (modify: gradient fill option, per-variant fill/border/blur) |
| `Controls` CTA | `PrimaryButton` | reuse (modify: radius 16, gradient, glow) |
| Booking status pill | `SportoBadge` + gradient | reuse + extend |
| Tabs Upcoming/Ongoing | `SportoTabChip` / `SportoSegmentedControl` | reuse |
| Choosable chips (Date/Time/Duration) | `SportoFilterChip` | reuse (modify radius 40/gold selected) |
| Sort chips | `SportoFilterChip` | reuse |
| Stat chips | `SportoStatCard` | reuse (modify) |
| Sport grid card | `SportoSelectableBox` | reuse + extend |
| Venue/referee list row | new `RefereeListTile` / `VenueListTile` | create |
| Payment method tile | new `PaymentMethodTile` | create |
| Price summary rows | `SportoSummaryRow` | reuse |
| Star rating | new `StarRating` | create |
| Tag chip (`Bars / Nav Bars`) | `SportoFilterChip` (pill) | reuse |
| Shimmer/skeleton | `SportoShimmer`/`SportoSkeletonCard` | reuse + tokenize + add per-component skeletons |
| Error view | new `SportoErrorView` | create |
| Empty view | new `SportoEmptyView` | create |
| Async switch wrapper | new `AsyncStateView` (bloc-aware: `BlocBuilder<B, S>` + state enum or `AsyncValue`-like) | create |

---

## 4. PHASE 4 — Written plan

### 4.1 Screen-by-screen — FINAL (19 screens: Package 1 = 17 distinct, Package 2 = merged)

Destination: `apps/partner_app` (decision 1). Feature module: `features/referee_booking/`. Package 1 exports stay distinct (17). Package 2's Booking Details Upcoming/Ongoing/Completed are **merged into ONE status-driven screen** (round-2 decision); Rate & Review stays separate → 2 screens. Shared UI extracted into base widgets so repeated layouts share code.

| # | Figma folder | Screen title (from JSON) | Flutter file | Route |
|---|---|---|---|---|
| 1 | E1-01_Referees | Book A Referee (bookings list) | `booking_list_screen.dart` | `/book-referee/bookings` |
| 2 | E1-02_Referees | Book A Referee (sport summary) | `booking_overview_screen.dart` | `/book-referee/overview` |
| 3 | E1-03_Referees | Select Sport | `select_sport_screen.dart` | `/book-referee/sport` |
| 4 | E1-04_Referees | Game Location (search) | `game_location_screen.dart` | `/book-referee/location` |
| 5 | E1-05_Referees | Game Location (current location) | `game_location_current_screen.dart` | `/book-referee/location/current` |
| 6 | E1-06_Referees | Game Location (venue selected) | `game_location_venue_screen.dart` | `/book-referee/location/venue` |
| 7 | E1-07_Referees | How would you like to book? | `booking_options_screen.dart` | `/book-referee/options` |
| 8 | E1-08_Your_Sponsorship | Booking Type (quick) | `booking_type_quick_screen.dart` | `/book-referee/type/quick` |
| 9 | E1-09_Confirm_Booking | Confirm Booking | `confirm_booking_screen.dart` | `/book-referee/confirm` |
| 10 | E1-10_Payment | Payment (methods) | `payment_methods_screen.dart` | `/book-referee/payment` |
| 11 | E1-11_Cricket_Match | Booking Success A | `booking_success_a_screen.dart` | `/book-referee/success/a` |
| 12 | E1-12_Your_Sponsorship | Booking Type (full day) | `booking_type_fullday_screen.dart` | `/book-referee/type/fullday` |
| 13 | E1-13_Your_Sponsorship | Choose Referee | `choose_referee_screen.dart` | `/book-referee/referee` |
| 14 | E1-14_Confirm_Booking | Referee Profile | `referee_profile_screen.dart` | `/book-referee/referee/:id` |
| 15 | E1-15_Confirm_Booking | Booking Summary | `booking_summary_screen.dart` | `/book-referee/summary` |
| 16 | E1-16_Payment | Payment (variant B) | `payment_methods_b_screen.dart` | `/book-referee/payment/b` |
| 17 | E1-17_Cricket_Match | Booking Success B | `booking_success_b_screen.dart` | `/book-referee/success/b` |
| 18 | E2-01/02/03 Booking Details (Upcoming/Ongoing/Completed) | **Booking Details (merged, status-driven)** | `booking_details_screen.dart` | `/bookings/:id` |
| 19 | E2-04_Booking_Details_-_Completed | Rate & Review | `rate_review_screen.dart` | `/bookings/review` |

Standalone routes in `AppRouter` (decision 8: no visible entry point yet). Repeated layouts (1↔2, 4↔5↔6, 8↔12, 11↔17, 10↔16) keep distinct files/routes but compose shared base widgets; only Booking Details (18) is a single status-driven screen.

### 4.2 Proposed theme/token/shared-widget changes

1. **Update the existing shared tokens globally** (decision 3) to the Figma (User App) values — do NOT create a parallel/scoped theme. Concretely: change `SportoDesignTokens.dark` values (canvas `#0E0C08→#090C10`, card `#171717→#17191E`, muted `#92949A→#A0A0A0`, gold `#CF9E24→#F4B41A`, red→`#FE464B`) and add new semantic fields (§5.1). `ColorScheme.primary` stays orange (`#ED7B00`, CTA gradient); green `#2BB673` is promoted to a token and stays as secondary/accent. Applied app-wide, so partner/referee screens that read these tokens will shift to the Figma palette (intended).
   - **Pre-change duty (approved):** before editing any token value, list every widget/screen in `partner_app`, `referee_app`, and `ui_kit` that reads each token being changed. Run `melos run test_ui` before and after. Report golden diffs and **WAIT for approval before regenerating any golden.**
2. Add layout tokens: `space14`, `radiusFull` (999), `radius30`; shadow tokens (`btnShadow`, `ctaGlow`, `cardShadowStrong`); blur tokens (`glassBlur=20`, `headerBlur=100`).
3. Add typography scale token set (`SportoTextStyles`) covering 10–28 + 40/64, Quicksand weights.
4. Tokenize `SportoShimmer` (colors from tokens, duration/curve from tokens, light/dark aware).
5. New shared widgets (in `ui_kit`): `SportoBookingAppBar`, `GlassDocCard`/extend `SportoCard`, `VenueHeaderCard`, `StatusPill`, `RefereeListTile`/`VenueListTile`, `ChoiceChipRow`, `SortChipRow`, `PaymentMethodTile`, `PriceSummaryCard`, `StatChip`, `StarRating`, `TagChip`, plus state widgets `SportoShimmer*` skeletons, `SportoErrorView`, `SportoEmptyView`, `AsyncStateView`.
6. Promote `#2BB673` etc. from `SportoTheme._green` into tokens.

### 4.3 Asset migration plan

- Add `flutter_svg` to `ui_kit` pubspec (keep `google_fonts`).
- Assets live in `packages/ui_kit/assets/referee_booking/{icons,illustrations,images}/` (aligned with the `features/referee_booking/` module name); the old empty `assets/booking/` stub is replaced.
- Merge + rename: build a semantic asset map (e.g. `ic_back.svg`, `ic_gps.svg`, `ic_clock.svg`, `ic_chevron_right.svg`, `ic_search.svg`, `ic_card.svg`, `ic_wallet.svg`, `ic_add_square.svg`, `ic_flash.svg`, `ic_profile_2user.svg`, `ic_location_pin.svg`, `ic_check.svg`; `sport_cricket.svg` … `sport_volleyball.svg`; `ill_success.svg`; `avatar_referee_default.png`).
- Dedupe identical SVGs (same icon across screens → one file).
- Maintain `docs/asset_mapping.md` (original Figma node name/path → new semantic asset name) so future re-exports can be re-mapped.
- Drop all status-bar mock assets.
- Raster: downscale `image-1-c0944a2003.jpg` → `avatar_referee_{1x,2x,3x}.png` (or keep jpg + provide placeholder), register in pubspec with variants.
- Register new asset dirs + `flutter_svg` in `packages/ui_kit/pubspec.yaml`; expose via `SportoAssets` (add SVG constants + a `SportoSvgIcon` widget mirroring `SportoAssetIcon`).
- Fonts: Quicksand already present — no new fonts.

### 4.4 Loading / error / empty plan per screen (proposed defaults)

| Screen | Skeleton (mirror layout) | Error | Empty |
|---|---|---|---|
| Booking home (E1-01) | 2x header card + 2x list-row skeleton | icon+msg+Retry | "No referee bookings yet" + CTA |
| Select Sport (E1-03) | 8x grid-cell skeleton | Retry | "No sports available" |
| Game Location (E1-04..06) | search field + 2-3 result rows | Retry | "No venues found" |
| Choose Referee (E1-13) | 3x referee-row skeleton | Retry (keep filters) | "No referees in this area" + change location |
| Payment (E1-10/16) | 4x payment-tile skeleton | Retry | "No saved methods" + Add |
| Booking Details (E2-*) | header + 3 section skeletons matching real section heights | Retry | n/a (id always resolves) → error only |
| Create booking / payment action | inline button spinner + disabled | inline error banner + Retry | n/a |

- One `AsyncStateView` wrapper; per-section states for multi-section screens (booking details, confirm).
- Retry re-triggers the same bloc event that loaded the data.

### 4.5 Implementation order (slices, package by package)

Shared slices run **once** (they serve all packages because of cross-package dedup, rule 8):
1. **Assets + fonts**: `flutter_svg`, asset dirs, rename/dedupe SVGs (across screens AND packages), raster variants, pubspec, `SportoAssets` SVG support. (No font work — Quicksand already bundled.)
2. **Tokens + theme**: extend `SportoDesignTokens`/layout/shadow/blur + new `SportoTextStyles`; tokenize shimmer.
3. **Shared widgets**: app bar, doc card, status pill, list tiles, chip rows, payment tile, price summary, stat chip, star rating, tag chip.
4. **State system**: `SportoShimmer*` skeletons, `SportoErrorView`, `SportoEmptyView`, `AsyncStateView`.

Then screens, **package by package** (each screen with loading/empty/error/data):

- **Package 1** `SPOTO_(Copy)_Dev_Export` (17 screens) — booking flow order: bookings list → overview → select sport → game location (search/current/venue) → booking options → booking type (quick/full) → choose referee → referee profile → booking summary → confirm → payment (2 variants) → success (2 variants).
- **Package 2** `SPOTO_(Copy)_Dev_Export_2` (4 screens) — Booking Details (upcoming/ongoing/completed) → Rate & Review.
- **Future packages**: slot into the shared slices; append to the package ledger in §7 and implement without re-planning.

Each slice ends with `flutter pub get` + `flutter analyze`, then wait for "continue".

### 4.6 Risks & conflicts

- **Destination app unknown** → if we create `apps/user_app`, that's a new app (routing, DI, theme wiring, main). Large scope change.
- **Theme divergence**: green User App vs orange centralized tokens — if we mutate shared tokens we can regress partner/referee goldens.
- **No backend** → screens can only be static/mock or need new API + bloc/domain layers (business-logic change; needs approval).
- **`flutter_svg` addition** affects `ui_kit` pubspec → re-resolve; ensure no version conflict.
- **Global ×1.12 text scale** will make Figma font sizes render 12% larger; must decide whether new screens opt out (`MediaQuery.withNoTextScaling`, as existing referee screens do) or design at scaled values. Affects pixel match.
- **Some Figma screens exceed viewport** (935/976) → must scroll; keep sticky header behavior.
- **Asset naming churn** → maintain a mapping table so future Figma re-exports can be re-mapped.
- **Duplicate/ambiguous screen identities** (e.g. 01 vs 02, 08 vs 12, 11 vs 17) → confirm which are real states vs just export variants.

### 4.7 Verification checklist (per screen)

- [ ] Rendered at 390 px width matches JSON: bg color, header height 90/44, card sizes (350 wide), paddings (20 sides), gaps (20/14/10), radii (16/20/30), borders.
- [ ] Text: family Quicksand, exact size/weight/color/line-height per JSON; no overflow at 320/360/390/430 widths.
- [ ] Icons: correct SVG, exact size (e.g. 36 back, 24 gps, 12 clock, 17x15.6 sport), tint.
- [ ] Gradients match stops; glass blur applied; shadows match offsets/blur/alpha.
- [ ] Safe areas: top/bottom respected; sticky header scrolling behavior; keyboard inset on search fields.
- [ ] Nodes marked `HIDDEN`/mock status bar are excluded.
- [ ] Loading skeleton mirrors final layout (no jump); error retry works; empty view shown; data view live.
- [ ] `flutter analyze` clean; golden test added for the base 390 frame where useful.

---

## 5. Phase 5 — Quiz answers (APPROVED decisions)

| # | Question | Decision |
|---|---|---|
| 1 | Destination app | **Inside `apps/partner_app`** (new `features/referee_booking/` module) |
| 2 | State management | **Keep `flutter_bloc`** (Bloc + Equatable) + go_router — no Riverpod |
| 3 | Token strategy | **Update existing shared tokens to the Figma (User App) values globally**; keep **primary = orange `#ED7B00`** (CTA gradient `#ED7B00→#CF9E24`), **secondary/green `#2BB673` = accent** (status/selected/links) |
| 4 | Data source | **UI-only with local mock/static data** behind a Bloc; no API/business-logic changes |
| 5 | Duplicate screens | **Keep all 21 as distinct screens/routes** |
| 6 | Text scaling | **Exact Figma font sizes**; wrap new screens in `MediaQuery.withNoTextScaling` (opt out of the ×1.12 lift) |
| 7 | Shimmer | **Reuse + tokenize `SportoShimmer`**; add per-component skeletons. No new shimmer package |
| 8 | Assets | **Add `flutter_svg`**; migrate SVGs to `assets/booking/{icons,illustrations}`; semantic snake_case rename + dedupe; drop mock status-bar assets; avatar raster 1x/2x/3x |
| 9 | Routing | **Standalone routes, no visible entry point yet** |
| 10 | Error / empty | **Propose token-based defaults** (generic copy until exact strings are provided) |

### 5.1 Token value changes (global — decision 3)

Update/verify `SportoDesignTokens.dark` (and derived `ColorScheme`) to the Figma palette. Values marked ◀ change from current:

| Token | New value | Current |
|---|---|---|
| canvas | `#090C10` ◀ | `#0E0C08` |
| card | `#17191E` ◀ | `#171717` |
| cardElevated | `#1C2026` | same |
| section | `#12161C` (new) | — |
| panel | `#1B2335` (new) | — |
| iconTile | `#313135` (new) | — |
| border | `#283040` | same |
| hairlineWarm | `#F3EEE2` (new) | — |
| textSecondary (muted) | `#A0A0A0` ◀ | `#92949A` |
| textTertiary | `#666666` (new) | — |
| onSurface | `#FFFFFF` | same |
| accentGreen + tint | `#2BB673` + `#28A1661A` (new) | theme-level `#2BB673` |
| avatarGreen | `#28A166` (new) | — |
| statusGreen | `#00D816` (new) | — |
| gold / goldSelected | `#F4B41A` ◀ (new token) | `_gold #CF9E24` |
| red | `#FE464B` ◀ | `_red #FE464B` (already equal) |
| primaryGradient | `#ED7B00→#CF9E24` | same |
| accentBlue | `#7AD3FF→#4FBAF0` (new) | — |
| accentGold | `#FFD572→#FEBD38` (new) | — |
| accentPink | `#FF58DD→#DC65AC` (new) | — |
| accentOrange | `#FF9364→#F25F33` (new) | — |
| accentRed | `#FE6C6C→#FE464B` (new) | — |
| glassBlur | `20` (new) | `SportoCard.defaultBlur=14` |
| headerBlur | `100` (new) | — |
| space14 | `14` (new) | — |
| radiusFull | `999` (new, pills) ; radius30 `30` (new) | — |
| cardShadowStrong / btnShadow / ctaGlow | tokens above | new |
| `SportoTextStyles` | 10/11/12/13/14/15/16/18/24/28/40/64 Quicksand | new |

⚠️ Because tokens change globally and decision 3 was "update shared tokens", the existing **`ui_kit` golden tests** (referee login/onboarding, text field) and any partner/referee widget using these tokens may shift. Plan: run `melos run test_ui` after the token slice and regenerate goldens **only if** the shift is the intended palette change; report diffs before regenerating.

### 5.2 Final assumptions (not contradicted by answers)

- **Dark-only.** App forces `SportoTheme.darkTheme`; Figma is dark. Light theme not pursued.
- Mock data lives behind a `BookingBloc` fed by an in-memory repository, so a real API can replace the repository later without UI changes.
- The mock status bar in Figma is excluded everywhere.
- Generic error/empty copy until exact strings are provided.

---

## 6. Next step

**STOPPED — awaiting explicit "approved, start implementation".** No app code has been written.
On approval, implementation proceeds in the 5 slices in §4.5 (assets → tokens/theme → shared widgets → state widgets → screens), each ending with `flutter pub get` + `flutter analyze`, then waiting for "continue".

---

## 7. Refined-requirements reconciliation (round 2 of the brief)

### 7.1 Input folder
- The brief says `new_changes/`. **`new_changes/` does not exist.** The export packages are in **`new_screens/`** (`SPOTO_(Copy)_Dev_Export`, `SPOTO_(Copy)_Dev_Export_2`). The unrelated `changes/` folder holds tournament-integration docs, not Figma exports. **Confirm the intended path** (assumed `new_screens/`).
- **No `.zip` packages exist** anywhere under `new_screens/` — nothing to extract.

### 7.2 Package ledger (single source of truth; append new packages here)

| Package | Screens | Base width | Tallest frame | Notes |
|---|---|---|---|---|
| `new_screens/SPOTO_(Copy)_Dev_Export` | 17 | 390 | 976 | Book-a-referee journey; 590 assets |
| `new_screens/SPOTO_(Copy)_Dev_Export_2` | 4 | 390 | 935 | Booking Details; 133 assets |

Base frame = **390 px** for both packages (confirmed from each `package-manifest.json`), consistent with the app's existing `sportoScale` base.

### 7.3 Fonts (Phase 1 item)
- **Quicksand is bundled locally** (`packages/ui_kit/assets/fonts/Quicksand-*.ttf`) and used via `fontFamily: 'packages/ui_kit/Quicksand'`. Figma uses 100% Quicksand → **no font bundling work**.
- `google_fonts: ^6.1.0` is declared in `packages/ui_kit/pubspec.yaml` but is **not referenced anywhere in `lib/`** and does not appear in `pubspec.lock`. Treat as unused; leave as-is unless you want it removed.

### 7.4 Existing screens/features that correspond to Figma screens
Grep of `apps/**` and `packages/**` for booking/sponsorship/referee-booking found **no existing implementation** of this flow.

| Figma area | Existing counterpart | Verdict |
|---|---|---|
| Referee booking (E1-01..17) | none (only `referee_management_screen.dart` = roster admin, different) | NEW |
| Booking Details (E2-*) | none | NEW |
| Payment / sponsorship | only tournament-level `TournamentSponsorRequest` model | NEW (UI-only, mock) |
| Closest reusable references | `partner_tournament_card.dart`, `live_tournament_card.dart`, `referee_details_screen.dart`, ui_kit `Sporto*` widgets | reuse patterns only |

### 7.5 Rule 9 — status/variant merging (RESOLVED)
Round-2 decision: **merge only Booking Details** (E2-01/02/03 → one status-driven screen). All Package-1 exports stay distinct. Final count: **17 (P1) + 2 (P2) = 19 screens**. See §4.1.

### 7.6 New global rules applied
- **Rule 10**: fake status bar never built; real system status bar + `SafeArea` everywhere (already in plan).
- **Rule 11**: alpha colors (`#F4B41A33`, `#2BB6730F/33`, `#28A1661A`, `#E1263F0F`, `#1C202666`, `#28304080`, `#31313580`, `#090C1033`) become **semantic tint tokens** per surface/status, not raw hex in screens.
- **Rule 12**: effects/gradients/blurs/strokes sourced from node `effects`/`fills` (already extracted in §2.3).
- **Rule 8**: dedup across screens **and packages** (e.g. `clock`, `gps`, `Back`, sport icons repeat in both packages → one shared asset/token/widget).

### 7.7 Open items (RESOLVED)
1. Input root = **`new_screens/`** (no `.zip` to extract).
2. Variant merging = **Booking Details only** (→ 19 screens).
3. Motion = **defaults only**, no custom animations/transitions; state changes instant with standard ink/ripple.
4. Interactions = **mock logic + in-flow navigation only** via a mock `BookingBloc`; retry re-fires the mock event. No existing business logic invoked.

---

## 8. Slice log (running)

### Slice 1 — Assets ✅ (done, awaiting "continue")
- Added `flutter_svg: ^2.0.10` to `packages/ui_kit/pubspec.yaml` (resolved 2.3.0); kept `google_fonts`.
- Created `packages/ui_kit/assets/referee_booking/{icons,images}/`, registered both in pubspec.
- Migrated **36 deduped SVGs + 1 raster** (37 files) from both packages; mock status-bar assets excluded. Full mapping in `docs/asset_mapping.md`.
- Added `SportoRefreeBookingIcons` constants + `SportoSvgIcon` widget to `packages/ui_kit/lib/src/assets/sporto_assets.dart` (exported via existing `ui_kit.dart`).
- Verified: `flutter pub get` + `flutter analyze` clean in `ui_kit`, `partner_app`, `referee_app`.
- Deferred (later slices): non-cricket/football sport grid glyphs are Figma **emoji text** (not SVGs); raster avatar is a single 1024² JPG (downscaled at render time) — ask if 1x/2x/3x PNG variants are required.

### Slice 2 — Tokens/theme ⏳ (implemented; AWAITING golden-diff approval)
Pre-change duty (approved): list every consumer of each changed token, run `melos run test_ui` before + after, report golden diffs, **wait for approval before regenerating goldens**.

**Pre-change consumers (files reading each changed token; `sporto_design_tokens.dart`/`sporto_theme.dart` excluded):**

| Changed token | Consumers |
|---|---|
| `canvas` (#0E0C08→#090C10) | no direct `.canvas` reads; drives `scaffoldBackgroundColor` in `sporto_theme.dart` + `sporto_ambient_background.dart` (global app background) |
| `card` (#171717→#17191E) | `tournament_detail_screen.dart`, `ui_kit/screens/onboarding_screen.dart` (9), `sporto_card.dart`, `sporto_quick_action.dart` |
| `muted` (#92949A→#A0A0A0) | `profile_screen.dart` (4); drives `onSurfaceVariant` (dark) app-wide |
| `tertiary`/gold (`_gold` #CF9E24→#F4B41A) | `create_tournament_wizard_screen` (16), `partner_main_screen` (7), `schedule_screen` (4), `tournament_detail_screen` (5), `tournaments_screen` (1), `live_tournament_card` (3), `partner_tournament_card` (2), `automated_onboarding_wizard` (11), `phone_login_screen` (4), `primary_button`, `sporto_bottom_nav` (6), `sporto_conduct_toss` (2), `sporto_cricket_match_card` (4), `sporto_info_row`, `sporto_match_verification` (3), `sporto_quick_action`, `sporto_summary_row` (2) |
| `onSurfaceVariant` (muted-derived) | 33 files across both apps + ui_kit (see grep in conversation) |
| `surfaceContainer*` (card-derived) | 10 files |
| `border` / `cardElevated` (values unchanged) | listed for completeness |

**Changes applied**
- `SportoDesignTokens`: values `canvas #090C10`, `card #17191E`, `muted #A0A0A0`; added `section #12161C`, `panel #1B2335`, `iconTile #313135`, `hairlineWarm #F3EEE2`, `textTertiary #666666`, `accentGreen #2BB673`, `accentGreenSoft #28A1661A`, `avatarGreen #28A166`, `statusGreen #00D816`, `gold #F4B41A`, `goldSoft #F4B41A33`, `red #FE464B`, `redSoft #E1263F0F`, `shimmerBase/shimmerHighlight`, and gradients `gradientBlue/gradientGold/gradientPink/gradientOrange/gradientRed`.
- `SportoLayoutTokens`: added `space14`, `radius30`, `radiusFull (999)`, `glassBlur (20)`, `headerBlur (100)`, `btnShadow`, `ctaGlow`, `shimmerDuration (1000ms)`.
- New `SportoTextStyles` (Quicksand scale 10–64 + `text()` builder); exported from `ui_kit.dart`.
- `SportoTheme._gold` → `#F4B41A` (ColorScheme.tertiary).
- `SportoShimmer` now reads base/highlight + duration from tokens (no hardcoded colours/duration).
- `flutter analyze` clean in `ui_kit`, `partner_app`, `referee_app`.

**`melos run test_ui` result — before vs after**

| | Before | After |
|---|---|---|
| passed | 23 | 15 |
| failed | 4 | 12 |

**New failures caused by the palette change (all `referee_intro_onboarding_golden_test.dart`, pixel diffs):**
`welcome 70.47%`, `booking 73.32%`, `matches 83.08%`, `payout 71.58%`, `earnings 68.56%`, `profile 76.35%`, `journey 77.48%`, `join 71.17%`.
(High % because the global background/card colour shifted slightly, so nearly every pixel changes.)

**Pre-existing failures (present before this slice):** `referee_login 26.52%`, `referee_onboarding_personal 9.87%`, `sporto_text_field 64.67%`, `referee_onboarding signup sequence`.

**Decision: A + verification (done).**
- Flat color remap (old palette → new token values, AA tol 8) leaves residual: welcome 5.48%, booking 2.87%, matches 2.62%, payout 2.63%, earnings 2.69%, profile 2.66%, journey 2.78%, join 2.97%.
- **Root cause of residual = alpha-composited / gradient blends** of the changed tokens (e.g. matches `D3991F→F3AC16`, delta ∝ gold vector `(+37,+22,−10)`), which a flat substitution cannot capture.
- **Blend-fit verification** (each changed pixel's delta must equal a convex combination of the token change vectors, fit tol 5): **explained = 100%, unexplained = 0 for all 8 goldens.** So the diffs are confirmed **palette-only**.
- Per the instruction ("if any golden has a meaningful residual, do NOT regenerate"), the **raw residual is meaningful**, so **NO goldens were regenerated**. Awaiting explicit go to regenerate the 8 `referee_intro_onboarding_*` (safe: 0 unexplained).
- Side-by-sides (OLD | NEW): `docs/figma_diffs/matches_OLD_vs_NEW.png`, `docs/figma_diffs/welcome_OLD_vs_NEW.png` (+ 3-panel `*_sbs.png` with the remapped middle panel).
- The 4 pre-existing failing goldens were **not touched**.

### Slice 3 - Shared widgets ✅ (done, awaiting "continue")
Brand-new token-driven widgets in `packages/ui_kit/lib/src/widgets/` (exported from `ui_kit.dart`):

| Widget | File | Notes |
|---|---|---|
| `SportoGlassSurface` + `SportoGlassBorders` | `sporto_glass_surface.dart` | base glass primitive: solid/gradient fill, colour/gradient hairline, backdrop blur, shadows; border-gradient presets (white/green/gold/goldSoft) from Figma |
| `SportoDocCard` | `sporto_doc_card.dart` | Figma `DocCard`/`Section` card (`plain` variant for `#1C2026` rows) |
| `SportoBookingAppBar` | `sporto_booking_app_bar.dart` | sticky glass header (canvas@0.2, blur 100), 36x36 back button, title/subtitle |
| `SportoStatusPill` | `sporto_status_pill.dart` | r50 gradient pill (orange/blue/green presets) |
| `SportoVenueHeaderCard` | `sporto_venue_header_card.dart` | sport glyph + venue/area header |
| `SportoBookingTile` | `sporto_booking_tile.dart` | referee/venue list card (slot-based) + green-tinted avatar |
| `SportoChoiceChip` | `sporto_choice_chip.dart` | r40 gold option chip (date/time/duration) |
| `SportoSortChip` | `sporto_sort_chip.dart` | r10 green sort chip |
| `SportoTagChip` | `sporto_tag_chip.dart` | `Bars / Nav Bars` tag chip (283040@0.5, white hairline) |
| `SportoStatChip` | `sporto_stat_chip.dart` | gold 107x54 stat chip |
| `SportoStarRating` | `sporto_star_rating.dart` | 5-star gold row (empty tinted #373435) |
| `SportoPaymentMethodTile` | `sporto_payment_method_tile.dart` | 50-high method tile (selected gradient) |
| `SportoPriceSummaryCard` | `sporto_price_summary_card.dart` | label/value rows + total |

- Extra token added: `SportoDesignTokens.whiteOverlay10` (#1AFFFFFF); `SportoDocCard`/app bar use `colorScheme.onSurface` for primary text.
- Verified: `flutter analyze` clean in `ui_kit` and `partner_app`; `ui_kit` tests still **15 pass / 12 fail** (no change - new widgets are unused).
- **Deferred to the screens slice (need @2x comparison):** exact gradient *opacity* on some translucent cards; on-accent dark text token (`#0E0C08` vs new canvas `#090C10`); Select-Sport grid non-cricket/football glyphs are Figma emoji text; `SportoStarRating` uses the small gold star asset (composed star-row assets available for exact display).

---

## 9. Follow-up (task #4) - hardcoded colors in existing partner/referee screens

Audit only. **Do NOT change these screens in this task.** Full line-level list (file, line, value, nearest token): `docs/hardcoded_colors_followup.md`.

**Totals:** 1072 occurrences across 25 files.

### Per file (occurrences)

| file | count |
|---|---|
| `apps\referee_app\lib\features\matches\presentation\screens\matches_list_screen.dart` | 188 |
| `apps\referee_app\lib\features\matches\presentation\screens\conduct_toss_wizard.dart` | 130 |
| `apps\referee_app\lib\features\matches\presentation\screens\referee_home_screen.dart` | 128 |
| `apps\referee_app\lib\features\matches\presentation\screens\match_verification_screen.dart` | 103 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\referee_management_screen.dart` | 77 |
| `apps\referee_app\lib\features\matches\presentation\screens\referee_scoring_tab_screen.dart` | 59 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\assign_referee_screen.dart` | 58 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\referee_details_screen.dart` | 53 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\partner_profile_detail_screens.dart` | 47 |
| `apps\referee_app\lib\features\matches\presentation\screens\profile_screen.dart` | 46 |
| `apps\referee_app\lib\features\matches\presentation\screens\live_scoring_screen.dart` | 45 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\profile_screen.dart` | 28 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\schedule_screen.dart` | 24 |
| `apps\referee_app\lib\features\matches\presentation\screens\referee_match_history_screen.dart` | 21 |
| `apps\referee_app\lib\features\matches\presentation\screens\referee_shell_screen.dart` | 19 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\create_tournament_wizard_screen.dart` | 14 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\tournament_detail_screen.dart` | 10 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\tournaments_screen.dart` | 9 |
| `apps\partner_app\lib\features\auth\presentation\views\partner_permission_setup_screen.dart` | 5 |
| `apps\partner_app\lib\features\tournaments\presentation\widgets\partner_tournament_card.dart` | 2 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\partner_main_screen.dart` | 2 |
| `apps\referee_app\test\referee_scoring_tab_screen_test.dart` | 1 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\venue_location_picker_screen.dart` | 1 |
| `apps\referee_app\test\matches_list_screen_test.dart` | 1 |
| `apps\partner_app\lib\features\tournaments\presentation\screens\team_details_screen.dart` | 1 |


### Distinct values -> nearest token (count)

| value | nearest token | count |
|---|---|---|
| `#FFFFFF` | `white` | 123 |
| `Colors.white` | material | 102 |
| `#2BB673` | `accentGreen` | 62 |
| `#AAAAAA` | `muted` | 57 |
| `#A0A0A0` | `muted` | 49 |
| `#8E95A2` | `muted` | 33 |
| `Colors.transparent` | material | 31 |
| `#FE464B` | `red` | 29 |
| `#FEBD38` | `gold` | 27 |
| `#ED7B00` | `actionOrange` | 26 |
| `#1C2026` | `cardElevated` | 26 |
| `#283040` | `border` | 25 |
| `#1B2335` | `panel` | 23 |
| `#20C783` | `accentGreen` | 22 |
| `Colors.black` | material | 22 |
| `#090C10` | `canvas` | 19 |
| `#13171E` | `section` | 19 |
| `#7AD3FF` | `info` | 19 |
| `#1F242C` | `cardElevated` | 17 |
| `#FF9364` | `upcoming` | 15 |
| `#CF9E24` | `gold` | 13 |
| `#6B7280` | `textTertiary` | 13 |
| `#000000` | `black` | 12 |
| `#4FBAF0` | `fieldBorderFocused` | 11 |
| `#5C93FF` | `fieldBorderFocused` | 10 |
| `#F25F33` | `upcoming` | 10 |
| `#0E0C08` | `canvas` | 10 |
| `#373E52` | `fieldBorder` | 9 |
| `#12161C` | `section` | 8 |
| `#2C313A` | `iconTile` | 7 |
| `#01A34D` | `avatarGreen` | 7 |
| `#7AD2FF` | `info` | 7 |
| `#F53E02` | `actionOrange` | 6 |
| `#FF334A` | `red` | 6 |
| `#1B1E24` | `field` | 6 |
| `#FF7545` | `upcoming` | 6 |
| `#FFD572` | `gold` | 6 |
| `#B40003` | `actionOrange` | 6 |
| `#1E232B` | `cardElevated` | 5 |
| `#767680` | `textTertiary` | 4 |
| `#FE6C6C` | `upcoming` | 4 |
| `#182824` | `cardElevated` | 3 |
| `#F65800` | `actionOrange` | 3 |
| `#512813` | `liveCardStart` | 3 |
| `#7BD0FA` | `info` | 3 |
| `#FEC03F` | `gold` | 3 |
| `#161B22` | `card` | 3 |
| `#082234` | `panel` | 3 |
| `#4F0E00` | `liveCardStart` | 3 |
| `#101317` | `section` | 3 |
| `#68EE76` | `assigned` | 3 |
| `#2F3A48` | `fieldBorder` | 2 |
| `#5185A1` | `textTertiary` | 2 |
| `#7AD0FA` | `info` | 2 |
| `#99FFA3` | `muted` | 2 |
| `#363E51` | `fieldBorder` | 2 |
| `#FF6B31` | `upcoming` | 2 |
| `#3A4356` | `fieldBorder` | 2 |
| `#1A1520` | `card` | 2 |
| `#E1AF45` | `gold` | 2 |
| `#17A25F` | `avatarGreen` | 2 |
| `#29303A` | `border` | 2 |
| `#A6A1A8` | `muted` | 2 |
| `#A19CA2` | `muted` | 2 |
| `#2C2C2A` | `iconTile` | 2 |
| `#FE595C` | `live` | 2 |
| `#112E23` | `field` | 2 |
| `#DF3F00` | `actionOrange` | 2 |
| `#AAA4AA` | `muted` | 2 |
| `#FF5265` | `live` | 2 |
| `#FF1919` | `actionOrange` | 2 |
| `#55F58E` | `assigned` | 2 |
| `#2A2035` | `panel` | 2 |
| `#252B38` | `border` | 2 |
| `#FFB600` | `gold` | 2 |
| `#222832` | `panel` | 2 |
| `#5C4700` | `liveCardStart` | 2 |
| `#243046` | `border` | 2 |
| `#17191F` | `card` | 2 |
| `#4EA1CA` | `fieldBorderFocused` | 2 |
| `#E8ECF1` | `onSurface` | 2 |
| `#1B222F` | `panel` | 1 |
| `#3D1F23` | `iconTile` | 1 |
| `#3D3823` | `iconTile` | 1 |
| `#28394B` | `border` | 1 |
| `#16191E` | `card` | 1 |
| `#3E506D` | `authFieldBorder` | 1 |
| `#57C8F5` | `info` | 1 |
| `#121211` | `canvas` | 1 |
| `#22252D` | `cardElevated` | 1 |
| `#394153` | `fieldBorder` | 1 |
| `#FF9100` | `gold` | 1 |
| `#374657` | `fieldBorder` | 1 |
| `#AAA5AC` | `muted` | 1 |
| `#5F2549` | `fieldBorder` | 1 |
| `#A19DA5` | `muted` | 1 |
| `#29230F` | `navSurface` | 1 |
| `#FF4444` | `red` | 1 |
| `Colors.orange` | material | 1 |
| `#444444` | `fieldBorder` | 1 |
| `#4FA9D7` | `fieldBorderFocused` | 1 |
| `#555555` | `textTertiary` | 1 |
| `#1C2427` | `cardElevated` | 1 |
| `#DE3F00` | `actionOrange` | 1 |
| `#281618` | `navSurface` | 1 |
| `#152520` | `field` | 1 |
| `#FFB718` | `gold` | 1 |
| `#0E1116` | `section` | 1 |
| `#283247` | `border` | 1 |
| `#3D221D` | `liveCardStart` | 1 |
| `#2A4250` | `fieldBorder` | 1 |
| `Colors.green` | material | 1 |
| `#0F172A` | `section` | 1 |
| `#1B292F` | `panel` | 1 |
| `#211C0F` | `navSurface` | 1 |
| `#D9A81B` | `gold` | 1 |
| `#231715` | `navSurface` | 1 |
| `#FF8500` | `gold` | 1 |
| `#23202C` | `cardElevated` | 1 |
| `#151B24` | `field` | 1 |
| `#FDBD38` | `gold` | 1 |
| `#4A4540` | `fieldBorder` | 1 |
| `#5B4D19` | `iconTile` | 1 |
| `#4A4D53` | `fieldBorder` | 1 |
| `#28251B` | `navSurface` | 1 |
| `#5A4A61` | `textTertiary` | 1 |
| `#FFB817` | `gold` | 1 |
| `#666666` | `textTertiary` | 1 |
| `#252A31` | `panel` | 1 |
| `#42F58D` | `assigned` | 1 |
| `#262B31` | `iconTile` | 1 |
| `#251C20` | `navSurface` | 1 |
| `#161411` | `section` | 1 |
| `#252C3B` | `border` | 1 |
| `#FEC144` | `gold` | 1 |
| `#4FA1CA` | `fieldBorderFocused` | 1 |
| `#181D26` | `field` | 1 |
| `#1A2332` | `panel` | 1 |
| `#697078` | `textTertiary` | 1 |
| `#A9A4AB` | `muted` | 1 |
| `#2C405A` | `fieldBorder` | 1 |
| `#101A15` | `section` | 1 |
| `#FF4D43` | `red` | 1 |
| `#84F890` | `assigned` | 1 |
| `#F4B41A` | `gold` | 1 |
| `#1E293B` | `panel` | 1 |
| `#171A20` | `card` | 1 |
| `#262B33` | `iconTile` | 1 |
| `#FF6846` | `upcoming` | 1 |
| `#FF7E24` | `upcoming` | 1 |
| `#556070` | `textTertiary` | 1 |

