import ProjectDescription

let projectName = "WhoCallMe"
fileprivate let projects: [Path] = ["App", "ThirdParty", "DynamicThirdParty"]
    .map{ "Projects/\($0)" }

let workspace = Workspace(name: projectName,
                          projects: projects)
