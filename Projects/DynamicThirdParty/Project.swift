import ProjectDescription

let project = Project(
    name: "DynamicThirdParty",
    packages: [.package(id: "firebase.firebase-ios-sdk", from: "12.10.0"),
    ],
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.credif.who.thirdparty.dynamic",
            dependencies: [.package(product: "FirebaseCrashlytics", type: .runtime),
                           .package(product: "FirebaseAnalytics", type: .runtime),
                           .package(product: "FirebaseMessaging", type: .runtime),
                           .package(product: "FirebaseRemoteConfig", type: .runtime)
            ]
        ),
    ]
)
