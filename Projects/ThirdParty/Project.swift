import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.credif.who.thirdparty",
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [.Externals.StringLogger,
                           .Externals.LSExtensions,
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
