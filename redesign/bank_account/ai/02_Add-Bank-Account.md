# Add Bank Account

- Screen: 02
- Folder: screens/02_Add-Bank-Account
- JSON: screens/02_Add-Bank-Account/Add-Bank-Account.json
- Preview: screens/02_Add-Bank-Account/Add-Bank-Account@2x.png
- Size: 390 × 844
- Layout root: NONE
- Logical screen: Add Bank Account - Default (default)

## Central components used

- Repeated section 1 — medium · Add Bank Account / Frame 1000003334
- Repeated section 2 — medium · Add Bank Account / Frame 1000003334 / Frame 1000003337

## Assets

- svg/icon: assets/svg/vector-86bf81529718.svg (PNG: assets/png/vector-86bf81529718@2x.png)

## Shared assets

- shared/assets/png/Vector-310f004d.png: ../../shared/assets/png/Vector-310f004d.png (1 placements)

## Node outline

```
Add Bank Account [FRAME · absolute]
  Add Bank Account / Frame 1000003334 [FRAME · flex-column] → Repeated section 1 (medium)
    Add Bank Account / Frame 1000003334 / Frame 1000003337 [FRAME · flex-row] → Repeated section 2 (medium)
  Add Bank Account / Frame 1261154190 [FRAME · flex-column]
    Add Bank Account / Frame 1261154190 / Frame 1171275339 [FRAME · flex-row]
    Add Bank Account / Frame 1261154190 / Frame 1261154379 [FRAME · flex-column]
    Add Bank Account / Frame 1261154190 / Controls [FRAME · flex-row]
```

## Coverage warnings

- None.

## Build notes

- Prefer the centralized components above over rebuilding the same subtree.
- Use `css` on each node for layout, box, visual, typography and asset hints.
- Use `assets` and `sharedAssets` paths exactly; do not redraw icons.
- Check `fonts.json` for missing fonts and fallbacks.

## Font warnings

- Font Quicksand has mixed weights across text runs. Resolve weights from styledSegments when rendering.
