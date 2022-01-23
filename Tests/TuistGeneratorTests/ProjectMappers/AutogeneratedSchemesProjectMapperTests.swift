// TODO: add tests

// import Foundation
// import TSCBasic
// import TuistCore
// import TuistGraph
// import TuistGraphTesting
// import XCTest
//
// @testable import TuistGenerator
// @testable import TuistSupport
// @testable import TuistSupportTesting
//
// final class AutogeneratedSchemesProjectMapperTests: TuistUnitTestCase {
//    var subject: AutogeneratedSchemesProjectMapper!
//
//    override func setUp() {
//        super.setUp()
//        subject = AutogeneratedSchemesProjectMapper()
//    }
//
//    override func tearDown() {
//        subject = nil
//        super.tearDown()
//    }
//
//    func test_map() throws {
//        // Given
//        let targetB = Target.test(name: "B")
//        let targetBTests = Target.test(
//            name: "BTests",
//            product: .unitTests,
//            dependencies: [
//                .target(name: "B"),
//                .target(name: "A"),
//            ]
//        )
//        let targetBUITests = Target.test(
//            name: "BUITests",
//            product: .uiTests,
//            dependencies: [.target(name: "B")]
//        )
//        let targetBIntegrationTests = Target.test(
//            name: "BIntegrationTests",
//            product: .unitTests,
//            dependencies: [.target(name: "B")]
//        )
//        let targetBSnapshotTests = Target.test(
//            name: "BSnapshotTests",
//            product: .unitTests,
//            dependencies: [
//                .target(name: "B"),
//                .target(name: "A"),
//            ]
//        )
//        let targetA = Target.test(
//            name: "A",
//            dependencies: [
//                .target(name: "B"),
//            ]
//        )
//        let targetATests = Target.test(
//            name: "ATests",
//            product: .unitTests,
//            dependencies: [.target(name: "A")]
//        )
//        let projectPath = try temporaryPath()
//        let project = Project.test(
//            path: projectPath,
//            targets: [
//                targetA,
//                targetATests,
//                targetB,
//                targetBTests,
//                targetBUITests,
//                targetBIntegrationTests,
//                targetBSnapshotTests,
//            ]
//        )
//
//        // When
//        let (got, sideEffects) = try subject.map(project: project)
//
//        // Then
//        XCTAssertEmpty(sideEffects)
//
//        let expected = [
//            makeScheme(
//                target: targetA,
//                projectPath: projectPath,
//                testTargetNames: ["ATests"]
//            ),
//            makeScheme(
//                target: targetATests,
//                projectPath: projectPath,
//                testTargetNames: ["ATests"]
//            ),
//            makeScheme(
//                target: targetB,
//                projectPath: projectPath,
//                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"]
//            ),
//            makeScheme(
//                target: targetBTests,
//                projectPath: projectPath,
//                testTargetNames: ["BTests"]
//            ),
//            makeScheme(
//                target: targetBUITests,
//                projectPath: projectPath,
//                testTargetNames: ["BUITests"]
//            ),
//            makeScheme(
//                target: targetBIntegrationTests,
//                projectPath: projectPath,
//                testTargetNames: ["BIntegrationTests"]
//            ),
//            makeScheme(
//                target: targetBSnapshotTests,
//                projectPath: projectPath,
//                testTargetNames: ["BSnapshotTests"]
//            ),
//        ]
//
//        XCTAssertEqual(
//            got.schemes,
//            expected
//        )
//    }
//
//    func test_map_doesnt_override_user_schemes() throws {
//        // Given
//        let targetA = Target.test(name: "A")
//        let aScheme = Scheme.test(
//            name: "A",
//            shared: true,
//            buildAction: nil,
//            testAction: nil,
//            runAction: nil,
//            archiveAction: nil,
//            profileAction: nil,
//            analyzeAction: nil
//        )
//        let project = Project.test(
//            targets: [targetA],
//            schemes: [aScheme]
//        )
//
//        // When
//        let (got, sideEffects) = try subject.map(project: project)
//
//        // Then
//        XCTAssertEmpty(sideEffects)
//        XCTAssertEqual(got.schemes.count, 1)
//
//        // Then: A
//        let gotAScheme = got.schemes.first!
//        XCTAssertNil(gotAScheme.buildAction)
//    }
//
//    func test_map_appExtensions() throws {
//        // Given
//        let path = AbsolutePath("/test")
//        let app = Target.test(
//            name: "App",
//            product: .app,
//            dependencies: [
//                .target(name: "AppExtension"),
//                .target(name: "MessageExtension"),
//            ]
//        )
//        let appExtension = Target.test(name: "AppExtension", product: .appExtension)
//        let messageExtension = Target.test(name: "MessageExtension", product: .messagesExtension)
//
//        let project = Project.test(path: path, targets: [app, appExtension, messageExtension])
//
//        // When
//        let (got, _) = try subject.map(project: project)
//
//        // Then
//        let buildActions = got.schemes.map(\.buildAction?.targets)
//        XCTAssertEqual(buildActions, [
//            [TargetReference(projectPath: path, name: "App")],
//            [TargetReference(projectPath: path, name: "AppExtension"), TargetReference(projectPath: path, name: "App")],
//            [TargetReference(projectPath: path, name: "MessageExtension"), TargetReference(projectPath: path, name: "App")],
//        ])
//
//        let runActions = got.schemes.map(\.runAction?.executable)
//        XCTAssertEqual(runActions, [
//            TargetReference(projectPath: path, name: "App"),
//            TargetReference(projectPath: path, name: "App"), // Extensions set their host app as the runnable target
//            TargetReference(projectPath: path, name: "App"), // Extensions set their host app as the runnable target
//        ])
//    }
//
//    func test_map_watch2() throws {
//        // Given
//        let path = AbsolutePath("/test")
//        let app = Target.test(
//            name: "App",
//            product: .app,
//            dependencies: [
//                .target(name: "WatchApp"),
//            ]
//        )
//        let watchApp = Target.test(name: "WatchApp", product: .watch2App, dependencies: [.target(name: "WatchExtension")])
//        let watchAppExtension = Target.test(name: "WatchExtension", product: .watch2Extension)
//
//        let project = Project.test(path: path, targets: [app, watchApp, watchAppExtension])
//
//        // When
//        let (got, _) = try subject.map(project: project)
//
//        // Then
//        let buildActions = got.schemes.map(\.buildAction?.targets)
//        XCTAssertEqual(buildActions, [
//            [TargetReference(projectPath: path, name: "App")],
//            [TargetReference(projectPath: path, name: "WatchApp")],
//            [TargetReference(projectPath: path, name: "WatchExtension")],
//        ])
//
//        let runActions = got.schemes.map(\.runAction?.executable)
//        XCTAssertEqual(runActions, [
//            TargetReference(projectPath: path, name: "App"),
//            TargetReference(projectPath: path, name: "WatchApp"),
//            TargetReference(projectPath: path, name: "WatchApp"),
//        ])
//    }
//
//    func test_map_enables_test_coverage_on_generated_schemes() throws {
//        // Given
//        subject = AutogeneratedSchemesProjectMapper()
//
//        let targetA = Target.test(
//            name: "A",
//            dependencies: [
//                .target(name: "B"),
//            ]
//        )
//        let targetATests = Target.test(
//            name: "ATests",
//            product: .unitTests,
//            dependencies: [.target(name: "A")]
//        )
//        let projectPath = try temporaryPath()
//        let project = Project.test(
//            path: projectPath,
//            options: [
//                .automaticSchemesOptions(
//                    .enabled(targetSchemesGrouping: .notGrouped, codeCoverageEnabled: true, testingOptions: [])
//                ),
//            ],
//            targets: [
//                targetA,
//                targetATests,
//            ]
//        )
//
//        // When
//        let (got, sideEffects) = try subject.map(project: project)
//
//        // Then
//        XCTAssertEmpty(sideEffects)
//        XCTAssertEqual(got.schemes.count, 2)
//
//        // Then: A Tests
//        let gotAScheme = got.schemes.first!
//        XCTAssertTrue(gotAScheme.testAction?.coverage != nil)
//        // Code coverage targets should be empty in order to gather coverage from all the targets
//        XCTAssertEqual(gotAScheme.testAction?.codeCoverageTargets.count, 0)
//    }
//
//    func test_map_onlySetsArgumentsWhenAvailableInTarget() throws {
//        // Given
//        subject = AutogeneratedSchemesProjectMapper()
//
//        let targetWithoutArguments = Target.test(
//            name: "ATargetWithoutArguments",
//            product: .framework,
//            environment: [:],
//            launchArguments: []
//        )
//        let targetWithArguments = Target.test(
//            name: "ATargetWithArguments",
//            product: .framework,
//            environment: [:],
//            launchArguments: [.init(name: "--run-argument", isEnabled: true)]
//        )
//        let targetWithEnvironment = Target.test(
//            name: "ATargetWithEnvironment",
//            product: .framework,
//            environment: ["A": "B"],
//            launchArguments: []
//        )
//        let projectPath = try temporaryPath()
//        let project = Project.test(
//            path: projectPath,
//            targets: [
//                targetWithoutArguments,
//                targetWithArguments,
//                targetWithEnvironment,
//            ]
//        )
//
//        // When
//        let (got, sideEffects) = try subject.map(project: project)
//
//        // Then
//        XCTAssertEmpty(sideEffects)
//        let runActions = got.schemes.compactMap(\.runAction)
//        let arguments = runActions.map(\.arguments)
//        XCTAssertEqual(arguments, [
//            nil,
//            Arguments(environment: [:], launchArguments: [.init(name: "--run-argument", isEnabled: true)]),
//            Arguments(environment: ["A": "B"], launchArguments: []),
//        ])
//    }
//
//    // MARK: - Helpers
//
//    private func makeScheme(
//        target: TuistGraph.Target,
//        projectPath: AbsolutePath,
//        testTargetNames: [String]
//    ) -> TuistGraph.Scheme {
//        Scheme(
//            name: target.name,
//            shared: true,
//            buildAction: BuildAction(
//                targets: [
//                    TargetReference(projectPath: projectPath, name: target.name),
//                ]
//            ),
//            testAction: TestAction.test(
//                targets: testTargetNames.map { TestableTarget(target: TargetReference(projectPath: projectPath, name: $0)) },
//                arguments: nil
//            ),
//            runAction: RunAction.test(
//                executable: TargetReference(projectPath: projectPath, name: target.name),
//                arguments: nil
//            )
//        )
//    }
// }
