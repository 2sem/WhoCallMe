# WhoCallMe – Project Overview

## Purpose
iOS app that enriches incoming call screens by embedding contact info (org, dept, job title, thumbnail) as a generated image in the contact's photo field. Also adds Korean cho-seong (초성) search indexes into contact notes for better searchability.

## Tech Stack
- **Language**: Swift 5
- **UI**: SwiftUI (migration from UIKit complete, merged to main)
- **Concurrency**: async/await, actors
- **Persistence**: SwiftData (ContactBackup), UserDefaults (LSDefaults)
- **Backend/Analytics**: Firebase 12.18.x — declared as an external SPM dependency in the root `Tuist/Package.swift` via **SCM URL** (`.package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMinor(from: "12.18.0"))`). URL not registry `id`: the root manifest is raw SwiftPM with no registry scope for `firebase`, so `.package(id:)` breaks `tuist install`. The App target declares only FirebaseCrashlytics + FirebaseAnalytics via `.Externals.Firebase.*` (`.external(name:)`); FirebaseCore (imported in AppDelegate.swift) and the rest (GoogleAppMeasurement*, GUL*, nanopb, FirebaseInstallations) resolve transitively. No explicit transitive product list and no `OTHER_LDFLAGS -framework` workaround — those were only for the removed DynamicThirdParty wrapper (verified: wiped-DerivedData clean build compiles `import FirebaseCore` and links with zero undefined symbols without them). Trade-off: open-source Firebase modules build from source (slower cold builds, Tuist binary cache mitigates); GoogleAppMeasurement/FirebaseAnalytics stay binary. `Tuist/Package.resolved` is committed.
- **Ads**: Google Mobile Ads via GADManager (interstitial + banner)
- **Project Generation**: Tuist 4.x (via mise)
- **CI/CD**: GitHub Actions (macos-26, Xcode 26.1.1) + Fastlane
- **Bundle ID**: com.credif.who
- **Deployment target**: iOS 18.0, iPhone only

## Module Structure (Tuist Workspace)
- `Projects/App` – Main app target (SwiftUI, iPhone only)
- `Projects/ThirdParty` – Static framework: LSExtensions, LSCircleProgressView, StringLogger
  (the former `Projects/DynamicThirdParty` Firebase wrapper framework was removed — Firebase is now an external SPM dependency of the App target, see Tech Stack)

## Key Architecture
- **ContactService** (@MainActor): orchestrates SwiftData + CNContact operations
- **ContactStore** (actor): async/await CNContactStore wrapper, fetchCount()
- **ContactConverter**: static cho-seong index generation/restore
- **ContactImageRenderer**: off-screen UIWindow rendering of ContactTemplateViewController
- **ContactTemplateViewController**: UIKit, still used via UIViewControllerRepresentable
- **LSDefaults**: static UserDefaults wrapper for all feature flags/settings
- **SwiftUIAdManager**: GADManager wrapper (interstitial + banner), ObservableObject
- **BannerAdView**: SwiftUI banner ad component with BannerAdCoordinator

## Ad Unit IDs (Project.swift GADUnitIdentifiers)
- FullAd: ca-app-pub-9684378399371172/4108901647
- HomeBanner: ca-app-pub-9684378399371172/2132640843
- SettingsBanner: ca-app-pub-9684378399371172/7926699548

## Contact Note Tag System
Cho-seong indexes stored in contact notes wrapped with `<WhoCallMe>...</WhoCallMe>` tag. Restore operation strips this range.
