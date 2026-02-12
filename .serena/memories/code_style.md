# Code Style & Conventions – WhoCallMe

## General
- Swift 5, UIKit + Storyboard (not SwiftUI — migration in progress on `swift-ui` branch)
- Semicolons at end of statements (legacy style from original Obj-C era code)
- `guard` for early returns; `if let` / `guard let` for optionals
- Force unwrap (`!`) used in places where nil is truly impossible (e.g., storyboard outlets)

## Naming
- Classes/types: UpperCamelCase (e.g., `WCMDataController`, `LSDefaults`)
- Methods/vars: lowerCamelCase
- IBOutlets: prefixed with type hint (e.g., `btn_Generate`, `lb_status`, `constraint_bottomBanner_Bottom`)
- Enum cases: lowerCamelCase (e.g., `.convertAll`, `.ready`)
- Static constants in nested structs: UpperCamelCase (e.g., `Cell_Ids.OptionPhotoCell`)

## Reactive (RxSwift)
- UI state driven by `BehaviorSubject`; bound to UI with `.asDriver(onErrorJustReturn:).drive()`
- Long operations use `ConcurrentDispatchQueueScheduler(qos: .background)` with `observeOn(MainScheduler.instance)` for UI updates
- Each major action (generate, restore, clear) has its own `DisposeBag` that gets replaced to cancel in-flight work

## Architecture Pattern
- UIKit + Storyboard + RxSwift reactive bindings (no MVVM formally, logic lives in ViewController)
- Singletons for shared services: `WCMDataController.shared`, `RxContactController.shared`, `AppDelegate.sharedGADManager`
- `LSDefaults` is a pure-static class wrapping UserDefaults — no instance needed

## Tuist Project Manifests
- Add new source files by placing them in `Sources/**` — Tuist picks them up automatically via glob
- Add new dependencies by editing the relevant `Project.swift` and running `tuist install && tuist generate`
- Helper extensions for Tuist in `Tuist/ProjectDescriptionHelpers/`

## Localisation
- Strings in `Resources/Strings/Base.lproj/Localizable.strings` (English) and `ko.lproj/` (Korean)
- Use `.localized()` extension on String for lookups
- Storyboard localised via `Storyboards/ko.lproj/Main.strings`

## Debug vs Release
- `#if DEBUG` disables ads (`enableAds = false`) and sets shorter ad intervals
- `OTHER_SWIFT_FLAGS = -D DEBUG` in debug xcconfig

## Ads (disabled in DEBUG)
- Interstitial: `GADManager<GADUnitName>` singleton on `AppDelegate.sharedGADManager`
- Reward: `GADRewardManager` on `AppDelegate.rewardAd`
- Banner: `GADBannerView` outlet on `MainViewController`
