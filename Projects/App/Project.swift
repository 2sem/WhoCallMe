import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    packages: [
        .remote(
            url: "https://github.com/2sem/LSExtensions",
            requirement: .exact("0.1.22")),
        .remote(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
                requirement: .upToNextMajor(from: "11.5.0"))],
    settings: .settings(configurations: [
        .debug(
            name: "Debug",
            xcconfig: "Configs/app.debug.xcconfig"),
        .release(
            name: "Release",
            xcconfig: "Configs/app.release.xcconfig")
    ]),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.credif.who",
            deploymentTargets: .iOS("13.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: .relativeToCurrentFile("Sources/App.entitlements")),
            dependencies: [.package(product: "LSExtensions", type: .runtime),
                           .Projects.ThirdParty,
                           .package(product: "GoogleMobileAds", type: .runtime),]
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.credif.who.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
    ]
)
