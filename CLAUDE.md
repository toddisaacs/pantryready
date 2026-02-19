# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run (choose appropriate profile)
./scripts/run_local.sh          # Mock data (default for dev)
./scripts/run_dev.sh            # Firestore dev profile
./scripts/run_prod.sh           # Firestore prod profile
./scripts/run.sh [dev|local|prod] [chrome|ios|android]  # Flexible

# Test
flutter test                    # All tests
flutter test test/models/pantry_item_test.dart  # Single test file
flutter test --coverage         # With coverage

# Code quality
dart format .                   # Format
flutter analyze                 # Static analysis

# Version management
./scripts/version.sh [patch|minor|major]
```

## Architecture

PantryReady is a pantry inventory management app with preparedness/survival tracking. It supports multiple data backends via a service abstraction layer.

### Service Layer (Factory Pattern)

`DataService` is an abstract interface. `DataServiceFactory` creates the appropriate implementation at runtime based on `EnvironmentConfig`:

- **MockDataService** — In-memory with pre-seeded sample data; use for UI development
- **DataService** (local) — Empty in-memory store
- **EnvironmentFirestoreService** — Firestore with environment-aware collection naming (`pantry_items_{profile}`)

Product lookup follows the same pattern: `ProductApiService` interface → `OpenFoodFactsService` or `MockProductApiService`.

### State Management

No external state management library. `main.dart` uses `StatefulWidget` with manual stream subscriptions to `DataService`. Screens receive callbacks and data as constructor parameters. Clean up subscriptions in `dispose()`.

### Configuration

`EnvironmentConfig` (static class) manages environment (`local`/`dev`/`prod`), data source (`mock`/`local`/`firestore`), and Firestore profile. Set at build time via `--dart-define=ENVIRONMENT=dev` or changed at runtime via `EnvironmentSettingsScreen`.

### Data Model

`PantryItem` is the core model with:
- `ItemBatch` list for quantity tracking (each batch has purchase/expiry dates)
- `SystemCategory` and `SurvivalScenario` enums for preparedness classification
- Daily consumption rate, min/max stock levels for preparedness calculations
- Full `toJson()`/`fromJson()` (Firestore uses `toFirestore()`/`fromFirestore()`)

### Firebase Setup

`lib/firebase_options.dart` is git-ignored. For local development without Firebase, run `./scripts/setup_firebase.sh` and choose option 1 (uses placeholder values; app runs on local/mock storage). Real config files (`firebase_options.dart`, `firebase.json`, platform google-services files) are all git-ignored.

## Code Style

Enforced via `analysis_options.yaml`:
- Single quotes, `const` constructors, `final` for fields/locals
- No `print()` statements — use proper logging
- Always declare return types
- Trailing commas required in multi-line parameter lists
- Cancel stream subscriptions and close sinks

## Testing

Tests live in `test/` mirroring `lib/` structure. Screens use `MockDataService` and `MockProductApiService` for isolation. Pre-commit hooks (`.githooks/`) run format, analyze, and tests — enable with `git config core.hooksPath .githooks`.
