# Fonts

Export (`fonts.json`): 2 families.

| Family | Uses | Source in export | App |
|---|---|---|---|
| Quicksand | 2 633 | marked `system`, fallback stack + substitute `Inter` | **already bundled** in `packages/ui_kit/assets/fonts/` (400/500/600/700) and used by `SportoTextStyles` |
| Mulish | 1 (Prize Pool) | system | already bundled, not needed by this screen |

- New families added: **0**.
- Fallback used: **none** — the `MISSING_FONT` warning on Quicksand is a Figma client-side availability
  note, not a real gap; the app ships the face.
- Metric impact: none. The list uses only sizes 10, 11, 12, 13, 14, 16, 18, 24 — all present in
  `SportoTextStyles`, so glyph widths match the export at the design width.
- Line-height drift: export is `AUTO`; the app's `SportoTextStyles.text()` uses `height: 1.25`.
  Measured line boxes agree within 0.3 px for 12 px and above; 10 px is 13 px in the export vs
  15 px in the app. Recorded, not "fixed" (changing the global default would move every screen).
