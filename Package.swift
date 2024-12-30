// swift-tools-version:6.0
import PackageDescription

let package:Package = .init(name: "swift-bson",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "BSON", targets: ["BSON"]),
        .library(name: "BSONLegacy", targets: ["BSONLegacy"]),
        .library(name: "BSONReflection", targets: ["BSONReflection"]),
        .library(name: "BSONABI", targets: ["BSONABI"]),

        .library(name: "BSON_ISO", targets: ["BSON_ISO"]),
        .library(name: "BSON_UUID", targets: ["BSON_UUID"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-grammar",
            from: "0.4.1"),

        .package(url: "https://github.com/tayloraswift/swift-hash",
            from: "0.7.0"),
        .package(url: "https://github.com/tayloraswift/swift-unixtime",
            from: "0.2.0"),
    ],
    targets: [
        .target(name: "BSON",
            dependencies: [
                .target(name: "BSONArrays"),
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
            ]),

        .target(name: "BSONABI",
            dependencies: [
                .product(name: "UnixTime", package: "swift-unixtime"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONArrays",
            dependencies: [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
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

        .target(name: "BSON_ISO",
            dependencies: [
                .target(name: "BSON"),
                .product(name: "ISO", package: "swift-unixtime"),
            ]),

        .target(name: "BSON_UUID",
            dependencies: [
                .target(name: "BSON"),
                .product(name: "UUID", package: "swift-hash"),
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
