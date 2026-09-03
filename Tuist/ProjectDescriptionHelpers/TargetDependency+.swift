//
//  TargetDependency+.swift
//  Packages
//
//  Created by 영준 이 on 6/2/24.
//

import ProjectDescription

// MARK: Store Projects
public extension TargetDependency {
    class Projects {
        public static let ThirdParty: TargetDependency = .project(target: "ThirdParty",
                                               path: .projects("ThirdParty"))
    }
}

// MARK: Firebase external SPM products
// `firebase-ios-sdk` is declared as an external dependency in the root
// `Tuist/Package.swift` (SCM URL form), so its products are wired into targets
// with `.external(name:)`. Only the two top-level products are declared;
// SwiftPM pulls in the rest transitively (FirebaseCore, GoogleAppMeasurement*,
// GUL*, nanopb, FirebaseInstallations), and their modules stay importable.
public extension TargetDependency {
    enum Externals {
        public enum Firebase {
            public static let crashlytics: TargetDependency = .external(name: "FirebaseCrashlytics")
            public static let analytics: TargetDependency = .external(name: "FirebaseAnalytics")
        }
    }
}
