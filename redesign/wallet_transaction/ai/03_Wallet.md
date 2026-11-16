# Wallet

- Screen: 03
- Folder: screens/03_Wallet
- JSON: screens/03_Wallet/Wallet.json
- Preview: screens/03_Wallet/Wallet@2x.png
- Size: 390 × 844
- Layout root: NONE
- Logical screen: Wallet - Default (default)

## Central components used

- DocCard — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard
- Card 4 — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510
- Card 5 — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154806
- Card 6 — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154805
- DocCard — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard
- Card 8 — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510
- Card 5 — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154806
- Card 9 — medium · Wallet / Frame 1261154193 / Frame 1261154431 / DocCard / Frame 1261154510 / Frame 1261154805
- ri-mic-2-line — medium · Wallet / Frame 1261154402 / Frame 1261154189 / ri-mic-2-line
- Repeated section 2 — medium · Wallet / Frame 1261154402 / Frame 1261154189 / ri-mic-2-line / Group 1000007028

## Assets

- svg/icon: assets/svg/ellipse_1-95f9936b2bc1.svg (PNG: assets/png/ellipse_1-95f9936b2bc1@2x.png)
- svg/icon: assets/svg/ellipse_1-95f9936b2bc1.svg (PNG: assets/png/ellipse_1-95f9936b2bc1@2x.png)
- svg/icon: assets/svg/vector-ae0d10cffb68.svg (PNG: assets/png/vector-ae0d10cffb68@2x.png)
- svg/icon: assets/svg/vector-2690caa75103.svg (PNG: assets/png/vector-2690caa75103@2x.png)
- svg/icon: assets/svg/vector-61ce9cf0d05a.svg (PNG: assets/png/vector-61ce9cf0d05a@2x.png)
- composed-svg/graphic: assets/composed/svg/group_1000007028-1784572d9440.svg (PNG: assets/composed/png/group_1000007028-1784572d9440@2x.png)
- composed-svg/graphic: assets/composed/svg/ri_mic_2_line-c68130e75da2.svg (PNG: assets/composed/png/ri_mic_2_line-c68130e75da2@2x.png)

## Shared assets

- shared/assets/png/Vector-60d9ffb5.png: ../../shared/assets/png/Vector-60d9ffb5.png (1 placements)
- shared/assets/png/Vector-06126289.png: ../../shared/assets/png/Vector-06126289.png (1 placements)
- shared/assets/png/Group-1000007028-929dcc23.png: ../../shared/assets/png/Group-1000007028-929dcc23.png (1 placements)
- shared/assets/png/ri-mic-2-line-cb1d7cea.png: ../../shared/assets/png/ri-mic-2-line-cb1d7cea.png (1 placements)
- shared/assets/png/Vector-310f004d.png: ../../shared/assets/png/Vector-310f004d.png (1 placements)
- shared/assets/svg/Ellipse-1-95f9936b.svg: ../../shared/assets/svg/Ellipse-1-95f9936b.svg (4 placements)
- shared/assets/png/Ellipse-1-554f06b0.png: ../../shared/assets/png/Ellipse-1-554f06b0.png (4 placements)

## Node outline

```
Wallet [FRAME · absolute]
  Wallet / Frame 1261154193 [FRAME · flex-column]
    Wallet / Frame 1261154193 / Frame 1261154431 [FRAME · flex-column]
  Wallet / Frame 1261154402 [FRAME · flex-column]
    Wallet / Frame 1261154402 / Frame 1000003336 [FRAME · flex-row]
    Wallet / Frame 1261154402 / Frame 1261154189 [FRAME · flex-row]
```

## Coverage warnings

- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (Wallet / Frame 1261154402 / Frame 1261154189 / ri-mic-2-line / Group 1000007028 / Vector)
- CONSTRAINT_LAYOUT: Stretch/scale constraints need responsive checks. (Wallet / Frame 1261154402 / Frame 1261154189 / ri-mic-2-line / Group 1000007028 / Vector)

## Build notes

- Prefer the centralized components above over rebuilding the same subtree.
- Use `css` on each node for layout, box, visual, typography and asset hints.
- Use `assets` and `sharedAssets` paths exactly; do not redraw icons.
- Check `fonts.json` for missing fonts and fallbacks.

## Font warnings

- Font Quicksand has mixed weights across text runs. Resolve weights from styledSegments when rendering.
