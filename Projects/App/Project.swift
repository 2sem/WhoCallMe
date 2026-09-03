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
                requirement: .upToNextMajor(from: "1.3.8")),
    ],
    targets: [
        .target(
            name: "App",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.credif.who",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
            with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "GADApplicationIdentifier": "ca-app-pub-9684378399371172~4206633246",
                "GADUnitIdentifiers" : [
                    "FullAd" : "ca-app-pub-9684378399371172/4108901647",
                    "HomeBanner" : "ca-app-pub-9684378399371172/2132640843",
                    "SettingsBanner" : "ca-app-pub-9684378399371172/7926699548"
                ],
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
            scripts: [
                .post(
                    script: """
                    # Firebase moved from a target-level registry package (PR pre-#64) to an SCM URL
                    # dependency in Tuist/Package.swift (PR #64). Tuist's SwiftPM integration now
                    # resolves it into <repo-root>/Tuist/.build/checkouts/ instead of the app's
                    # DerivedData SourcePackages/checkouts/. $SRCROOT for the App target is
                    # <repo-root>/Projects/App (Tuist generates every other Firebase path the same
                    # "$(SRCROOT)/../../Tuist/.build/checkouts/firebase-ios-sdk" way), so repo root
                    # is "$SRCROOT/../..". Keep the SourcePackages candidates first for backward
                    # safety and for any future registry-style packages.
                    SOURCE_PACKAGES_ROOT="${SOURCE_PACKAGES_DIR_PATH:-${BUILD_DIR%/Build/*}/SourcePackages}"
                    TUIST_BUILD_ROOT="$SRCROOT/../../Tuist/.build"
                    CRASHLYTICS_RUN_SCRIPT=""

                    for candidate in \
                      "$SOURCE_PACKAGES_ROOT/checkouts/firebase-ios-sdk/Crashlytics/run" \
                      "$SOURCE_PACKAGES_ROOT/registry/downloads/firebase/firebase-ios-sdk/Crashlytics/run" \
                      "$SOURCE_PACKAGES_ROOT"/registry/downloads/firebase/firebase-ios-sdk/*/Crashlytics/run \
                      "$TUIST_BUILD_ROOT/checkouts/firebase-ios-sdk/Crashlytics/run" \
                      "$TUIST_BUILD_ROOT/index-build/checkouts/firebase-ios-sdk/Crashlytics/run" \
                      "$TUIST_BUILD_ROOT"/*/checkouts/firebase-ios-sdk/Crashlytics/run
                    do
                      if [ -f "$candidate" ]; then
                        CRASHLYTICS_RUN_SCRIPT="$candidate"
                        break
                      fi
                    done

                    if [ -z "$CRASHLYTICS_RUN_SCRIPT" ]; then
                      echo "error: Firebase Crashlytics run script not found. Searched under:"
                      echo "  $SOURCE_PACKAGES_ROOT"
                      echo "  $TUIST_BUILD_ROOT (resolved: $(cd "$TUIST_BUILD_ROOT" 2>/dev/null && pwd || echo missing))"
                      exit 1
                    fi

                    echo "note: Firebase Crashlytics run script: $CRASHLYTICS_RUN_SCRIPT"
                    "$CRASHLYTICS_RUN_SCRIPT"
                    """,
                    name: "Upload dSYM for Crashlytics",
                    inputPaths: [
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
                        "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
                        "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
                    ],
                    runForInstallBuildsOnly: true
                )
            ],
            dependencies: [
                            .Projects.ThirdParty,
                            .package(product: "GADManager", type: .runtime),
                            // Firebase — declared in Tuist/Package.swift (SCM URL), wired in via
                            // .Externals.Firebase.*. SwiftPM resolves the rest transitively
                            // (FirebaseCore, GoogleAppMeasurement*, GUL*, nanopb, FirebaseInstallations).
                            .Externals.Firebase.crashlytics,
                            .Externals.Firebase.analytics
            ],
            settings: .settings(configurations: [
                .debug(name: "Debug", xcconfig: "Configs/app.debug.xcconfig"),
                .release(name: "Release", xcconfig: "Configs/app.release.xcconfig")
            ])
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.credif.who.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")],
            settings: .settings(base: ["CODE_SIGNING_ALLOWED": "NO"])
        ),
    ]
)
