import ProjectDescription

let projectName = "WhoCallMe"
fileprivate let projects: [Path] = ["App"]
    .map{ "Projects/\($0)" }

let workspace = Workspace(name: projectName,
                          projects: projects)
