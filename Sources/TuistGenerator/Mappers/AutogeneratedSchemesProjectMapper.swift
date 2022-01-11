import Foundation
import TSCBasic
import TuistCore
import TuistGraph

/// A project mapper that auto-generates schemes for each of the targets of the `Project`
/// if the user hasn't already defined schemes for those.
public final class AutogeneratedSchemesProjectMapper: ProjectMapping {
    let enableCodeCoverage: Bool

    // MARK: - Init

    public init(enableCodeCoverage: Bool) {
        self.enableCodeCoverage = enableCodeCoverage
    }

    // MARK: - ProjectMapping

    public func map(project: Project) throws -> (Project, [SideEffectDescriptor]) {
        let userDefinedSchemes = project.schemes
        let userDefinedSchemeNames = Set(project.schemes.map(\.name))

        var buildTargets: Set<Target> = []
        var testTargets: Set<Target> = []
        var runTargets: Set<Target> = []
        project.targets.forEach { target in
            if target.product.runnable {
                runTargets.insert(target)
            } else if target.product.testsBundle {
                testTargets.insert(target)
            } else {
                buildTargets.insert(target)
            }
        }

        let autogeneratedSchemes: [Scheme]
        switch project.options.automaticSchemesGrouping {
        case .singleScheme:
            autogeneratedSchemes = [
                createDefaultScheme(
                    name: project.name,
                    projectPath: project.path,
                    buildTargets: buildTargets.map { .init(projectPath: project.path, name: $0.name) },
                    testTargets: testTargets.map { .init(projectPath: project.path, name: $0.name) },
                    runTarget: runTargets.count == 1 ? runTargets.first! : nil,
                    buildConfiguration: project.defaultDebugBuildConfigurationName
                ),
            ]
        case .byName:
            // TODO: add grouping logic
            autogeneratedSchemes = []
        case .notGrouped:
            let buildTargetsSchemes = buildTargets.map {
                createDefaultScheme(
                    name: project.name,
                    projectPath: project.path,
                    buildTargets: [.init(projectPath: project.path, name: $0.name)],
                    buildConfiguration: project.defaultDebugBuildConfigurationName
                )
            }
            let testTargetsSchemes = testTargets.map {
                createDefaultScheme(
                    name: project.name,
                    projectPath: project.path,
                    buildTargets: [.init(projectPath: project.path, name: $0.name)],
                    testTargets: [.init(projectPath: project.path, name: $0.name)],
                    buildConfiguration: project.defaultDebugBuildConfigurationName
                )
            }
            let runTargetsSchemes = runTargets.map {
                createDefaultScheme(
                    name: project.name,
                    projectPath: project.path,
                    buildTargets: [.init(projectPath: project.path, name: $0.name)],
                    runTarget: $0,
                    buildConfiguration: project.defaultDebugBuildConfigurationName
                )
            }
            autogeneratedSchemes = buildTargetsSchemes + testTargetsSchemes + runTargetsSchemes
        }

        let filteredAutogeneratedSchemes = autogeneratedSchemes.filter { !userDefinedSchemeNames.contains($0.name) }
        return (project.with(schemes: userDefinedSchemes + filteredAutogeneratedSchemes), [])
    }

    // MARK: - Private

    private func createDefaultScheme(
        name: String,
        projectPath: AbsolutePath,
        buildTargets: [TargetReference],
        testTargets: [TargetReference] = [],
        runTarget: Target? = nil,
        buildConfiguration: String
    ) -> Scheme {
        let runAction: RunAction?
        if let runTarget = runTarget {
            runAction = .init(
                configurationName: buildConfiguration,
                attachDebugger: true,
                preActions: [],
                postActions: [],
                executable: .init(projectPath: projectPath, name: runTarget.name),
                filePath: nil,
                arguments: defaultArguments(for: runTarget),
                diagnosticsOptions: [.mainThreadChecker]
            )
        } else {
            runAction = nil
        }

        return Scheme(
            name: name,
            shared: true,
            buildAction: BuildAction(targets: buildTargets),
            testAction: TestAction(
                targets: testTargets.map { TestableTarget(target: $0) },
                arguments: nil,
                configurationName: buildConfiguration,
                attachDebugger: true,
                coverage: enableCodeCoverage,
                codeCoverageTargets: [],
                expandVariableFromTarget: nil,
                preActions: [],
                postActions: [],
                diagnosticsOptions: [.mainThreadChecker]
            ),
            runAction: runAction
        )
    }

    private func defaultArguments(for target: Target) -> Arguments? {
        if target.environment.isEmpty, target.launchArguments.isEmpty {
            return nil
        }
        return Arguments(environment: target.environment, launchArguments: target.launchArguments)
    }
}
