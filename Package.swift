// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Markin",
    platforms: [
        .macOS(.v12), .iOS(.v16), .tvOS(.v16), .visionOS(.v1)
    ],
    products: [
        .library(name: "Markin", targets: ["Markin"]),
    ],
    targets: [
        .target(name: "Markin",
                dependencies: [],
                swiftSettings: [
                    .define("DEBUG", .when(configuration: .debug)),
                    .define("RELEASE", .when(configuration: .release)),
                    .define("SWIFT_PACKAGE")
                ]),
        .testTarget(name: "MarkinTests", dependencies: ["Markin"]),
    ]
)
