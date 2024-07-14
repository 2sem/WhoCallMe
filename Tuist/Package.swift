// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
//         productTypes: []
//            "GADManager": .framework,]
//            "FirebaseCrashlytics": .framework,
//            "FirebaseAnalytics": .framework,
//         ]
    )
#endif

let package = Package(
    name: "WhoCallMe",
    dependencies: [
//        .package(url: "https://github.com/2sem/GADManager",
//                 from: "1.3.3"),
//        .package(url: "https://github.com/firebase/firebase-ios-sdk",
//                from: "10.4.0"),
    ]
)
