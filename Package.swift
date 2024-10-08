// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-macros",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "Macros",
            targets: ["Macros"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "MacrosImplementation",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            plugins: [
//                .plugin(name: "SwiftLint", package: "BuildTools"),
//                .plugin(name: "SwiftFormat", package: "BuildTools")
            ]
        ),
        .target(
            name: "Macros",
            dependencies: ["MacrosImplementation"],
            plugins: [
//                .plugin(name: "SwiftLint", package: "BuildTools"),
//                .plugin(name: "SwiftFormat", package: "BuildTools")
            ]
        ),
        .testTarget(
            name: "MacrosTests",
            dependencies: [
                "MacrosImplementation",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            plugins: [
//                .plugin(name: "SwiftLint", package: "BuildTools"),
//                .plugin(name: "SwiftFormat", package: "BuildTools")
            ]
        ),
    ]
)
