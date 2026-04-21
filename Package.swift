// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "cmd-eisuu-kana",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CmdEisuuKanaCore",
            targets: ["CmdEisuuKanaCore"]
        ),
        .executable(
            name: "cmd-eisuu-kana",
            targets: ["CmdEisuuKanaApp"]
        )
    ],
    targets: [
        .target(
            name: "CmdEisuuKanaCore"
        ),
        .executableTarget(
            name: "CmdEisuuKanaApp",
            dependencies: ["CmdEisuuKanaCore"]
        ),
        .testTarget(
            name: "CmdEisuuKanaCoreTests",
            dependencies: ["CmdEisuuKanaCore"]
        )
    ]
)
