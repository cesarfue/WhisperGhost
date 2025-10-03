// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "WhisperGhost",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WhisperGhost", targets: ["WhisperGhost"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "WhisperGhost",
            dependencies: [],
            path: "Sources/WhisperGhost"
        )
    ]
)
