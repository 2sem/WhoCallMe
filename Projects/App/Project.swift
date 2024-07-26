import ProjectDescription
import ProjectDescriptionHelpers

let skAdNetworks: [Plist.Value] = ["cstr6suwn9",
                                   "4fzdc2evr5",
                                   "2fnua5tdw4",
                                   "ydx93a7ass",
                                   "5a6flpkh64",
                                   "p78axxw29g",
                                   "v72qych5uu",
                                   "c6k4g5qg8m",
                                   "s39g8k73mm",
                                   "3qy4746246",
                                   "3sh42y64q3",
                                   "f38h382jlk",
                                   "hs6bdukanm",
                                   "prcb7njmu6",
                                   "wzmmz9fp6w",
                                   "yclnxrl5pm",
                                   "4468km3ulz",
                                   "t38b2kh725",
                                   "7ug5zh24hu",
                                   "9rd848q2bz",
                                   "n6fk4nfna4",
                                   "kbd757ywx3",
                                   "9t245vhmpl",
                                   "2u9pt9hc89",
                                   "8s468mfl3y",
                                   "av6w8kgt66",
                                   "klf5c3l5u5",
                                   "ppxm28t8ap",
                                   "424m5254lk",
                                   "uw77j35x4d",
                                   "e5fvkxwrpn",
                                   "zq492l623r",
                                   "3qcr597p9d"
    ]
    .map{ .dictionary(["SKAdNetworkIdentifier" : "\($0).skadnetwork"]) }

let project = Project(
    name: "App",
    packages: [
        .remote(url: "https://github.com/2sem/GADManager",
                requirement: .upToNextMajor(from: "1.3.3")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk",
               requirement: .upToNextMajor(from: "10.4.0")),
        
    ],
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
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.credif.who",
            deploymentTargets: .iOS("13.0"),
        infoPlist: .extendingDefault(
            with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIMainStoryboardFile": "Main",
                "GADApplicationIdentifier": "ca-app-pub-9684378399371172~4206633246",
                "GADUnitIdentifiers" : ["FullAd" : "ca-app-pub-9684378399371172/4108901647"],
                "GoogleADUnitID": ["FullAd" : "ca-app-pub-9684378399371172/4108901647",
                                   "RewardAd" : "ca-app-pub-9684378399371172/5771706946",
                                   "TopBanner" : ""],
                "Itunes App Id": "395429781",
                "NSContactsUsageDescription": "This app needs access contacts to convert",
                "NSUserTrackingUsageDescription": "Your data will be used to deliver personalized ads to you",
                "SKAdNetworkItems": .array(skAdNetworks),
                "CFBundleShortVersionString": "${MARKETING_VERSION}",
                "CFBundleDisplayName": "WhoCallMe"
            ]
        ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: .relativeToCurrentFile("Sources/App.entitlements")),
            dependencies: [
                            
                           .Projects.ThirdParty,
                           .package(product: "FirebaseCrashlytics", type: .runtime),
                           .package(product: "FirebaseAnalytics", type: .runtime),
                           .package(product: "GADManager", type: .runtime)
            ]
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
