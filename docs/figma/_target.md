# Target

Repo:        melos monorepo (`melos.yaml`, `apps/*`, workspace `pubspec.yaml`)
Apps:        `apps/partner_app`, `apps/referee_app`
Packages:    `packages/core`, `partner_data`, `referee_data`, `shared_domain`, `ui_kit`

## App: apps/partner_app

Resolved without asking — the export answers it:

- Folder name: `spoto_partner_tournament_redesign`
- `package-manifest.json` → `source.fileName = "🏏 SPOTO (Copy)"`, `source.page.name = "Partner App"`
- Screen content is tournament **organizer** content (own tournaments, registrations, approval states) — the partner app, not the referee app.

Every file lands in `apps/partner_app` plus its design system (`packages/ui_kit`).
No new package.

## Scope chosen by user

**Tournaments list** — export `09`, `10`, `14`, `36` (+ `39`–`43` tab strips) into the
existing Tournaments tab screen.

## Module

`apps/partner_app/lib/features/tournaments/` — existing module, existing routes
(`/`, `/tournaments/:id`, `/create-tournament`, `/tournaments/live`).

## State of the repo before this pass (important)

A previous import pass exists: commit `e57e8ad` "feat(partner): add tournament redesign
screens and theme tokens" (12 Nov 2026). The export is dated **15 Nov 2026**, so the design
is newer than that implementation.

Leftovers from that pass:

- `apps/partner_app/lib/figma/{components,screens/tokens,screens/cricket_match}` — **empty
  directories only** (0 files). Not tracked by git. They violate the no-parallel-module rule;
  they are removed as part of this pass (no content is lost).
- `apps/partner_app/assets/figma/{screens/01_cricket_match,shared}/{png,svg}` — **empty
  directories only** (0 files), also not registered in `pubspec.yaml`. Removed.
- The previous pass hard-coded placeholder values in the list screen
  (`matchesScheduled: 63`, `champions: 'Hyd Highlanders'`, `refereeText: '2 awaiting referee'`).
  These are data the API does not return; they are logged as data gaps and removed.

## Routing / wiring that must not change

| Concern | Current |
|---|---|
| Screen file | `lib/features/tournaments/presentation/screens/tournaments_redesign_screen.dart` |
| Mounted by | `partner_main_screen.dart` (tab index 1, `embedded: true`) |
| Data | `PartnerApiBloc` + `LoadPartnerApiBootstrapEvent` |
| Create | `context.push(AppRouter.createTournamentRoute)` |
| Detail | `context.push(AppRouter.tournamentDetailRoute(id))` |
| Live list | `context.push(AppRouter.liveTournamentsRoute)` — **only entry point in the app** |
