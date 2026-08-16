// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "kanatan",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "KanatanCore",
            targets: ["KanatanCore"]
        ),
        .executable(
            name: "kanatan",
            targets: ["KanatanApp"]
        )
    ],
    targets: [
        .target(
            name: "KanatanCore"
        ),
        .executableTarget(
            name: "KanatanApp",
            dependencies: ["KanatanCore"]
        ),
        .testTarget(
            name: "KanatanCoreTests",
            dependencies: ["KanatanCore"]
        )
    ]
)
