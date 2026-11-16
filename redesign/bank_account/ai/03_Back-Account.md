# Back Account

- Screen: 03
- Folder: screens/03_Back-Account
- JSON: screens/03_Back-Account/Back-Account.json
- Preview: screens/03_Back-Account/Back-Account@2x.png
- Size: 390 × 844
- Layout root: NONE
- Logical screen: Back Account - Default (default)

## Central components used

- Repeated section 1 — medium · Back Account / Frame 1000003334
- Repeated section 2 — medium · Back Account / Frame 1000003334 / Frame 1000003337

## Assets

- svg/icon: assets/svg/vector-7bf3ec93c80b.svg (PNG: assets/png/vector-7bf3ec93c80b@2x.png)
- svg/icon: assets/svg/vector-a4eb49850c93.svg (PNG: assets/png/vector-a4eb49850c93@2x.png)
- svg/icon: assets/svg/vector-149be7e3dfc4.svg (PNG: assets/png/vector-149be7e3dfc4@2x.png)
- svg/icon: assets/svg/vector-149be7e3dfc4.svg (PNG: assets/png/vector-149be7e3dfc4@2x.png)
- svg/icon: assets/svg/vector-38982698c110.svg (PNG: assets/png/vector-38982698c110@2x.png)

## Shared assets

- shared/assets/png/Vector-310f004d.png: ../../shared/assets/png/Vector-310f004d.png (1 placements)

## Node outline

```
Back Account [FRAME · absolute]
  Back Account / Frame 1000003334 [FRAME · flex-column] → Repeated section 1 (medium)
    Back Account / Frame 1000003334 / Frame 1000003337 [FRAME · flex-row] → Repeated section 2 (medium)
  Back Account / Frame 1261154190 [FRAME · flex-column]
    Back Account / Frame 1261154190 / Frame 1261154713 [FRAME · flex-row]
    Back Account / Frame 1261154190 / Frame 1261154714 [FRAME · flex-column]
```

## Coverage warnings

- FIXED_TEXT_BOX: Text box is fixed. Verify overflow and wrapping behavior. (Back Account / Frame 1261154190 / Frame 1261154714 / Frame 1171275339 / Frame 1171275285 / Upto 3.5% Cashback)
- FIXED_TEXT_BOX: Text box is fixed. Verify overflow and wrapping behavior. (Back Account / Frame 1261154190 / Frame 1261154714 / Frame 1171275341 / Frame 1171275285 / Upto 3.5% Cashback)

## Build notes

- Prefer the centralized components above over rebuilding the same subtree.
- Use `css` on each node for layout, box, visual, typography and asset hints.
- Use `assets` and `sharedAssets` paths exactly; do not redraw icons.
- Check `fonts.json` for missing fonts and fallbacks.

## Font warnings

- Font Quicksand has mixed weights across text runs. Resolve weights from styledSegments when rendering.
