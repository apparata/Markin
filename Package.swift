// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Markin",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
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
