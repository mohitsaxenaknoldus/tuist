import ProjectDescription

let config = Config(
    cache: .cache(
        profiles: [
            .profile(name: "Simulator", configuration: "debug", device: "iPhone 11 Pro", os: "15.0")
        ],
        path: .relativeToRoot("TuistCache")
    ),
    generationOptions: [.disableAutogeneratedSchemes]
)
