// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // productTypes: ["Alamofire": .framework,]
    )
#endif

let package = Package(
    name: "WhoCallMe",
    dependencies: [
        .package(url: "https://github.com/2sem/GADManager",
                 from: "1.3.3"),
    ]
)
