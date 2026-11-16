# Centralized UI

This folder is the shared source of truth for every screen.

- `central-ui.json` — tokens, component library and screen compositions.
- Components come from Figma components (high confidence) and repeated structures (medium confidence).
- Screens reference components by id and path; unmatched nodes stay in each screen JSON.
- Review `coverage.json` before treating the output as pixel-perfect.
