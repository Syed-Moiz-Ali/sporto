# Token reconciliation

Existing token file: `packages/ui_kit/lib/src/theme/sporto_tournament_tokens.dart`
(`SportoTournamentTokens`, a `ThemeExtension` registered by `SportoTheme.darkTheme`).
Type: `sporto_text_styles.dart`. **No second token file is created.**

## Colours

| Export token | Value | App token | Verdict |
|---|---|---|---|
| `color/text-primary` | `#090C10` | `screenBase` | reused |
| `color/text-primary/31` | `#0A0E12` | `screenHeader` | reused |
| `color/text-primary/16` | `#17191E` | `card` | reused |
| `color/text-primary/08` | `#1C2026` | `cardElevated` | reused |
| `color/text-primary/38` | `#1B2335` | `panel` | reused |
| `color/accent-blue` | `#283040` | `border` | reused |
| `color/neutral-dark` | `#666666` | `dim` | reused |
| `color/neutral-light` | `#A0A0A0` | `muted` = `#AAAAAA` | **drifted** (+6/channel) — reuse, record |
| `color/accent-orange` | `#F4B41A` | `gold` (= `underReview`) | reused |
| `color/accent-green` | `#2BB673` | `green` | reused |
| `color/accent-orange/12` | `#F3EEE2` | `warm` | reused |
| `color/background` | `#FFFFFF` | `white` | reused |
| `color/text-primary/21` | `#0E0C08` | `screenBase` `#090C10` | **drifted** (2–5/channel) — reuse, record |
| `color/accent-green/18` | `#28A166` | — | **missing → added** as `greenDeep` |
| `overlay/13` | `#090C1033` | `screenBase.withValues(alpha: .20)` | derived, no token |
| `overlay/29` | `#F3EEE20A` | `warm.withValues(alpha: .04)` | derived, no token |
| `overlay/39` | `#B400031A` | `red.withValues(alpha: .10)` | derived, no token |

## Gradients

| Export | Stops | App token | Verdict |
|---|---|---|---|
| header wash | `#6075FF0A → #274D4D0A` | `headerGradient` | reused |
| pending pill | `#FF9364 → #F25F33` | `orangePillGradient` | reused |
| rejected pill | `#FE6C6C → #FE464B` | `redPillGradient` | reused |
| under-review pill | `#FFD572 → #FEBD38` | `goldPillGradient` | reused |
| completed pill | `#7AD3FF → #4FBAF0` | `bluePillGradient` | reused |
| medal / monitor | `#ED7B00 → #CF9E24` | — | **missing → added** as `amberPillGradient` |
| selected pill border | `#2BB6730F → #2BB67333 → #2BB6730F` | — | **missing → added** as `greenPillBorderGradient` |
| idle pill border | `#7BD0FA1A → #7BD0FA4D → #7BD0FA1A` | — | **missing → added** as `bluePillBorderGradient` |
| live dot | `#FF4444 → #FF1919` | — | **missing → added** as `liveDotGradient` |
| identity card hairline | `#7BD0FA00 → #7BD0FA4D → #7BD0FA00` (vertical) | — | **missing → added** as `blueEdgeGradient` |
| prize panel hairline | `#FFFFFF0F → #FFFFFF4D → #FFFFFF0F` (vertical) | — | **missing → added** as `whiteBorderGradient` |
| champion ticket | base `#E1263F0F` + linear `#173824 → #0E2418` + radial `#F2B7052E` + radial `#E1263F59` | — | composed in `TournamentChampionTicket` from `green`/`gold`/`red` alphas (4 stacked layers, not a single token) |

## Radii

| Export | Value | App token | Verdict |
|---|---|---|---|
| `radius/10` | 10 | `r10` | reused (Create pill, avatar, Edit pill) |
| `radius/50` | 50 | `r50` | reused (filter pills) |
| `radius/80` | 80 | `r80` | reused (status badges) |
| `radius/16` | 16 | — | **missing → added** as `r16` (list card) |
| `radius/12` | 12 | — | **missing → added** as `r12` (Edit pill, action button) |
| header bottom | 20 | `r18` = 18 | **drifted** (−2) — reuse, record |

## Typography

Sizes used by the list: 10, 11, 12, 13, 14, 16, 18, 24 — all present in `SportoTextStyles`
(`size10`…`size24`). Weights 400/500/600/700 are the existing constants.

Drift: the export uses `lineHeight: AUTO`; `SportoTextStyles.text()` defaults to `height: 1.25`.
Measured line boxes agree within 0.3 px from 12 px up (12→15, 14→18, 18→23, 24→30); only 10 px
differs (export 13 px vs 15 px box). Changing the global default would move every existing
screen, so the default is kept and the drift is accepted.

## Spacing / shadows

- Spacing: the app has no spacing-token API (literals × `context.sportoScale`). Same mechanism
  reused; nothing added.
- Shadows: `softCardShadow` reused for the card. The export's `BACKGROUND_BLUR` on cards is a
  Figma glass effect over an opaque `#17191E` fill — visually invisible; reproduced as a plain
  fill (recorded as an approximation, not a missing token).

## Totals

- Reused: 14 colours · 5 gradients · 3 radii · type scale · shadow
- Added (to `sporto_tournament_tokens.dart`, annotated with node ids): **1 colour**
  (`greenDeep`), **6 gradients**, **2 radii** = 9 entries
- Drifted: 3 (`muted` 6 units, selected-pill ink 2–5 units, header radius 2 px)
- Conflicts: **0** — no brand colour differs from the existing palette
