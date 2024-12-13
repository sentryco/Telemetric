// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Telemetric",
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
