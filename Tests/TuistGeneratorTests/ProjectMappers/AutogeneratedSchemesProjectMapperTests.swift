import Foundation
import TSCBasic
import TuistCore
import TuistGraph
import TuistGraphTesting
import XCTest

@testable import TuistGenerator
@testable import TuistSupport
@testable import TuistSupportTesting

final class AutogeneratedSchemesProjectMapperTests: TuistUnitTestCase {
    var subject: AutogeneratedSchemesProjectMapper!

    override func setUp() {
        super.setUp()
        subject = AutogeneratedSchemesProjectMapper()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_grouping_singleScheme() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .singleScheme,
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "Project",
                buildTargetNames: ["A", "ADemo", "ATests", "B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["ATests", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_grouping_byNameSuffix() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let allIntegrationTests = Target.test(
            name: "AllIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "A"), .target(name: "B")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
                allIntegrationTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A", "ADemo", "ATests"],
                testTargetNames: ["ATests"],
                runTargetName: "ADemo",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "AllIntegrationTests",
                buildTargetNames: ["AllIntegrationTests"],
                testTargetNames: ["AllIntegrationTests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_grouping_notGrouped() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .notGrouped,
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A"],
                testTargetNames: [],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "ADemo",
                buildTargetNames: ["ADemo"],
                testTargetNames: [],
                runTargetName: "ADemo",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "ATests",
                buildTargetNames: ["ATests"],
                testTargetNames: ["ATests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B"],
                testTargetNames: [],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "BIntegrationTests",
                buildTargetNames: ["BIntegrationTests"],
                testTargetNames: ["BIntegrationTests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "BSnapshotTests",
                buildTargetNames: ["BSnapshotTests"],
                testTargetNames: ["BSnapshotTests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "BTests",
                buildTargetNames: ["BTests"],
                testTargetNames: ["BTests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "BUITests",
                buildTargetNames: ["BUITests"],
                testTargetNames: ["BUITests"],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_map_doesnt_override_user_schemes() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ],
            schemes: [
                makeScheme(
                    name: "A",
                    buildTargetNames: ["A"],
                    testTargetNames: [],
                    runTargetName: nil,
                    projectPath: projectPath,
                    coverage: true,
                    parallelizable: false,
                    randomExecution: false,
                    arguments: nil
                ),
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A"],
                testTargetNames: [],
                runTargetName: nil,
                projectPath: projectPath,
                coverage: true,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_coverage_enabled() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: true,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A", "ADemo", "ATests"],
                testTargetNames: ["ATests"],
                runTargetName: "ADemo",
                projectPath: projectPath,
                coverage: true,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: true,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_testing_options() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: false,
                    testingOptions: [.parallelizable, .randomExecutionOrdering]
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A", "ADemo", "ATests"],
                testTargetNames: ["ATests"],
                runTargetName: "ADemo",
                projectPath: projectPath,
                coverage: false,
                parallelizable: true,
                randomExecution: true,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: true,
                randomExecution: true,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_run_arguments() throws {
        // Given
        let targetB = Target.test(
            name: "B",
            product: .app,
            launchArguments: [.init(name: "--run-argument", isEnabled: true)]
        )
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            environment: ["A": "B"],
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A", "ADemo", "ATests"],
                testTargetNames: ["ATests"],
                runTargetName: "ADemo",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: .init(environment: ["A": "B"], launchArguments: [])
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: .init(environment: [:], launchArguments: [.init(name: "--run-argument", isEnabled: true)])
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_disabled() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .framework,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetADemo = Target.test(
            name: "ADemo",
            product: .app,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.disabled),
            ],
            targets: [
                targetA,
                targetADemo,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)
        XCTAssertEqual(got.schemes, [])
    }

    func test_app_extension() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "A"),
            ]
        )
        let targetAAppExtension = Target.test(
            name: "AAppExtension",
            product: .appExtension,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetAMessagesExtension = Target.test(
            name: "AMessagesExtension",
            product: .messagesExtension,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetA = Target.test(
            name: "A",
            product: .app,
            dependencies: [
                .target(name: "B"),
                .target(name: "AAppExtension"),
                .target(name: "AMessagesExtension"),
            ]
        )
        let targetATests = Target.test(
            name: "ATests",
            product: .unitTests,
            dependencies: [.target(name: "A")]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetA,
                targetAAppExtension,
                targetAMessagesExtension,
                targetATests,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "A",
                buildTargetNames: ["A", "ATests"],
                testTargetNames: ["ATests"],
                runTargetName: "A",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "AAppExtension",
                buildTargetNames: ["A", "AAppExtension"],
                testTargetNames: [],
                runTargetName: "A",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "AMessagesExtension",
                buildTargetNames: ["A", "AMessagesExtension"],
                testTargetNames: [],
                runTargetName: "A",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    func test_watch_extension() throws {
        // Given
        let targetB = Target.test(name: "B", product: .app)
        let targetBTests = Target.test(
            name: "BTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "AWatchApp"),
            ]
        )
        let targetBUITests = Target.test(
            name: "BUITests",
            product: .uiTests,
            dependencies: [.target(name: "B")]
        )
        let targetBIntegrationTests = Target.test(
            name: "BIntegrationTests",
            product: .unitTests,
            dependencies: [.target(name: "B")]
        )
        let targetBSnapshotTests = Target.test(
            name: "BSnapshotTests",
            product: .unitTests,
            dependencies: [
                .target(name: "B"),
                .target(name: "AWatchApp"),
            ]
        )
        let targetAWatchExtension = Target.test(
            name: "AWatchExtension",
            product: .watch2Extension,
            dependencies: [
                .target(name: "B"),
            ]
        )
        let targetAWatchApp = Target.test(
            name: "AWatchApp",
            product: .watch2App,
            dependencies: [
                .target(name: "AWatchExtension"),
            ]
        )
        let projectPath = try temporaryPath()
        let project = Project.test(
            path: projectPath,
            options: [
                .automaticSchemesOptions(.enabled(
                    targetSchemesGrouping: .byNameSuffix(
                        build: [],
                        test: ["Tests", "UITests", "IntegrationTests", "SnapshotTests"],
                        run: ["Demo"]
                    ),
                    codeCoverageEnabled: false,
                    testingOptions: []
                )),
            ],
            targets: [
                targetAWatchApp,
                targetAWatchExtension,
                targetB,
                targetBTests,
                targetBUITests,
                targetBIntegrationTests,
                targetBSnapshotTests,
            ]
        )

        // When
        let (got, sideEffects) = try subject.map(project: project)

        // Then
        XCTAssertEmpty(sideEffects)

        let expected = [
            makeScheme(
                name: "AWatchApp",
                buildTargetNames: ["AWatchApp"],
                testTargetNames: [],
                runTargetName: "AWatchApp",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "AWatchExtension",
                buildTargetNames: ["AWatchApp", "AWatchExtension"],
                testTargetNames: [],
                runTargetName: "AWatchApp",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
            makeScheme(
                name: "B",
                buildTargetNames: ["B", "BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                testTargetNames: ["BIntegrationTests", "BSnapshotTests", "BTests", "BUITests"],
                runTargetName: "B",
                projectPath: projectPath,
                coverage: false,
                parallelizable: false,
                randomExecution: false,
                arguments: nil
            ),
        ]

        XCTAssertEqual(got.schemes, expected)
    }

    // MARK: - Helpers

    private func makeScheme(
        name: String,
        buildTargetNames: [String],
        testTargetNames: [String],
        runTargetName: String?,
        projectPath: AbsolutePath,
        coverage: Bool,
        parallelizable: Bool,
        randomExecution: Bool,
        arguments: Arguments?
    ) -> TuistGraph.Scheme {
        Scheme(
            name: name,
            shared: true,
            buildAction: buildTargetNames.isEmpty ? nil : BuildAction(
                targets: buildTargetNames.map { TargetReference(projectPath: projectPath, name: $0) }
            ),
            testAction: testTargetNames.isEmpty ? nil : TestAction.test(
                targets: testTargetNames.map {
                    TestableTarget(
                        target: TargetReference(projectPath: projectPath, name: $0),
                        parallelizable: parallelizable,
                        randomExecutionOrdering: randomExecution
                    )
                },
                arguments: nil,
                coverage: coverage
            ),
            runAction: runTargetName.map {
                RunAction.test(
                    executable: TargetReference(projectPath: projectPath, name: $0),
                    arguments: arguments
                )
            }
        )
    }
}
