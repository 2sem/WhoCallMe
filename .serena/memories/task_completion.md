# Task Completion Checklist – WhoCallMe

## After modifying Swift source files
1. If `Project.swift` was changed (new target/dependency/resource): run `mise x -- tuist generate`
2. Build to confirm no compile errors: `xcodebuild -workspace WhoCallMe.xcworkspace -scheme App -configuration Debug build`
3. Run unit tests: `xcodebuild -workspace WhoCallMe.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 16' test`

## After modifying Tuist manifests (Project.swift / Workspace.swift / Tuist.swift)
1. `mise x -- tuist install` (if dependencies changed)
2. `mise x -- tuist generate`
3. Verify generated project opens and builds

## After adding a new SPM package
1. Add to the appropriate `Project.swift` (`packages:` and `dependencies:`)
2. `mise x -- tuist install`
3. `mise x -- tuist generate`

## Before committing
- Confirm `.xcodeproj` and `Derived/` changes are expected (generated, not hand-edited)
- The `Derived/` folder is committed (contains generated Swift files for assets/strings/plists)

## No linter/formatter configured
- No SwiftLint or SwiftFormat detected in the project
- Follow existing code style conventions manually
