# Shared Asset Library

Generated: 2026-11-16T10:28:36.907Z

These files are identical copies of assets used by more than one screen.
They live in `shared/assets/` so you do not have to hunt down duplicates.

Per-screen copies are still present in each screen's `assets/` folder so a
single screen folder can be opened in isolation. Use the shared copies when
building shared components or a global asset pipeline.

## How to use

1. Open `shared/assets/manifest.json` for machine-readable references.
2. From a screen JSON, use `sharedAssets[].relativeFromScreen`.
3. From package root, use `sharedAssets[].file`.
4. Each asset entry lists the screens and layer paths where it is used.

Total shared assets: 1

## 1. shared/assets/png/Vector-310f004d.png

- Kind: svg
- Role: icon
- MIME: image/png
- Size: 694 bytes
- Used by 4 screens (4 placements)

- Screen 01: On-boarding Screen
  - JSON: screens/01_On-boarding-Screen/On-boarding-Screen.json
  - On-boarding Screen / Frame 1000003334 / Frame 1000003337 / Back / Vector (vector)
- Screen 02: Add Bank Account
  - JSON: screens/02_Add-Bank-Account/Add-Bank-Account.json
  - Add Bank Account / Frame 1000003334 / Frame 1000003337 / Back / Vector (vector)
- Screen 03: Back Account
  - JSON: screens/03_Back-Account/Back-Account.json
  - Back Account / Frame 1000003334 / Frame 1000003337 / Back / Vector (vector)
- Screen 04: Bank Account Details
  - JSON: screens/04_Bank-Account-Details/Bank-Account-Details.json
  - Bank Account Details / Frame 1261154402 / Frame 1000003336 / Back / Vector (vector)
