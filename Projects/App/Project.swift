import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    packages: [
        .remote(
            url: "https://github.com/2sem/LSExtensions",
            requirement: .exact("0.1.22"))],
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
            deploymentTargets: .iOS("12.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: .relativeToCurrentFile("Sources/App.entitlements")),
            dependencies: [.package(product: "LSExtensions", type: .runtime),
                           .Projects.ThirdParty]
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
