// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-macros",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "HasLoggerMacro",
            targets: ["HasLoggerMacro"]
        ),
        .library(
            name: "URLMacro",
            targets: ["URLMacro"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/chipp/BuildPlugins", branch: "main")
    ],
    targets: [
        .target(
            name: "HasLoggerMacro",
            dependencies: ["MacrosImplementation"],
            plugins: [
                .plugin(name: "SwiftLint", package: "BuildPlugins"),
                .plugin(name: "SwiftFormat", package: "BuildPlugins")
            ]
        ),
        .target(
            name: "URLMacro",
            dependencies: ["MacrosImplementation"],
            plugins: [
                .plugin(name: "SwiftLint", package: "BuildPlugins"),
                .plugin(name: "SwiftFormat", package: "BuildPlugins")
            ]
        ),

        .macro(
            name: "MacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            plugins: [
                .plugin(name: "SwiftLint", package: "BuildPlugins"),
                .plugin(name: "SwiftFormat", package: "BuildPlugins")
            ]
        ),
        .testTarget(
            name: "MacrosTests",
            dependencies: [
                "MacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            plugins: [
                .plugin(name: "SwiftLint", package: "BuildPlugins"),
                .plugin(name: "SwiftFormat", package: "BuildPlugins")
            ]
        ),
    ]
)
