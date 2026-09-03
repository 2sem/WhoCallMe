# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This project uses **Tuist 4.203.4** (managed via `mise`) as the project generator. The Xcode project files are generated — do not edit `.xcodeproj` files directly.

```bash
# Install Tuist via mise
mise install tuist

# Install SPM dependencies
mise x -- tuist install

# Generate Xcode project files
mise x -- tuist generate

# Build via xcodebuild (workspace-based)
xcodebuild -workspace WhoCallMe.xcworkspace -scheme App -configuration Debug build

# Run tests
xcodebuild -workspace WhoCallMe.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
xcodebuild -workspace WhoCallMe.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AppTests/WhoCallMeTests test
```

**IMPORTANT**: Never run `tuist generate` alone — always run `tuist install` first if dependencies may have changed.

## CI/CD

- GitHub Actions: `.github/workflows/deploy-ios.yml` — manually triggered, deploys to TestFlight or App Store via Fastlane
- Fastlane lane: `fastlane ios release [isReleasing:true|false] [description:"..."]`
- Xcode 16.2 on macOS 15 in CI

## Project Structure

```
Workspace.swift            # Declares App + ThirdParty modules
Tuist.swift                # Tuist config (Xcode compat up to 16.x)
Tuist/
  Package.swift            # Root SPM manifest — declares firebase-ios-sdk (SCM URL)
  ProjectDescriptionHelpers/
    Path+.swift            # projects("Name") helper -> Projects/Name
    TargetDependency+.swift # .Projects.ThirdParty + .Externals.Firebase.* helpers
Projects/
  App/                     # Main app target (UIKit, iPhone only, iOS 13+)
    Project.swift          # Depends on ThirdParty, GADManager; Firebase products via .external(name:)
    Sources/               # All Swift source files
    Resources/             # Assets, storyboards, strings, Core Data model
    Configs/               # Debug/Release xcconfig files
  ThirdParty/              # Static framework: RxSwift, KakaoSDK, LSExtensions, etc.
    Project.swift
```

**Firebase linking:** `firebase-ios-sdk` is declared as an external SPM dependency in the root `Tuist/Package.swift` — via the **SCM URL** form (`.package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMinor(from: "12.18.0"))`), *not* the registry `.package(id: "firebase.firebase-ios-sdk", ...)` form: the root manifest is resolved by raw SwiftPM, which has no registry scope configured for the `firebase` id, so `tuist install` fails on the id form there. The `App` target declares only the two top-level products — `.external(name: "FirebaseCrashlytics")` and `FirebaseAnalytics` (via the `.Externals.Firebase.*` helpers). SwiftPM resolves everything else transitively — `FirebaseCore` (still `import`-able in `AppDelegate.swift` without a direct dep), `GoogleAppMeasurement*`, `GUL*`, `nanopb`, `FirebaseInstallations` — now that Firebase is a direct external dependency. The old explicit product list and the `OTHER_LDFLAGS -framework` workaround were needed only for the removed `DynamicThirdParty` dynamic wrapper and are gone (verified: wiped-DerivedData clean build compiles `import FirebaseCore` and links with zero undefined symbols without them). Products declared in a `Project.swift` `packages:` array are referenced with `.package(product:)`; products from the root manifest use `.external(name:)`. Trade-off: the SCM form makes Tuist build the open-source Firebase modules (FirebaseCore, Crashlytics, Installations, GoogleUtilities, nanopb) from source rather than pulling registry binaries — slower cold resolve/compile, mitigated by Tuist binary caching. GoogleAppMeasurement / FirebaseAnalytics stay binary (closed-source `.binaryTarget`). The Crashlytics dSYM upload post-script stays on the App target. `Tuist/Package.resolved` is committed to lock the transitive graph.

## Architecture

The app is UIKit + Storyboard based, using **RxSwift** for reactive data binding throughout.

### Core Components

- **`MainViewController`** — Central view controller handling all contact operations (convert all, convert one, restore, clear photos, preview). Uses `BehaviorSubject<Mode>` and `BehaviorSubject<State>` to drive UI via RxSwift bindings.
- **`WCMDataController`** (singleton) — Core Data stack managing `OriginalContract` entities that back up contact data before conversion.
- **`RxContactController`** (singleton) — Reactive wrapper around `CNContactStore` for requesting access and fetching/saving contacts.
- **`ContactTemplateViewController`** — Renders a visual template of a contact's incoming call screen (photo + org/dept/job title). Used both for preview and for rendering to PNG for embedding in contact imageData.
- **`LSDefaults`** — Static `UserDefaults` wrapper for all app settings (feature flags for what data to include in conversions).

### Key Data Flow

1. User taps "Convert All" → `MainViewController` requests contacts via `RxContactController`
2. For each contact: `generate()` renders `ContactTemplateViewController` to image → `generateIndex()` inserts Korean cho-seong (초성) into contact note → saves via `RxContactController.save()`
3. Original contact data (image, suffix, nickname) is backed up in Core Data via `WCMDataController` before modification
4. Restore: reads `OriginalContract` from Core Data, reverts contact fields, removes WhoCallMe search tag from note

### Contact Note Tag System

The app uses a `<WhoCallMe>...</WhoCallMe>` tag in contact notes to store Korean cho-seong search indexes. When restoring, it strips this tag range from the note.

## Dependencies

Package sources:
- `ThirdParty` (`Projects/ThirdParty/Project.swift`): RxSwift 5.x, RxCocoa, KakaoSDK, LSCircleProgressView, LSExtensions, StringLogger (2sem/)
- `App` (`Projects/App/Project.swift`): GADManager (Google Ads interstitial/banner/reward management), declared in the target `packages:` array
- Firebase 12.18.x: declared as an external SPM dependency in the root `Tuist/Package.swift` via SCM URL (`github.com/firebase/firebase-ios-sdk`, `.upToNextMinor(from: "12.18.0")`). The App target declares only `FirebaseCrashlytics` + `FirebaseAnalytics` via `.external(name:)`; `FirebaseCore` and the rest resolve transitively. See "Firebase linking" above for why URL and not the registry `id` form.

## Important Constraints

- **Tuist-managed project**: Modify `Project.swift` files to add/remove targets, sources, or dependencies — not the `.xcodeproj`. After any `Project.swift` change, regenerate: `mise x -- tuist generate`
- **iOS 13.0 minimum deployment target**; iPhone only (`destinations: [.iPhone]`)
- **Bundle ID**: `com.credif.who` (App), `com.credif.who.thirdparty` (ThirdParty)
- Ads are disabled in `#if DEBUG` builds (`enableAds = false`)
- The current branch `swift-ui` is for incremental SwiftUI migration
