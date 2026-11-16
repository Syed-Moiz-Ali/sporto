# Wallet

- Screen: 02
- Folder: screens/02_Wallet
- JSON: screens/02_Wallet/Wallet.json
- Preview: screens/02_Wallet/Wallet@2x.png
- Size: 390 × 844
- Layout root: NONE
- Logical screen: Wallet - Default (default)

## Central components used

- DocCard — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard
- Card 4 — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510
- Card 5 — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154806
- Card 6 — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154805
- DocCard — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard
- Card 8 — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510
- Card 5 — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154806
- Card 9 — medium · Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154805

## Assets

- svg/icon: assets/svg/vector-5af69e49fbea.svg (PNG: assets/png/vector-5af69e49fbea@2x.png)
- svg/icon: assets/svg/vector-3b3489cff0dd.svg (PNG: assets/png/vector-3b3489cff0dd@2x.png)
- composed-svg/logo: assets/composed/svg/logout-8c4eda5237c1.svg (PNG: assets/composed/png/logout-8c4eda5237c1@2x.png)
- composed-svg/logo: assets/composed/svg/vuesax_linear_logout-95a06f14e4a3.svg (PNG: assets/composed/png/vuesax_linear_logout-95a06f14e4a3@2x.png)
- svg/icon: assets/svg/vector-63b2d0c8247a.svg (PNG: assets/png/vector-63b2d0c8247a@2x.png)
- svg/icon: assets/svg/ellipse_1-95f9936b2bc1.svg (PNG: assets/png/ellipse_1-95f9936b2bc1@2x.png)
- svg/icon: assets/svg/ellipse_1-95f9936b2bc1.svg (PNG: assets/png/ellipse_1-95f9936b2bc1@2x.png)
- svg/icon: assets/svg/vector-71e861cd69ea.svg (PNG: assets/png/vector-71e861cd69ea@2x.png)
- svg/icon: assets/svg/vector-a4eb49850c93.svg (PNG: assets/png/vector-a4eb49850c93@2x.png)

## Shared assets

- shared/assets/png/Vector-310f004d.png: ../../shared/assets/png/Vector-310f004d.png (1 placements)
- shared/assets/svg/Ellipse-1-95f9936b.svg: ../../shared/assets/svg/Ellipse-1-95f9936b.svg (4 placements)
- shared/assets/png/Ellipse-1-554f06b0.png: ../../shared/assets/png/Ellipse-1-554f06b0.png (4 placements)

## Node outline

```
Wallet [FRAME · absolute]
  Wallet / Frame 1261154190 [FRAME · flex-column]
    Wallet / Frame 1261154190 / Frame 1261154430 [FRAME · flex-column]
    Wallet / Frame 1261154190 / Frame 1261154192 [FRAME · flex-row]
    Wallet / Frame 1261154190 / Frame 1261154431 [FRAME · flex-column]
  Wallet / Frame 1261154402 [FRAME · flex-column]
    Wallet / Frame 1261154402 / Frame 1000003336 [FRAME · flex-row]
```

## Coverage warnings

- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154571 / Frame 1261154430 / vuesax/linear/logout / logout / Vector)
- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (Wallet / Frame 1261154190 / Frame 1261154431 / Frame 1261154571 / Frame 1261154430 / vuesax/linear/logout / logout / Vector)

## Build notes

- Prefer the centralized components above over rebuilding the same subtree.
- Use `css` on each node for layout, box, visual, typography and asset hints.
- Use `assets` and `sharedAssets` paths exactly; do not redraw icons.
- Check `fonts.json` for missing fonts and fallbacks.

## Font warnings

- Font Quicksand has mixed weights across text runs. Resolve weights from styledSegments when rendering.
