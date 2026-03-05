// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LocaleChain",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "LocaleChain",
            targets: ["LocaleChain"]
        )
    ],
    targets: [
        .target(
            name: "LocaleChain",
            path: "Sources/LocaleChain"
        ),
        .testTarget(
            name: "LocaleChainTests",
            dependencies: ["LocaleChain"],
            path: "Tests/LocaleChainTests",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
