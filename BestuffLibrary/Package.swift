// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BestuffLibrary",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "BestuffLibrary",
            targets: [
                "BestuffLibrary"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/muhiro12/SwiftAppUtilities", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .target(
            name: "BestuffLibrary",
            dependencies: [
                .product(name: "SwiftAppUtilities", package: "SwiftAppUtilities")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "BestuffLibraryTests",
            dependencies: [
                "BestuffLibrary"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
