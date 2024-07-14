//
//  TargetDependency+.swift
//  Packages
//
//  Created by 영준 이 on 6/2/24.
//

import ProjectDescription

// MARK: Store Projects
public extension TargetDependency {
    class Projects {
        public static let ThirdParty: TargetDependency = .project(target: "ThirdParty",
                                               path: .projects("ThirdParty"))
        public static let DynamicThirdParty: TargetDependency = .project(target: "DynamicThirdParty",
                                               path: .projects("DynamicThirdParty"))
    }
}
