# On-boarding Screen

- Screen: 01
- Folder: screens/01_On-boarding-Screen
- JSON: screens/01_On-boarding-Screen/On-boarding-Screen.json
- Preview: screens/01_On-boarding-Screen/On-boarding-Screen@2x.png
- Size: 390 × 844
- Layout root: NONE
- Logical screen: On-boarding Screen - Default (default)

## Central components used

- Repeated section 1 — medium · On-boarding Screen / Frame 1000003334
- Repeated section 2 — medium · On-boarding Screen / Frame 1000003334 / Frame 1000003337

## Assets

- svg/icon: assets/svg/vector-8dce437d48e9.svg (PNG: assets/png/vector-8dce437d48e9@2x.png)
- svg/icon: assets/svg/vector-439af28f781d.svg (PNG: assets/png/vector-439af28f781d@2x.png)
- svg/icon: assets/svg/vector-dab79f89e48d.svg (PNG: assets/png/vector-dab79f89e48d@2x.png)
- svg/icon: assets/svg/vector-45a79c568e52.svg (PNG: assets/png/vector-45a79c568e52@2x.png)
- composed-svg/graphic: assets/composed/svg/info_circle-3a09cdde292a.svg (PNG: assets/composed/png/info_circle-3a09cdde292a@2x.png)
- composed-svg/graphic: assets/composed/svg/vuesax_linear_info_circle-b0b024b4d5de.svg (PNG: assets/composed/png/vuesax_linear_info_circle-b0b024b4d5de@2x.png)
- composed-svg/graphic: assets/composed/svg/info_circle-3b615cde258b.svg (PNG: assets/composed/png/info_circle-3b615cde258b@2x.png)
- composed-svg/graphic: assets/composed/svg/frame_1171275269-15c42adc4b91.svg (PNG: assets/composed/png/frame_1171275269-15c42adc4b91@2x.png)
- svg/icon: assets/svg/vector-d5e919234bd2.svg (PNG: assets/png/vector-d5e919234bd2@2x.png)

## Shared assets

- shared/assets/png/Vector-310f004d.png: ../../shared/assets/png/Vector-310f004d.png (1 placements)

## Node outline

```
On-boarding Screen [FRAME · absolute]
  On-boarding Screen / Frame 1000003334 [FRAME · flex-column] → Repeated section 1 (medium)
    On-boarding Screen / Frame 1000003334 / Frame 1000003337 [FRAME · flex-row] → Repeated section 2 (medium)
  On-boarding Screen / Frame 1261154190 [FRAME · flex-column]
    On-boarding Screen / Frame 1261154190 / Frame 1171275339 [FRAME · flex-column]
    On-boarding Screen / Frame 1261154190 / Section [FRAME · flex-column]
    On-boarding Screen / Frame 1261154190 / Primary Button [FRAME · flex-row]
```

## Coverage warnings

- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (On-boarding Screen / Frame 1261154190 / Frame 1171275339 / Frame 1171275271 / Frame 1171275269 / info-circle / vuesax/linear/info-circle / info-circle / Vector)
- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (On-boarding Screen / Frame 1261154190 / Frame 1171275339 / Frame 1171275271 / Frame 1171275269 / info-circle / vuesax/linear/info-circle / info-circle / Vector)
- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (On-boarding Screen / Frame 1261154190 / Frame 1171275339 / Frame 1171275271 / Frame 1171275269 / info-circle / vuesax/linear/info-circle / info-circle / Vector)
- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (On-boarding Screen / Frame 1261154190 / Frame 1171275339 / Frame 1171275271 / Frame 1171275269 / info-circle / vuesax/linear/info-circle / info-circle / Vector)

## Build notes

- Prefer the centralized components above over rebuilding the same subtree.
- Use `css` on each node for layout, box, visual, typography and asset hints.
- Use `assets` and `sharedAssets` paths exactly; do not redraw icons.
- Check `fonts.json` for missing fonts and fallbacks.

## Font warnings

- Font Quicksand has mixed weights across text runs. Resolve weights from styledSegments when rendering.
