//
//  String+.swift
//  Packages
//
//  Created by 영준 이 on 6/2/24.
//

import ProjectDescription

public extension Path {
    static func projects(_ path: String) -> Path { .relativeToRoot("Projects/\(path)") }
}
