# AI Agent Prompt — Dev Export Package

Generated: 2026-11-16T10:29:05.256Z
Screens: 6
Architecture: centralized UI

You are rebuilding the exported Figma UI in a frontend project.

## Non-negotiables

- Read `central-ui/central-ui.json` first. It is the shared token and component source of truth.
- Build shared tokens and shared components once, then compose every screen from them.
- Do not duplicate component styles inside screens.
- Use `screens/<screen>/<screen>.json` for exact node data and `central-ui` for shared structure.
- Use the screen @2x PNG as the visual source of truth.
- Use the assets from `screens/<screen>/assets` and `shared/assets`; do not redraw icons.
- Resolve every asset path with `node-index.json` when a node is ambiguous.
- Treat `coverage.json` warnings as known risks, not as ignored items.
- Treat `screen-variants.json` groups as one logical screen with state/tab handling, not duplicate screens.

## Recommended workflow

1. Read `package-manifest.json`.
2. Read `central-ui/central-ui.json` and create the token layer.
3. Create the shared components listed in `central-ui.components`.
4. For each screen, read its JSON, then compose it from the shared components.
5. Use fallback nodes for anything without a confident component match.
6. Check `fonts.json` and load or fall back for every missing font.
7. Compare against `screens/<screen>/<screen>@2x.png`.
8. If a verification harness exists under `verify/`, run it, fix the worst diff regions, and repeat.

## Package map

- `central-ui/central-ui.json` — tokens, components, screen compositions.
- `fonts.json` — font families, styles, weights, fallbacks, missing-font warnings.
- `coverage.json` — masks, blend modes, image crops, gradients, fixed text boxes and font issues.
- `node-index.json` — node id to screen/path map.
- `screen-variants.json` — logical screens with state/tab variants grouped together.
- `AI_AGENT_PROMPT.md` — this file.
- `ai/<screen>.md` — condensed per-screen handoff.
- `screens/<screen>/<screen>.json` — full screen data and `centralUi` references.
- `shared/assets/` — canonical duplicate assets used by multiple screens.

## Output options

- Design JSON / Figma spec: use `central-ui` + screen JSON.
- Code: use the generated starter folder and refine it.
- Both: emit the spec and the starter code from the same central model.

Current output mode: design.
Code target: not generated.
Code folder: none.

Targets supported by this build: React, Flutter, HTML + CSS.

## Design token files

- `tokens/tokens.json` — token source of truth.
- `tokens/tokens.css` — CSS variables.
- `tokens/tailwind.config.js` — Tailwind theme extension.
- `component-index.json` — component usage grouped by screen and source.
- `screen-groups.json` — inferred breakpoints and screen name groups.

## Current export facts

- Components: 11 (2 Figma, 9 repeated)
- Tokens: 9 colors, 5 typography, 5 spacing, 2 radii
- Shared assets: 5
- Font families: 1 (0 missing-font warnings)
- Coverage warnings: 29

## Do not

- Do not invent copy, images or icons.
- Do not flatten everything into absolute positioning.
- Do not ignore Auto Layout sizing (FIXED / HUG / FILL).
- Do not create per-screen copies of shared components.
- Do not silently drop `coverage.json` warnings.
