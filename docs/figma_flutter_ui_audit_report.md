# SPORTO Figma to Flutter UI Audit and Implementation Plan

Date: 2026-08-17  
Design file: `?? SPORTO (Copy)`  
Baseline design viewport: `390 x 844` logical pixels  
Scope requested: visual implementation plan only; no application code changed.

## Executive Summary

The current Flutter codebase has a reusable SPORTO UI kit, local font files, shared design tokens, responsive helpers, and a small set of Figma golden tests. It is not yet pixel-complete against the supplied Figma file.

The implementation scope is strictly limited to two product areas:

- Referee App: 57 top-level canvas children.
- Partner App: 51 top-level canvas children.

The User App area visible in the Figma file is owned by another developer and is deliberately excluded from this audit, implementation plan, manifest work, and validation scope.

The manifest identifies the majority of Referee and Partner states as `not_started`. A few Referee auth/onboarding and match-flow states are marked implemented, but their visual validation remains `needs_asset_review`.

## Current State Findings

### Existing strengths

- `packages/ui_kit` already centralizes buttons, cards, fields, navigation, backgrounds, scoring widgets, and theme extensions.
- Local font assets exist for Space Grotesk, Quicksand, Inter, and Mulish.
- `SportoLayoutTokens` contains common spacing/radius values based on the Figma canvas.
- `SportoTheme` and `SportoDesignTokens` centralize colors, gradients, borders, and surfaces.
- Golden tests already establish the correct testing pattern: fixed viewport, `devicePixelRatio = 1`, explicit font loading, and PNG comparison.
- Referee home, match verification, conduct toss intro, and referee login have documented previous geometry work.

### Blocking gaps

- No complete screen-by-screen implementation/validation matrix exists beyond the manifest statuses.
- Most Figma states are not implemented, especially live scoring, final results, match-list variants, profile, partner dashboard, tournament creation, schedules, and partner live-match details.
- Existing implemented states still defer icon and asset verification.
- Some Figma states have different content heights while sharing a route; Flutter must model each state, not only the route shell.
- `MaterialApp` is configured with `SportoTheme.darkTheme` as both `theme` and `darkTheme` in both apps. The light design path is therefore not actually available at runtime.
- The shared theme defaults to Quicksand, while Space Grotesk, Inter, and Mulish are also registered. Each Figma text style must be measured and assigned deliberately rather than relying on the global fallback.
- Several widgets use Material icons or custom-drawn substitutes where the Figma file contains specific icons/assets. These must be replaced or verified against exported Figma assets.
- Root-level `flutter test packages/ui_kit/test/figma` is invalid because the repository root is not a Flutter package. Tests must execute from `packages/ui_kit` or through a package-aware Melos command.

## Screen Scope

### Referee App

Priority implementation groups from the manifest:

- Authentication: splash states, onboarding states 01-12, returning login, OTP/login variants.
- Main shell: home viewport and long-content variants, matches list states, profile.
- Verification: match verification state 1 and long state 2.
- Toss: intro, states 2-4, long state, completion.
- Scoring: seven score-entry states, two final-result states, tied state, and two result-submitted states.
- Shared components: toss extracted group and score-entry extracted section.

### Partner App

- Authentication: login, splash states, onboarding states 01-11, returning login.
- Main shell: home, cricket match/history, schedules, profile.
- Tournament operations: live match details states 1-6, tournament creation states 1-9 and completion.
- Dashboard/detail: tournament dashboard long state and schedules long state.
- Shared components: sort bottom sheet and tournament wizard extracted content.

## Pixel-Perfect Verification Checklist

Every Figma frame must be checked at its exact exported size before responsive adaptation.

### Canvas and system UI

- Frame width and content height match the Figma frame exactly.
- Safe-area top and bottom behavior matches the intended design, including status/navigation bar treatment.
- Scroll content begins and ends at the same coordinates as the design.
- Keyboard, focus, and resize behavior do not shift fixed elements unexpectedly.
- Android and iOS system-bar colors, icon brightness, and edge-to-edge mode are explicit.

### Typography

- Font family is identified from the Figma text style, not inferred from the screen name.
- Weight maps to the correct local font file.
- Font size, line height, letter spacing, case, and text alignment match.
- Text box width, wrapping, truncation, baseline, and paragraph spacing match.
- Font loading is local and deterministic for release builds and golden tests.
- No accidental Material default typography remains.

### Color and effects

- Background fills, gradients, opacity, and blend direction match.
- Card/field/nav surfaces match in both solid color and alpha compositing.
- Borders use the exact color, width, and radius.
- Shadows match x/y offset, blur, spread, and opacity.
- Blur/glass effects are validated on a real device because screenshot compositing can differ from widget tests.
- Active, inactive, disabled, error, success, live, upcoming, and submitted states are all captured.

### Geometry

- Outer margins and horizontal content width.
- Header height and title baseline.
- Section gaps and repeated vertical rhythm.
- Card width/height, internal padding, and corner radius.
- Button dimensions, label baseline, icon-to-label gap, and pressed/disabled states.
- Text-field height, label position, hint position, prefix/suffix spacing, cursor, and focus border.
- Checkbox/radio dimensions and selected-state treatment.
- Bottom navigation height, item width, icon size, label baseline, active indicator, and bottom inset.
- Modal/bottom-sheet height, handle, radius, backdrop opacity, and safe-area padding.

### Assets and icons

- Export every Figma raster/SVG asset at the intended density.
- Verify crop, aspect-fit/fill behavior, transparent padding, and tint.
- Replace approximate Material icons and custom substitutes when a Figma asset exists.
- Verify logos, flags, player/team images, coin artwork, sports icons, ads, and empty-state art.
- Keep asset names and a source-node reference in an asset inventory.

### Interaction states

- Initial, populated, selected, unselected, focused, validation-error, loading, success, empty, offline, and submitted states.
- Back navigation and route transitions.
- Form validation messages and their layout impact.
- OTP input behavior, timer, resend state, and button loading state.
- Tournament wizard step progression and state-specific fields.
- Match scoring state transitions and result submission states.
- Touch target minimums and semantics labels without changing visual bounds.

## Required Implementation Sequence

### Phase 0: Freeze scope and source of truth

- Keep User App excluded from all implementation and validation work.
- Confirm target Flutter version, Android/iOS target devices, device pixel ratio, and system-bar policy.
- Create a Figma export package containing frame PNGs, SVGs, raster assets, and node metadata.
- Revoke/regenerate the Figma access token after use because it was shared in chat.

### Phase 1: Design token audit

- Extract Figma colors, typography, spacing, radii, borders, shadows, gradients, and effects.
- Compare them to `sporto_design_tokens.dart` and `sporto_theme.dart`.
- Split tokens by semantic role where current values are reused incorrectly.
- Decide exact font family per text role and remove unintentional fallback dependence.
- Add missing icon/asset metadata and remove approximations.

### Phase 2: Shared component calibration

Calibrate and golden-test components before screen work:

- Primary/secondary buttons.
- Text fields and OTP cells.
- Cards, glass containers, badges, tabs, checkboxes, radios, and dividers.
- Bottom navigation and shell/header.
- Bottom sheets and dialogs.
- Cricket match, toss, score-entry, final-result, and result-submitted primitives.

Each component needs states for normal, selected, disabled, focused, error, loading, and success where applicable.

### Phase 3: Implement by user journey

Recommended order:

1. Shared auth: splash, onboarding, login, returning login, OTP.
2. Referee shell: home, match list, profile.
3. Referee verification and toss flow.
4. Referee scoring, final result, tied result, and submission states.
5. Partner shell: home, tournaments, schedules, profile.
6. Partner live-match details and dashboard states.
7. Partner tournament creation wizard and completion.
8. Remaining extracted components and edge states.

### Phase 4: Visual validation

- Add one golden test per manifest frame/state.
- Render at exact Figma dimensions with `devicePixelRatio = 1`.
- Compare Flutter output against Figma PNGs using pixel diff and an overlay image.
- Fix in this order: canvas/system UI, geometry, typography, color/effects, assets, then interaction polish.
- Validate at 320x568, 390x844, 430x932, and at least one physical Android and iOS device.
- Record status in `figma_screen_manifest.yaml` only after the frame passes.

## Definition Of Done

A screen is `validated` only when:

- Its exact Figma frame and all named states have a corresponding route/test fixture.
- Fonts and assets are local, loaded deterministically, and source-mapped.
- Golden comparison has no unexplained geometry or typography differences.
- Responsive checks pass without overflow or clipped content.
- Interaction states are tested, not only the initial screenshot.
- Android and iOS safe-area/system-bar behavior is confirmed.
- The manifest contains the implementation file, route, reference size, validation date, and any accepted intentional difference.

The overall project should not be called 100% Figma-perfect until every in-scope manifest entry is `validated`; `implemented` alone is insufficient.

## Immediate Next Actions

1. Export only Referee and Partner Figma frames/assets and create a complete asset/font inventory.
2. Audit token and typography differences before adding more screen-specific constants.
3. Correct runtime theme wiring and establish the package-level golden-test command.
4. Calibrate shared components, then implement and validate screens in the journey order above.
