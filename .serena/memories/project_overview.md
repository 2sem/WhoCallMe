# WhoCallMe – Project Overview

## Purpose
iOS app that enriches incoming call screens by embedding contact info (org, dept, job title, thumbnail) as a generated image in the contact's photo field. Also adds Korean cho-seong (초성) search indexes into contact notes for better searchability.

## Tech Stack
- **Language**: Swift 5
- **UI**: SwiftUI (migration from UIKit complete, merged to main)
- **Concurrency**: async/await, actors
- **Persistence**: SwiftData (ContactBackup), UserDefaults (LSDefaults)
- **Backend/Analytics**: Firebase (Crashlytics, Analytics, Messaging, RemoteConfig)
- **Ads**: Google Mobile Ads via GADManager (interstitial + banner)
- **Project Generation**: Tuist 4.x (via mise)
- **CI/CD**: GitHub Actions (macos-26, Xcode 26.1.1) + Fastlane
- **Bundle ID**: com.credif.who
- **Deployment target**: iOS 18.0, iPhone only

## Module Structure (Tuist Workspace)
- `Projects/App` – Main app target (SwiftUI, iPhone only)
- `Projects/ThirdParty` – Static framework: LSExtensions, LSCircleProgressView, StringLogger
- `Projects/DynamicThirdParty` – Dynamic framework: Firebase suite

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
