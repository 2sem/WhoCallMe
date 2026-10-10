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
        .package(url: "https://github.com/2sem/GADManager",
                 .upToNextMajor(from: "1.3.8")),
        .package(url: "https://github.com/2sem/StringLogger",
                 .upToNextMajor(from: "0.7.0")),
        .package(url: "https://github.com/2sem/LSExtensions",
                 exact: "0.1.23"),
        .package(id: "firebase.firebase-ios-sdk",
                 .upToNextMinor(from: "12.18.0")),
    ]
)
