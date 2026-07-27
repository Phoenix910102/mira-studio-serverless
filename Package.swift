// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MiraStudio",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "MiraStudio", targets: ["MiraStudio"])
    ],
    targets: [
        .executableTarget(
            name: "MiraStudio",
            linkerSettings: [.linkedFramework("Security")]
        )
    ]
)
