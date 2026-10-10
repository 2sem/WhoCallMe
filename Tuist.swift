//
//  Tuist.swift
//  WhoCallMeManifests
//
//  Created by 영준 이 on 3/9/25.
//

import ProjectDescription

let tuist = Tuist(
    fullHandle: "gamehelper/whocallme",
    project: .tuist(
        compatibleXcodeVersions: [.upToNextMajor("26.0"), .upToNextMajor("27.0")],
        generationOptions: .options(
            registryEnabled: true
        ),
        installOptions: .options(
            passthroughSwiftPackageManagerArguments: ["--replace-scm-with-registry"]
        )
    )
)
