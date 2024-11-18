// swift-tools-version:6.0
import PackageDescription

let package:Package = .init(name: "swift-bson",
    platforms: [.macOS(.v15), .iOS(.v17), .tvOS(.v17), .visionOS(.v1), .watchOS(.v10)],
    products: [
        .library(name: "BSON", targets: ["BSON"]),
        .library(name: "BSONLegacy", targets: ["BSONLegacy"]),
        .library(name: "BSONReflection", targets: ["BSONReflection"]),
        .library(name: "BSONABI", targets: ["BSONABI"]),

        .library(name: "BSON_OrderedCollections", targets: ["BSON_OrderedCollections"]),
        .library(name: "BSON_UUID", targets: ["BSON_UUID"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.4.1")),

        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.7.0")),
        .package(url: "https://github.com/tayloraswift/swift-unixtime", .upToNextMinor(
            from: "0.1.5")),
        .package(url: "https://github.com/apple/swift-collections.git",
            from: "1.1.4"),
    ],
    targets: [
        .target(name: "BSON",
            dependencies: [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONABI",
            dependencies: [
                .product(name: "UnixTime", package: "swift-unixtime"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONDecoding",
            dependencies: [
                .target(name: "BSONABI"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONEncoding",
            dependencies: [
                .target(name: "BSONABI"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONLegacy",
            dependencies: [
                .target(name: "BSON"),
            ]),

        .target(name: "BSONReflection",
            dependencies: [
                .target(name: "BSON"),
            ]),

        .target(name: "BSON_UUID",
            dependencies: [
                .target(name: "BSON"),
                .product(name: "UUID", package: "swift-hash"),
            ]),

        .target(name: "BSON_OrderedCollections",
            dependencies: [
                .target(name: "BSON"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),


        .testTarget(name: "BSONTests",
            dependencies: [
                .target(name: "BSONReflection"),
                .target(name: "BSON_UUID"),
            ]),

        .testTarget(name: "BSONDecodingTests",
            dependencies: [
                .target(name: "BSONDecoding"),
            ]),

        .testTarget(name: "BSONEncodingTests",
            dependencies: [
                .target(name: "BSON"),
                .target(name: "BSONEncoding"),
            ]),

        .testTarget(name: "BSONIntegrationTests",
            dependencies: [
                .target(name: "BSON"),
                .target(name: "BSONReflection"),
            ]),

        .testTarget(name: "BSONReflectionTests",
            dependencies: [
                .target(name: "BSONReflection"),
                .target(name: "BSONEncoding"),
            ]),
    ]
)

for target:PackageDescription.Target in package.targets
{
    {
        var settings:[PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        $0 = settings
    } (&target.swiftSettings)
}
