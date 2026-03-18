// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TextGrab",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "TextGrab",
            path: "Sources",
            linkerSettings: [
                .linkedFramework("Carbon")
            ]
        )
    ]
)
