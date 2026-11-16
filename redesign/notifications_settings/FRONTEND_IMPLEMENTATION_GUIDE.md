# Frontend Implementation Guide

Generated: 2026-11-16T10:29:05.256Z
Screens: 6

This guide explains how to turn the exported JSON and assets into a working
frontend implementation. It is intentionally framework-neutral; the same
data works for React, Next.js, Vue, Nuxt, Angular, Svelte, Flutter, SwiftUI,
Jetpack Compose, React Native or plain HTML/CSS.

## 1. Package map

- `package-manifest.json` — every screen, totals and recommended read order.
- `central-ui/central-ui.json` — shared tokens, components and screen compositions.
- `fonts.json` — families, styles, fallbacks and missing-font warnings.
- `coverage.json` — items that may need manual verification.
- `node-index.json` — node id to screen/path map.
- `screen-variants.json` — logical screens with state/tab variants grouped together.
- `tokens/` — design tokens as JSON, CSS variables and Tailwind theme.
- `component-index.json` — component usage grouped by screen and source.
- `screen-groups.json` — inferred breakpoints and screen groups.
- `verify/` — Playwright visual verification harness and expected previews.
- `code/` — optional starter code for React, Flutter or HTML/CSS.
- `AI_AGENT_PROMPT.md` + `ai/` — agent handoff instructions per screen.
- `screens/<screen>/<screen>.json` — layout tree, styles, assets and variables.
- `screens/<screen>/<screen>@2x.png` — visual reference for that screen.
- `screens/<screen>/assets/` — screen-local assets + asset catalog.
- `shared/assets/` — identical assets reused by 2+ screens.
- `shared/assets/manifest.json` — shared asset usage references.
- `FRONTEND_IMPLEMENTATION_GUIDE.md` — this document.

## 2. Recommended build order

1. Read `package-manifest.json` and note screen order and totals.
2. Open one screen JSON and read `developerSummary` first.
3. Read `assetIndex` and `sharedAssets` before touching `nodes`.
4. Study the screen preview PNG to understand visual intent.
5. Map `nodes` into components, starting from the outermost frame.
6. Build shared primitives (buttons, inputs, cards) after two screens.
7. Repeat per screen, promoting repeated patterns into shared components.
8. Compare the finished page against the preview at 100% zoom.

## 3. Screen JSON anatomy

- `source` — file, page, screen node id and node counts.
- `guidance` — coordinate system, layer order and asset strategy.
- `developerSummary` — colors, typography, spacing and warnings.
- `assetIndex` — assets grouped by node, role and composed graphics.
- `assetManifest` — asset files, dimensions, roles and format paths.
- `sharedAssets` — shared files plus exact screens/layers where used.
- `variableCollections` / `variables` — tokens and modes.
- `nodes` — serialized layer tree (root is the selected screen).

## 4. Node mapping

- `FRAME` / `GROUP` → layout containers or semantic sections.
- `TEXT` → text element with typography from `text`.
- `RECTANGLE` / `ELLIPSE` → boxes, avatars, dividers or backgrounds.
- `VECTOR` / `BOOLEAN_OPERATION` → inline SVG or exported asset.
- `INSTANCE` → reusable component; check `mainComponent` and overrides.
- `COMPONENT` / `COMPONENT_SET` → component or variant set.
- Do not mirror every Figma wrapper one-to-one. Remove purely structural
  groups when native layout primitives can express the same result.

## 5. Layout and responsiveness

- `x` / `y` are relative to the immediate parent; `absoluteBoundingBox` is page space.
- `layoutMode` (`VERTICAL` / `HORIZONTAL`) maps to flex or stack layouts.
- `primaryAxisAlignItems` → justify-content; `counterAxisAlignItems` → align-items.
- `itemSpacing`, `padding*` and `counterAxisSpacing` map to gap and padding.
- `layoutSizingHorizontal` / `layoutSizingVertical`:
  - `FIXED` → fixed width/height.
  - `HUG` → width/height fit content.
  - `FILL` → flex: 1 / expand.
- `constraints` explain how children pin when a parent resizes.
- `minWidth`, `maxWidth`, `minHeight`, `maxHeight` should not be dropped.
- `clipsContent` maps to overflow hidden.

## 6. Visual styles

- `fills` / `strokes` include Figma paint data and a `hex` helper for SOLID paints.
- `opacity` and `blendMode` apply to the whole layer.
- `effects` contain shadows, blurs and inner shadows.
- `cornerRadius` or per-corner radii map to border-radius.
- `strokeWeight`, `strokeAlign`, `strokeCap`, `strokeJoin` and `dashPattern`
  describe borders. `strokeAlign: INSIDE` is the default web border box.
- `layoutGrids` and `gridStyleId` are optional hints; check `includeCSS` output
  only when it is enabled.

## 7. Typography

- `text.characters` is the exact copy.
- `fontName`, `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing` drive styles.
- `textAlignHorizontal` / `textAlignVertical` map to text-align and alignment.
- `textAutoResize` tells you whether the text box grows or stays fixed.
- If `styledSegments` exists, apply per-range styles instead of one style.

## 8. Assets

- `vectorAsset` → exact SVG for a vector layer.
- `composedVectorAsset` → merged decorative vector group.
- `imageAssets` → one entry per image fill; check `fillIndex`, `scaleMode`,
  `imageTransform`, `filters` and `rotation`.
- Asset paths inside screen JSON are relative to that screen folder.
- Shared entries also include `relativeFromScreen` (`../../shared/...`).
- Prefer composed SVGs for illustrations and individual SVGs for reusable icons.

## 9. Shared asset library

5 asset files are reused across screens and live in shared/assets/.

| File | Kind | Screens | Placements |
| --- | --- | --- | --- |
| shared/assets/png/Vector-310f004d.png | svg | 6 | 6 |
| shared/assets/png/Line-5-Stroke-1a6472f8.png | svg | 5 | 11 |
| shared/assets/png/Ellipse-816-d8dbaa94.png | svg | 5 | 11 |
| shared/assets/png/Line-5-Stroke-e26b7e8e.png | svg | 3 | 3 |
| shared/assets/png/Ellipse-816-2766cdd7.png | svg | 3 | 3 |

Use `shared/assets/manifest.json` for the exact layer path of every placement.

## 10. Variables and tokens

- `variableCollections` and `variables` contain resolved Figma variables and modes.
- `boundVariables` on a node tells you which token drives a property.
- Create a token layer in the target project (CSS variables, Tailwind theme,
  SwiftUI Environment, Compose MaterialTheme, etc.) and map tokens once.

## 11. Components and variants

- `INSTANCE.mainComponent` points back to the component name and key.
- `componentProperties` and `variantProperties` describe configurable props.
- `overrides` shows instance-level changes that must become props or slots.

## 12. Interactions

- `reactions` and overlay properties describe prototype links.
- Convert them into routing, navigation or modal state in the target app.

## 13. Framework notes

- React / Next.js: one component per repeated frame pattern, CSS modules or
  Tailwind, an `assets/` folder for shared files.
- Vue / Nuxt: define props from component properties and slots for children.
- Flutter: Widget tree from frames, `Row`/`Column` from auto layout, `Image.asset`.
- SwiftUI: VStack/HStack/ZStack, `Image(uiImage:)` or symbols for icons.
- HTML/CSS: flexbox or grid for layout; SVG inline for icons when possible.

## 14. Quality checklist

- [ ] Every screen matches its preview at 1× and 2× zoom.
- [ ] Text styles use the project's typography scale.
- [ ] Colors come from tokens, not ad-hoc hex values.
- [ ] Shared assets are imported once, not duplicated per screen.
- [ ] Auto layout behavior survives content changes.
- [ ] Fixed/hug/fill sizing matches the JSON.
- [ ] Interactive elements have hover, focus and disabled states added.
- [ ] Hidden-layer decisions match the export option.
- [ ] No raw Figma node names leak into user-facing copy.

## 15. Exported screens

01. Notification Settings
   - JSON: screens/01_Notification-Settings/Notification-Settings.json
   - Preview: screens/01_Notification-Settings/Notification-Settings@2x.png
   - Assets: 6

02. Match Notifications - Notification Settings
   - JSON: screens/02_Match-Notifications-Notification-Settings/Match-Notifications-Notification-Settings.json
   - Preview: screens/02_Match-Notifications-Notification-Settings/Match-Notifications-Notification-Settings@2x.png
   - Assets: 9

03. Tournament Updates - Notification Settings
   - JSON: screens/03_Tournament-Updates-Notification-Settings/Tournament-Updates-Notification-Settings.json
   - Preview: screens/03_Tournament-Updates-Notification-Settings/Tournament-Updates-Notification-Settings@2x.png
   - Assets: 7

04. Team & Requests - Notification Settings
   - JSON: screens/04_Team-Requests-Notification-Settings/Team-Requests-Notification-Settings.json
   - Preview: screens/04_Team-Requests-Notification-Settings/Team-Requests-Notification-Settings@2x.png
   - Assets: 7

05. Registration & Payments - Notification Settings
   - JSON: screens/05_Registration-Payments-Notification-Settings/Registration-Payments-Notification-Settings.json
   - Preview: screens/05_Registration-Payments-Notification-Settings/Registration-Payments-Notification-Settings@2x.png
   - Assets: 5

06. Others - Notification Settings
   - JSON: screens/06_Others-Notification-Settings/Others-Notification-Settings.json
   - Preview: screens/06_Others-Notification-Settings/Others-Notification-Settings@2x.png
   - Assets: 5
