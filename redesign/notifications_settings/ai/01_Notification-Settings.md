# Notification Settings

- Screen: 01
- Folder: screens/01_Notification-Settings
- JSON: screens/01_Notification-Settings/Notification-Settings.json
- Preview: screens/01_Notification-Settings/Notification-Settings@2x.png
- Size: 390 × 844
- Layout root: NONE
- Logical screen: Notification Settings - Default (default)

## Central components used

- Repeated section 1 — medium · Notification Settings / Frame 1000003334
- Repeated section 2 — medium · Notification Settings / Frame 1000003334 / Frame 1000003336

## Assets

- svg/icon: assets/svg/vector-dd3aadc35b6d.svg (PNG: assets/png/vector-dd3aadc35b6d@2x.png)
- svg/icon: assets/svg/vector-430c0593dc44.svg (PNG: assets/png/vector-430c0593dc44@2x.png)
- svg/icon: assets/svg/vector-22b2877f7ebe.svg (PNG: assets/png/vector-22b2877f7ebe@2x.png)
- svg/icon: assets/svg/vector-0c9ed3cffce8.svg (PNG: assets/png/vector-0c9ed3cffce8@2x.png)
- svg/icon: assets/svg/vector-54e564abe7b9.svg (PNG: assets/png/vector-54e564abe7b9@2x.png)
- svg/icon: assets/svg/vector-6953da7ddff6.svg (PNG: assets/png/vector-6953da7ddff6@2x.png)

## Shared assets

- shared/assets/png/Vector-310f004d.png: ../../shared/assets/png/Vector-310f004d.png (1 placements)

## Node outline

```
Notification Settings [FRAME · absolute]
  Notification Settings / Frame 1261154190 [FRAME · flex-column]
    Notification Settings / Frame 1261154190 / Frame 1261154499 [FRAME · flex-column]
    Notification Settings / Frame 1261154190 / Frame 1261154423 [FRAME · flex-column]
  Notification Settings / Frame 1000003334 [FRAME · flex-column] → Repeated section 1 (medium)
    Notification Settings / Frame 1000003334 / Frame 1000003336 [FRAME · flex-row] → Repeated section 2 (medium)
```

## Coverage warnings

- None.

## Build notes

- Prefer the centralized components above over rebuilding the same subtree.
- Use `css` on each node for layout, box, visual, typography and asset hints.
- Use `assets` and `sharedAssets` paths exactly; do not redraw icons.
- Check `fonts.json` for missing fonts and fallbacks.
