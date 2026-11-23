# Export package contract

Source: `C:\Users\sanja\Downloads\spoto_partner_tournament_redesign`
Generated: 2026-11-15T18:10:59Z · mode `design` (`codeGeneration: none`) · verification disabled

| Fact | Value |
|---|---|
| Screens | 48 artboards → **25 logical screens** (`screen-variants.json`) |
| Design size | 390 × 844 (mobile); a few component strips 424–965 wide |
| Tokens | 45 colours · 69 typography · 18 spacing · 16 radii · 20 shadows · 35 gradients · 23 named styles |
| Components | 155 (5 Figma components, 150 heuristically repeated) |
| Assets | 1 165 (992 individual SVG, 172 composed SVG, 1 raster); 131 shared |
| Fonts | Quicksand (2 633 uses) + Mulish (1 use) — both already bundled in `ui_kit` |
| Coverage | 383 warnings: `CONSTRAINT_LAYOUT` 331, `MULTIPLE_FILLS` 43, `FIXED_TEXT_BOX` 7, `MISSING_FONT` 1, `HEURISTIC_COMPONENTS` 1 |

## Read order used

`package-manifest.json` → `screen-variants.json` / `screen-groups.json` → each
`screens/<NN>/<Name>.json` → `central-ui/central-ui.json` (tokens + components) →
`fonts.json` → `coverage.json` → `screens/<NN>/assets/manifest.json`.

## Two traps in this package

1. **Layer names are stale.** `TEXT` nodes carry an old layer name (`"Cashback History"`)
   while the real copy is in `text.characters` (`"Applications (4)"`). Any text extraction
   that reads `node.name` produces garbage. All copy below comes from `text.characters`.
2. **File names are stale too.** Folder names do not describe content:

   | Folder | Actual content |
   |---|---|
   | `01_Cricket-Match` | **Live Tournaments** list screen (back header, "Live Tournaments (2)") |
   | `09/10/14/36_Cricket-Match` | **Tournaments tab** list (3 different tab states) |
   | `05_Cricket-Match` | card-variant **gallery** (overlapping frames, all status variants) |
   | `15`–`34_Create-Tournament-Wizard` | **Tournament detail tabs** (standings, stats, bracket, financials) |
   | `19_Venue-Schedule` | **Player details** (innings table) |
   | `39`–`47` | title-only artboards, **no design content** (`39_Live-Tournaments` is a 749×223 frame containing one text node) |

## Coverage warnings for this scope

| Screen | Warnings | Breakdown |
|---|---|---|
| 09 | 19 | 18 `CONSTRAINT_LAYOUT` (nav icon vectors), 1 `MULTIPLE_FILLS` (header gradient stack) |
| 10 | 19 | same as 09 |
| 14 | 31 | 28 `CONSTRAINT_LAYOUT` (nav icons), 3 `MULTIPLE_FILLS` (header + champion ticket) |
| 36 | 22 | 21 `CONSTRAINT_LAYOUT` (nav icons), 1 `MULTIPLE_FILLS` |

The nav-icon warnings belong to the app shell (`partner_main_screen`), not to the list body.
The `MULTIPLE_FILLS` on the header and the champion ticket are intentional layered fills and
are reproduced as stacked `DecoratedBox` layers, not flattened.

`fonts.json` warning `MISSING_FONT` / "Quicksand — source: system, substitute: Inter" is not a
real gap: `ui_kit` bundles Quicksand 400/500/600/700. No fallback is used.
