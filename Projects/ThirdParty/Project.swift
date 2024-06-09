import ProjectDescription

let project = Project(
    name: "ThirdParty",
    packages: [.remote(url: "https://github.com/firebase/firebase-ios-sdk",
                       requirement: .upToNextMajor(from: "10.4.0")),
               .remote(url: "https://github.com/ReactiveX/RxSwift",
                       requirement: .upToNextMajor(from: "5.0.0")),
               .remote(url: "https://github.com/2sem/StringLogger", 
                       requirement: .upToNextMajor(from: "0.7.0")),
               .remote(url: "https://github.com/2sem/LSCircleProgressView", 
                       requirement: .upToNextMajor(from: "0.1.0")),
               .remote(url: "https://github.com/2sem/GADManager", requirement: .upToNextMajor(from: "1.3.2")),
               .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.22.2"))
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.credif.who.thirdparty",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [.package(product: "FirebaseCrashlytics", type: .runtime),
                           .package(product: "FirebaseAnalytics", type: .runtime),
                           .package(product: "RxSwift", type: .runtime),
                           .package(product: "RxCocoa", type: .runtime),
                           .package(product: "StringLogger", type: .runtime),
                           .package(product: "LSCircleProgressView", type: .runtime),
                           .package(product: "GADManager", type: .runtime),
                           .package(product: "KakaoSDK", type: .runtime)
            ]
        ),
        .target(
            name: "ThirdPartyTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.credif.who.thirdparty.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "ThirdParty")]
        ),
    ]
)
