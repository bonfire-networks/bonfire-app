// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "Bonfire",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(name: "ElixirKit", path: "../../../deps/elixirkit/elixirkit/elixirkit_swift")
    ],
    targets: [
        .executableTarget(
            name: "Bonfire",
            dependencies: ["ElixirKit"]
        )
    ]
)
