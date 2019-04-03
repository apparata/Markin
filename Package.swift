// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Markin",
    products: [
        .library(name: "Markin", targets: ["Markin"]),
    ],
    targets: [
        .target(name: "Markin", dependencies: []),
        .testTarget(name: "MarkinTests", dependencies: ["Markin"]),
    ]
)
