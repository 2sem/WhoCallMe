import ProjectDescription

let project = Project(
    name: "DynamicThirdParty",
    packages: [.package(id: "firebase.firebase-ios-sdk", from: "12.15.0"),
               .package(id: "google.googleappmeasurement", from: "12.15.0"),
    ],
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.credif.who.thirdparty.dynamic",
            dependencies: [.package(product: "FirebaseCrashlytics"),
                            .package(product: "FirebaseAnalytics"),
                            .package(product: "GoogleAppMeasurement"),
                            .package(product: "GoogleAppMeasurementCore"),
                            .package(product: "GoogleAppMeasurementIdentitySupport"),
                            .package(product: "FirebaseInstallations"),
                            .package(product: "GULAppDelegateSwizzler"),
                            .package(product: "GULMethodSwizzler"),
                            .package(product: "GULNSData"),
                            .package(product: "GULNetwork"),
                            .package(product: "nanopb"),
                            .package(product: "FirebaseMessaging"),
                            .package(product: "FirebaseRemoteConfig")
            ],
            settings: .settings(base: ["DEFINES_MODULE": "NO"])
        ),
    ]
)
