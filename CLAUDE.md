# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This project uses **Tuist 4.38.2** (managed via `mise`) as the project generator. The Xcode project files are generated — do not edit `.xcodeproj` files directly.

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
Workspace.swift            # Declares App + ThirdParty + DynamicThirdParty modules
Tuist.swift                # Tuist config (Xcode compat up to 16.x)
Tuist/
  Package.swift            # Root SPM package (Tuist-controlled)
  ProjectDescriptionHelpers/
    Path+.swift            # projects("Name") helper -> Projects/Name
    TargetDependency+.swift # TargetDependency.Projects.ThirdParty / .DynamicThirdParty
Projects/
  App/                     # Main app target (UIKit, iPhone only, iOS 13+)
    Project.swift          # Depends on ThirdParty, DynamicThirdParty, GADManager
    Sources/               # All Swift source files
    Resources/             # Assets, storyboards, strings, Core Data model
    Configs/               # Debug/Release xcconfig files
  ThirdParty/              # Static framework: RxSwift, KakaoSDK, LSExtensions, etc.
    Project.swift
  DynamicThirdParty/       # Dynamic framework: Firebase (Crashlytics, Analytics, Messaging, RemoteConfig)
    Project.swift
```

**Why two frameworks?** Firebase requires dynamic linking; everything else is bundled as a static framework to reduce app size and launch time.

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

All SPM packages are defined in the respective `Project.swift` files:
- `ThirdParty`: RxSwift 5.x, RxCocoa, KakaoSDK, LSCircleProgressView, LSExtensions, StringLogger (2sem/)
- `DynamicThirdParty`: Firebase 11.8.x (Crashlytics, Analytics, Messaging, RemoteConfig)
- `App`: GADManager (Google Ads interstitial/banner/reward management)

## Important Constraints

- **Tuist-managed project**: Modify `Project.swift` files to add/remove targets, sources, or dependencies — not the `.xcodeproj`. After any `Project.swift` change, regenerate: `mise x -- tuist generate`
- **iOS 13.0 minimum deployment target**; iPhone only (`destinations: [.iPhone]`)
- **Bundle ID**: `com.credif.who` (App), `com.credif.who.thirdparty` (ThirdParty), `com.credif.who.thirdparty.dynamic` (DynamicThirdParty)
- Ads are disabled in `#if DEBUG` builds (`enableAds = false`)
- The current branch `swift-ui` is for incremental SwiftUI migration
