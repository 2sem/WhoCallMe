# WhoCallMe – Project Overview

## Purpose
iOS app that enriches incoming call screens by embedding contact info (org, department, job title, thumbnail) as a generated image in the contact's photo field. Also adds Korean cho-seong (초성) search indexes into contact notes for better searchability.

## Tech Stack
- **Language**: Swift 5
- **UI**: UIKit + Storyboard (Main.storyboard), iOS 13.0+, iPhone only
- **Reactive**: RxSwift 5.x / RxCocoa
- **Persistence**: Core Data (WhoCallMe.sqlite), UserDefaults (LSDefaults)
- **Backend/Analytics**: Firebase (Crashlytics, Analytics, Messaging, RemoteConfig)
- **Ads**: Google Mobile Ads via GADManager
- **Social**: KakaoSDK
- **Project Generation**: Tuist 4.38.2 (via mise)
- **CI/CD**: GitHub Actions + Fastlane
- **Bundle ID**: com.credif.who
- **Deployment target**: iOS 13.0, Xcode ≥ 16.0

## Module Structure (Tuist Workspace)
- `Projects/App` – Main app target (UIKit, iPhone only)
- `Projects/ThirdParty` – Static framework: RxSwift, KakaoSDK, LSExtensions, LSCircleProgressView, StringLogger
- `Projects/DynamicThirdParty` – Dynamic framework: Firebase suite (must be dynamic for Firebase to work)

## Key Architecture
- **MainViewController**: Central controller; uses `BehaviorSubject<Mode>` and `BehaviorSubject<State>` with RxSwift bindings to drive all UI
- **WCMDataController** (singleton): Core Data stack for `OriginalContract` entities (contact backups)
- **RxContactController** (singleton): Rx wrapper around CNContactStore
- **ContactTemplateViewController**: Renders incoming call template to UIImage for embedding in contact photo
- **LSDefaults**: Static UserDefaults wrapper for all feature flags/settings

## Contact Note Tag System
Cho-seong indexes are stored in contact notes wrapped with `<WhoCallMe>...</WhoCallMe>` tag. Restore operation strips this range.

## Current Branch
`swift-ui` — ongoing incremental SwiftUI migration
