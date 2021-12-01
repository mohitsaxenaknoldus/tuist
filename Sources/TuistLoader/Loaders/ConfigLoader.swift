import Foundation
import TSCBasic
import TuistCore
import TuistGraph
import TuistSupport

import struct ProjectDescription.Config

public protocol ConfigLoading {
    /// Loads the Tuist configuration by traversing the file system till the Config manifest is found,
    /// otherwise returns the default configuration.
    ///
    /// - Parameter path: Directory from which look up and load the Config.
    /// - Returns: Loaded Config object.
    /// - Throws: An error if the Config.swift can't be parsed.
    func loadConfig(path: AbsolutePath) throws -> TuistGraph.Config
}

public final class ConfigLoader: ConfigLoading {
    private let manifestLoader: ManifestLoading
    private let rootDirectoryLocator: RootDirectoryLocating
    private let fileHandler: FileHandling
    private var cachedConfigs: [AbsolutePath: TuistGraph.Config] = [:]

    public init(
        manifestLoader: ManifestLoading = ManifestLoader(),
        rootDirectoryLocator: RootDirectoryLocating = RootDirectoryLocator(),
        fileHandler: FileHandling = FileHandler.shared
    ) {
        self.manifestLoader = manifestLoader
        self.rootDirectoryLocator = rootDirectoryLocator
        self.fileHandler = fileHandler
    }

    public func loadConfig(path: AbsolutePath) throws -> TuistGraph.Config {
        if let cached = cachedConfigs[path] {
            return cached
        }

        guard let configPath = locateConfigPath(at: path) else {
            let config = TuistGraph.Config.default
            cachedConfigs[path] = config
            return config
        }

        let manifest = try manifestLoader.loadConfig(at: configPath.parentDirectory)
        let config = try TuistGraph.Config.from(manifest: manifest, at: configPath)
        cachedConfigs[path] = config
        return config
    }

    // MARK: - Helpers

    private func locateConfigPath(at path: AbsolutePath) -> AbsolutePath? {
        // If the Config.swift file exists in the root Tuist/ directory, we load it from there
        if let rootDirectoryPath = rootDirectoryLocator.locate(from: path) {
            let configPath =
                rootDirectoryPath
                .appending(
                    RelativePath(
                        "\(Constants.tuistDirectoryName)/\(Manifest.config.fileName(path))"
                    )
                )
            if fileHandler.exists(configPath) {
                return configPath
            }
        }

        // Otherwise we try to traverse up the directories to find it
        return fileHandler.locateDirectoryTraversingParents(
            from: path,
            path: Manifest.config.fileName(path)
        )
    }
}
