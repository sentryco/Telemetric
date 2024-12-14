// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Telemetric",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Telemetric",
            targets: ["Telemetric"]),
    ],
    targets: [
        .target(
            name: "Telemetric"),
        .testTarget(
            name: "TelemetricTests",
            dependencies: ["Telemetric"]
        ),
    ]
)
