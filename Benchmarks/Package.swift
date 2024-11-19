// swift-tools-version:6.0
import PackageDescription

let package:Package = .init(name: "swift-bson-benchmarks",
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark",
            .upToNextMajor(from: "1.27.3")),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "BSONEncodingBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "BSON", package: "swift-bson"),
            ],
            path: "Benchmarks/BSONEncodingBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]),
    ]
)
