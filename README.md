# Bestuff

## Overview

Bestuff is a SwiftUI productivity companion for capturing, scoring, and reviewing personal "stuff" entries. The iOS app persists data with SwiftData, organizes items with typed tags, offers AI-assisted creation and planning tools, and ships with widgets and App Intents so entries stay accessible across the system.

## Key Features

### Capture and review items

- Split-view browser with search, pinning, and detail panes for quickly moving between entries.【F:Bestuff/Sources/Stuff/Views/StuffNavigationView.swift†L9-L36】【F:Bestuff/Sources/Stuff/Views/StuffListView.swift†L11-L114】
- Rich filtering that combines sort options, completion state, date scopes, minimum score thresholds, and tag selection, plus saved filter presets for fast reuse.【F:Bestuff/Sources/Stuff/Views/StuffListView.swift†L41-L205】
- Quick Add sheet for lightweight entry creation and optional auto-tagging or pinning, alongside bulk tools for batch updates, labeling, completion, and deletion.【F:Bestuff/Sources/Stuff/Components/QuickAddSheet.swift†L1-L69】【F:Bestuff/Sources/Stuff/Views/StuffListView.swift†L115-L238】【F:Bestuff/Sources/Stuff/Views/StuffListView.swift†L238-L330】

### Organize with tags and recaps

- Dedicated tag management workspace with segmented filters, duplicate detection, unused tag cleanup, and drill-down into tagged items.【F:Bestuff/Sources/Tag/Views/TagNavigationView.swift†L1-L91】
- Monthly and yearly recap navigator that groups entries by period so highlights are easy to review and share.【F:Bestuff/Sources/Recap/Views/RecapNavigationView.swift†L11-L64】【F:Bestuff/Sources/Recap/Views/RecapListView.swift†L11-L68】

### Intelligence and automation

- Language-model powered predictions that convert natural language into scored items, available in-app and via the Predict Stuff App Intent.【F:Bestuff/Sources/Stuff/Models/StuffService+Prediction.swift†L1-L41】【F:Bestuff/Sources/Stuff/Intents/PredictStuffIntent.swift†L1-L34】
- Planning assistant that synthesizes actionable suggestions for today, this week, or an upcoming trip using recent high-scoring entries and tag preferences.【F:Bestuff/Sources/Plan/Models/PlanService.swift†L1-L71】【F:Bestuff/Sources/Plan/Views/PlanListView.swift†L9-L82】
- App Intents to create, update, delete, and query entries or fetch tag-based collections so Shortcuts and Siri can interact with the library.【F:Bestuff/Sources/Stuff/Intents/CreateStuffIntent.swift†L1-L41】【F:Bestuff/Sources/Stuff/Intents/GetStuffsByTagIntent.swift†L1-L53】【F:Bestuff/Sources/Stuff/Intents/GetStuffsOnDateIntent.swift†L1-L58】【F:Bestuff/Sources/Stuff/Intents/GetStuffsInMonthIntent.swift†L1-L58】【F:Bestuff/Sources/Stuff/Intents/UpdateStuffIntent.swift†L1-L61】【F:Bestuff/Sources/Stuff/Intents/DeleteStuffIntent.swift†L1-L48】

### Productivity extras

- Settings area with version info, configurable import strategies, JSON backup export/import, and subscription management entry points.【F:Bestuff/Sources/Settings/Views/SettingsListView.swift†L1-L154】
- Debug and onboarding flows for seeding sample data, clearing storage, or guiding new users through key workflows.【F:Bestuff/Sources/Debug/Views/DebugListView.swift†L1-L120】【F:Bestuff/Sources/Onboarding/Views/OnboardingNavigationView.swift†L1-L86】
- Recap and plan sheets, quick tag picker suggestions, and StoreKit subscription UI to keep routine reviews and upgrades close at hand.【F:Bestuff/Sources/Stuff/Views/StuffListView.swift†L115-L238】【F:Bestuff/Sources/Package/StoreKit/StoreSection.swift†L1-L13】

### Widgets and surfaces

- WidgetKit extension that summarizes today’s pending and completed items, highlights pinned entries, and surfaces monthly progress with multiple configuration modes.【F:Widgets/Sources/Widgets.swift†L1-L130】
- Shared SwiftData fetch helpers provide snapshot data for the widget timeline and in-app summaries.【F:Widgets/Sources/Widgets.swift†L108-L129】【F:BestuffLibrary/Sources/Stuff/Models/StuffService+Queries.swift†L1-L120】

## Targets and shared code

- **Bestuff** – SwiftUI app that wires up the model container, StoreKit subscription wrapper, configuration checks, and the main window scene.【F:Bestuff/Sources/BestuffApp.swift†L7-L48】【F:Bestuff/Sources/ContentView.swift†L9-L52】
- **BestuffLibrary** – Swift Package housing SwiftData models, services for stuff, tags, configuration, backups, and reusable utilities consumed by the app and widget targets.【F:BestuffLibrary/Package.swift†L1-L34】【F:BestuffLibrary/Sources/Stuff/Models/StuffService.swift†L1-L37】【F:BestuffLibrary/Sources/Tag/Models/TagService.swift†L1-L120】【F:BestuffLibrary/Sources/Shared/Models/BackupService.swift†L1-L120】
- **Widgets** – WidgetKit target that reuses `BestuffLibrary` to expose timeline entries driven by the same persistence stack.【F:Widgets/Sources/Widgets.swift†L1-L130】【F:Bestuff/Sources/BestuffExports.swift†L1-L1】

## Technology highlights

- SwiftUI navigation split views, sheets, and forms compose the multi-pane experience across the app.【F:Bestuff/Sources/Stuff/Views/StuffNavigationView.swift†L9-L36】【F:Bestuff/Sources/Tag/Views/TagNavigationView.swift†L22-L71】
- SwiftData powers persistent storage for stuff and tag models across app, widget, and tests.【F:Bestuff/Sources/BestuffApp.swift†L11-L36】【F:Widgets/Sources/Widgets.swift†L108-L129】
- FoundationModels’ `LanguageModelSession` drives the prediction and planning prompts for generative features.【F:Bestuff/Sources/Stuff/Models/StuffService+Prediction.swift†L17-L41】【F:Bestuff/Sources/Plan/Models/PlanService.swift†L28-L71】
- StoreKitWrapper integrates subscription flows that can be surfaced from Settings when needed.【F:Bestuff/Sources/BestuffApp.swift†L24-L35】【F:Bestuff/Sources/Package/StoreKit/StoreSection.swift†L1-L13】
- App-wide configuration fetch checks required versions before presenting the main interface.【F:Bestuff/Sources/ContentView.swift†L13-L51】【F:BestuffLibrary/Sources/Configuration/Models/ConfigurationService.swift†L13-L36】

## Building

1. Open `Bestuff.xcodeproj` in Xcode 16 or later to satisfy the Swift 6.2 toolchain and iOS 18 platform requirement declared by the package manifest.【F:BestuffLibrary/Package.swift†L1-L18】
2. Select the **Bestuff** scheme and run it on an iOS 18 simulator or device. The app bootstraps its SwiftData container and subscriptions automatically.【F:Bestuff/Sources/BestuffApp.swift†L11-L48】
3. Optional: execute `ci_scripts/ci_post_clone.sh` on CI machines to align with the project’s Xcode Cloud defaults.【F:ci_scripts/ci_post_clone.sh†L1-L9】

## Running tests

```sh
swift test --package-path BestuffLibrary
```

The package-level tests cover backup import/export, tag utilities, filtering, and service helpers shared with the app and widgets.【F:BestuffLibrary/Tests/BackupServiceTests.swift†L1-L160】【F:BestuffLibrary/Tests/FilterLogicTests.swift†L1-L120】【F:BestuffLibrary/Tests/TagServiceTests.swift†L1-L160】 You can also run UI or intent tests from Xcode using the **Bestuff** scheme as needed.

## Repository layout

| Path | Description |
| --- | --- |
| `Bestuff/` | SwiftUI app target sources, assets, and configurations. |
| `BestuffLibrary/` | Swift Package with shared models, services, and tests. |
| `Widgets/` | WidgetKit extension that surfaces stuff summaries. |
| `ci_scripts/` | Automation helpers invoked by Xcode Cloud pipelines. |

## Configuration and environment

- Remote JSON configuration controls update requirements before presenting the UI, ensuring older builds prompt for upgrades when necessary.【F:BestuffLibrary/Sources/Configuration/Models/ConfigurationService.swift†L19-L36】【F:Bestuff/Sources/ContentView.swift†L13-L51】
- AppStorage toggles preserve onboarding completion, debug tools, and saved filters across launches.【F:Bestuff/Sources/ContentView.swift†L10-L21】【F:Bestuff/Sources/Stuff/Views/StuffListView.swift†L23-L38】
- Debug and onboarding experiences can seed realistic sample data into the SwiftData store for demos or testing.【F:Bestuff/Sources/Debug/Views/DebugListView.swift†L1-L120】【F:Bestuff/Sources/Onboarding/Views/OnboardingNavigationView.swift†L60-L63】
