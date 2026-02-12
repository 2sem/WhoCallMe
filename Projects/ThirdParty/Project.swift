import ProjectDescription

let project = Project(
    name: "ThirdParty",
    packages: [.remote(url: "https://github.com/2sem/StringLogger",
                       requirement: .upToNextMajor(from: "0.7.0")),
               .remote(url: "https://github.com/kakao/kakao-ios-sdk",
                       requirement: .upToNextMajor(from: "2.22.2")),
               .remote(url: "https://github.com/2sem/LSExtensions",
                       requirement: .exact("0.1.22")),
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.credif.who.thirdparty",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [.package(product: "StringLogger", type: .runtime),
                           .package(product: "KakaoSDK", type: .runtime),
                           .package(product: "LSExtensions", type: .runtime),
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
