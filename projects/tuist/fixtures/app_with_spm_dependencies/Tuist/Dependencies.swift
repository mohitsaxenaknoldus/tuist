import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .package(url: "https://github.com/danielgindi/Charts", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/adjust/ios_sdk/", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMajor(from: "12.1.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMajor(from: "6.0.2")),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMinor(from: "0.22.0")),
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/realm/realm-cocoa.git", .upToNextMajor(from: "10.21.1")),
    ],
    platforms: [.iOS]
)
