# Asset mapping — Figma "🏏 SPOTO (Copy) / User App" → `ui_kit`

Single source of truth for re-mapping future Dev-Export packages. Every SVG below is the
**deduped representative** of a visual-equivalent group (identical icons were re-exported
per screen with different node ids). Original files remain in `new_screens/` untouched.

- Destination root: `packages/ui_kit/assets/referee_booking/`
- `icons/` — SVGs (rendered via `SportoSvgIcon`)
- `images/` — raster (`avatar_referee.png`) with 1x/2x/3x variants
- Registered in `packages/ui_kit/pubspec.yaml`; rendered through `SportoAssets` /
  `SportoRefreeBookingIcons` / `SportoSvgIcon`.
- **Excluded (design artifact, never build):** the mock status bar — Figma nodes
  `Group 2`, `Group 1000003334`, `Group 1000003335`, `Group 1000003336`, `Group 3`,
  `Frame 1000003335`, `Frame 1000003339`, `Line 1..5 (Stroke)`, `20:23` (time/signal/wifi/battery).

## Icons

| New asset (`assets/referee_booking/icons/`) | Figma node name | Original representative path (under `new_screens/`) | Colour | Used by |
|---|---|---|---|---|
| `ic_back.svg` | Vector | `SPOTO_(Copy)_Dev_Export/screens/01_Referees/assets/svg/Vector-2840_4555.svg` | white + drop shadow | all 21 screens (header) |
| `ic_search.svg` | Vector | `.../04_Referees/assets/svg/Vector-2890_5553.svg` | gradient `#7AD3FF→#4FBAF0` | E1-04,05,06 |
| `ic_chevron_right.svg` | Vector | `.../01_Referees/assets/svg/Vector-2867_2183.svg` | gradient `#7AD3FF→#4FBAF0` | E1-01, E1-13, E1-14 |
| `ic_check.svg` | Stroke 3 | `.../10_Payment/assets/svg/Stroke_3-2891_6768.svg` | `#FFFFFF` | E1-10,16 (saved method) |
| `ic_check_green.svg` | Icon | `.../07_Referees/assets/svg/Icon-2890_6139.svg` | `#2BB673` | E1-07 |
| `ic_check_blue.svg` | Icon | `.../07_Referees/assets/svg/Icon-2890_6187.svg` | `#7AD3FF` | E1-07 |
| `ic_credit_card.svg` | vuesax/linear/card | `.../10_Payment/assets/composed/svg/vuesax-linear-card-2891_6749.svg` | white | E1-10,16 |
| `ic_wallet.svg` | vuesax/linear/wallet-3 | `.../10_Payment/assets/composed/svg/vuesax-linear-wallet-3-2891_6757.svg` | white | E1-10,16 |
| `ic_add_square.svg` | vuesax/linear/add-square | `.../10_Payment/assets/composed/svg/vuesax-linear-add-square-I2891_6771_3_5141.svg` | `#A0A0A0` | E1-10,16 |
| `ic_gps.svg` | gps | `.../04_Referees/assets/composed/svg/gps-2890_5543.svg` | gradient `#7AD3FF→#4FBAF0` | E1-04,05,06 |
| `ic_gps_sm.svg` | gps | `.../04_Referees/assets/composed/svg/gps-2890_5544.svg` | gradient `#7AD3FF→#4FBAF0` | E1-04,05,06 |
| `ic_clock_orange.svg` | clock | `.../01_Referees/assets/composed/svg/clock-2868_2399.svg` | gradient `#FF9364→#F25F33` | E1-01,02,09 |
| `ic_clock_green.svg` | clock | `SPOTO_(Copy)_Dev_Export_2/screens/03_Booking_Details_-_Completed/assets/composed/svg/clock-2885_3622.svg` | `#2BB673` | E2-01/02/03 |
| `ic_pin_green.svg` | Vector | `.../05_Referees/assets/svg/Vector-2890_5851.svg` | `#2BB673` | E1-05..08,09,12..16 |
| `ic_pin_green_sm.svg` | Vector | `.../16_Payment/assets/svg/Vector-2903_2059.svg` | `#2BB673` | E1-16 |
| `ic_pin_gold.svg` | Vector | `SPOTO_(Copy)_Dev_Export_2/screens/01_Booking_Details_-_Upcoming/assets/svg/Vector-2884_2961.svg` | `#F4B41A` | E1-01, E2-* |
| `ic_pin_gold_sm.svg` | Vector | `.../01_Referees/assets/svg/Vector-2867_2028.svg` | gradient `#FFD572→#FEBD38` | E1-01, E1-13 |
| `ic_star_gold.svg` | Vector | `.../14_Confirm_Booking/assets/svg/Vector-2902_1870.svg` | gradient `#FFD572→#FEBD38` | E1-14 |
| `ic_star_gold_sm.svg` | Vector | `.../14_Confirm_Booking/assets/svg/Vector-2902_1825.svg` | gradient `#FFD572→#FEBD38` | E1-14 |
| `ic_flash_green.svg` | flash / vuesax/linear/flash | `.../07_Referees/assets/composed/svg/flash-I2890_6133_1_1196.svg` | `#2BB673` | E1-07 |
| `ic_profile_2user.svg` | profile-2user | `.../07_Referees/assets/composed/svg/profile-2user-I2890_6251_1_38473.svg` | gradient `#7AD3FF→#4FBAF0` | E1-07 |
| `status_dot_green.svg` | Ellipse 47 | `.../14_Confirm_Booking/assets/svg/Ellipse_47-2902_1876.svg` | `#2BB673` | E1-01,13,14,15 |
| `status_dot_green_sm.svg` | Vector | `.../11_Cricket_Match/assets/svg/Vector-2898_6935.svg` | `#2BB673` | E1-11,17 |
| `status_dot_gold.svg` | Vector | `.../09_Confirm_Booking/assets/svg/Vector-2891_6590.svg` | gradient `#FFD572→#FEBD38` | E1-09,15 |
| `dot_separator.svg` | Ellipse 2/3/4/5 | `.../01_Referees/assets/svg/Ellipse_3-2867_1526.svg` | `#666666` | many |
| `dot_separator_sm.svg` | Ellipse 2/3 | `.../01_Referees/assets/svg/Ellipse_2-2868_2373.svg` | `#A0A0A0` | many |
| `divider_hairline.svg` | Line 8 | `.../09_Confirm_Booking/assets/svg/Line_8-2891_6713.svg` | gradient white 0.1→1→0.1 | all cards |
| `divider_hairline_short.svg` | Line 8 | `.../13_Your_Sponsorship/assets/svg/Line_8-2900_7611.svg` | gradient white | E1-13 |
| `divider_solid.svg` | Line 7 | `.../10_Payment/assets/svg/Line_7-2891_6739.svg` | `#283040` | E1-10 |
| `divider_vertical.svg` | Line 8 / Line 9 | `.../09_Confirm_Booking/assets/svg/Line_9-2891_6577.svg` | gradient white | E1-09,11,15,17 |
| `ic_sport.svg` | Vector | `.../04_Referees/assets/svg/Vector-2890_5500.svg` | white | E1-04,05,06 (header sport glyph) |
| `sport_cricket.svg` | Frame 1171275310 | `.../03_Referees/assets/composed/svg/Frame_1171275310-2890_5198.svg` | `#313135` tile + white glyph | E1-03 |
| `sport_football.svg` | Frame 1171275310 | `.../03_Referees/assets/composed/svg/Frame_1171275310-2890_5231.svg` | `#1A1D23` + white glyph | E1-03 |
| `rating_stars_gold.svg` | Frame 1261154788 | `.../14_Confirm_Booking/assets/composed/svg/Frame_1261154788-2902_1840.svg` | gold | E1-14 |
| `rating_stars_gold_lg.svg` | Frame 1261154763 | `SPOTO_(Copy)_Dev_Export_2/screens/04_Booking_Details_-_Completed/assets/composed/svg/Frame_1261154763-2885_3711.svg` | gold + `#373435` | E2-04 |
| `rating_stars_gold_pg.svg` | Frame 1261154767 | `SPOTO_(Copy)_Dev_Export_2/screens/04_Booking_Details_-_Completed/assets/composed/svg/Frame_1261154767-2885_3708.svg` | gold + `#373435` | E2-04 |

## Raster

| New asset | Figma node | Original path | Notes |
|---|---|---|---|
| `images/avatar_referee.png` (+ `2.0x/`, `3.0x/`) | Frame 2 | `.../01_Referees/assets/images/original/image-1-c0944a2003.jpg` | Source 1024×1024 JPG; downscaled to 50/100/150 px PNG variants. Used as referee avatar (40/50 px) in ~11 screens. Exposed via `SportoAssets.avatarReferee`. |

## Notes / follow-ups

- **SVG sanitization (8 files):** Figma exported `<foreignObject>` (backdrop-blur artifact, transparent) and `<filter>` (drop shadows / glows) which `flutter_svg` cannot render. These were stripped from `ic_back`, `ic_chevron_right`, `ic_pin_gold`, `sport_cricket`, `sport_football`, `status_dot_green`, `status_dot_green_sm`, `status_dot_gold`. The visual drop-shadows/glows are re-applied in Flutter via `BoxShadow` in the widget slice. Verified by `packages/ui_kit/test/referee_booking_svg_test.dart` (would have failed on those features; now passes — no parse errors, no unsupported features, no divergent renders).
- **Icon tinting:** monochrome-white icons (`ic_back`, `ic_sport`, `ic_credit_card`, `ic_wallet`) can be tinted at runtime via `SportoSvgIcon(color:)`; accent icons use **baked gradients** and must render untinted (two colour variants are provided where both are used, e.g. `ic_clock_orange` / `ic_clock_green`).
- **Health/QA:** duplicated `Ellipse n` dot separators and `Line n` dividers collapsed to one asset each.
- **Not migrated as assets:** non-cricket/football sport icons in the Select Sport grid are **emoji text** in Figma (🏸 🏀 🎯 🏑 🤼 🏃 🏓 🏐 🏐); they will be rendered as text/glyphs in the widget slice, not as SVG files.
- Re-exports: map new node ids to these semantic names using the "Figma node name" + dimensions column.
