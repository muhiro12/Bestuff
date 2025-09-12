// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BestuffLibrary",
    products: [
        .library(
            name: "BestuffLibrary",
            targets: [
                "BestuffLibrary"
            ]
        )
    ],
    targets: [
        .target(
            name: "BestuffLibrary"
        ),
        .testTarget(
            name: "BestuffLibraryTests",
            dependencies: [
                "BestuffLibrary"
            ]
        )
    ]
)
