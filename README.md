<div align="center">

***`bson`***

[![Tests](https://github.com/tayloraswift/swift-bson/actions/workflows/Tests.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/Tests.yml)
[![Documentation](https://github.com/tayloraswift/swift-bson/actions/workflows/Documentation.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/Documentation.yml)

</div>

The ***swift-bson*** library is a portable, Foundation-free library for working with [BSON](https://bsonspec.org/).

<div align="center">

[documentation](https://swiftinit.org/docs/swift-bson) ·
[license](LICENSE)

</div>


## Requirements

The swift-bson library requires Swift 6.0 or later.


| Platform | Status |
| -------- | ------ |
| 🐧 Linux | [![Tests](https://github.com/tayloraswift/swift-bson/actions/workflows/Tests.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/Tests.yml) |
| 🍏 Darwin | [![Tests](https://github.com/tayloraswift/swift-bson/actions/workflows/Tests.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/Tests.yml) |
| 🍏 Darwin (iOS) | [![iOS](https://github.com/tayloraswift/swift-bson/actions/workflows/iOS.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/iOS.yml) |
| 🍏 Darwin (tvOS) | [![tvOS](https://github.com/tayloraswift/swift-bson/actions/workflows/tvOS.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/tvOS.yml) |
| 🍏 Darwin (visionOS) | [![visionOS](https://github.com/tayloraswift/swift-bson/actions/workflows/visionOS.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/visionOS.yml) |
| 🍏 Darwin (watchOS) | [![watchOS](https://github.com/tayloraswift/swift-bson/actions/workflows/watchOS.yml/badge.svg)](https://github.com/tayloraswift/swift-bson/actions/workflows/watchOS.yml) |


[Check deployment minimums](https://swiftinit.org/docs/swift-bson#ss:platform-requirements)


## What is BSON?

[BSON](https://bsonspec.org/) is a general-purpose binary serialization format that is a superset of [JSON](https://www.json.org/). Parsing BSON requires much less memory than parsing JSON, and the format is traversable, which makes it possible to extract individual fields nested deep within a BSON document without actually parsing the entire file.

BSON was originally developed by [MongoDB](https://www.mongodb.com/), for which it serves as its native data format. However, the file format itself is not tied to MongoDB, and can be used in any system that requires a high-performance, low-memory serialization format.


## Why do I need this library?

If you are using [MongoKitten](https://github.com/orlandos-nl/MongoKitten), your MongoDB driver already includes a BSON parser based on the standard library’s [`Codable`](https://swiftinit.org/docs/swift/swift/codable) system, which has the advantage of generating much of the deserialization code for you automatically. However, `Codable` has well-known performance limitations, and is not suitable for high-throughput use cases.

Another reason to use this library is that it is portable and has few dependencies. BSON parsers provided by MongoDB drivers have dependencies on networking primitives such as [`ByteBuffer`](https://swiftinit.org/docs/swift-nio/niocore/bytebuffer), which requires you to link the [SwiftNIO library](https://github.com/apple/swift-nio). For applications that simply use BSON as a storage format, this may not be desirable.


## Is it faster than Codable?

The decoder is approximately 3 to 6 times faster than the default MongoKitten decoder. The encoder has similar throughput to `Codable`.

([Benchmark source code](/Benchmarks/Benchmarks/VsMongoKittenDefault))

<details>

<summary>Performance comparison </summary>

```
Host 'vscode' with 12 'x86_64' processors with 30 GB memory, running:
#202408030740 SMP PREEMPT_DYNAMIC Sat Aug  3 07:53:03 UTC 2024

====================
VsMongoKittenDefault
====================

Decode BSON with MongoKitten Default
╒═════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                              │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ (Alloc + Retain) - Release Δ *      │    1476 │    1500 │    1506 │    1512 │    1520 │    1529 │    1536 │     376 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Object allocs *                     │    2334 │    2459 │    2493 │    2521 │    2545 │    2605 │    2634 │     376 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Releases (K) *                      │      21 │      21 │      22 │      22 │      22 │      22 │      22 │     376 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Retains (K) *                       │      17 │      18 │      18 │      18 │      18 │      18 │      18 │     376 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (#)              │     617 │     592 │     583 │     572 │     562 │     415 │     234 │     376 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs) *            │    1620 │    1690 │    1714 │    1747 │    1781 │    2408 │    4276 │     376 │
╘═════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Decode BSON with This Library
╒═════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                              │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ (Alloc + Retain) - Release Δ *      │    7917 │    8035 │    8071 │    8099 │    8123 │    8167 │    8187 │    1000 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Object allocs *                     │     892 │     969 │     984 │     997 │    1011 │    1034 │    1061 │    1000 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Releases (K) *                      │      13 │      14 │      14 │      14 │      14 │      14 │      14 │    1000 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Retains *                           │    4406 │    4523 │    4555 │    4583 │    4607 │    4643 │    4697 │    1000 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (#)              │    1915 │    1820 │    1791 │    1748 │    1669 │    1175 │    1061 │    1000 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs) *            │     522 │     549 │     559 │     572 │     599 │     810 │     943 │    1000 │
╘═════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Encode BSON with MongoKitten Default
╒═════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                              │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ (Alloc + Retain) - Release Δ *      │    5054 │    5247 │    5307 │    5379 │    5427 │    5519 │    5598 │     513 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Object allocs *                     │    2993 │    3113 │    3153 │    3199 │    3229 │    3279 │    3323 │     513 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Releases (K) *                      │      39 │      41 │      41 │      42 │      42 │      43 │      44 │     513 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Retains (K) *                       │      31 │      33 │      33 │      33 │      34 │      34 │      35 │     513 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (#)              │     198 │     189 │     185 │     182 │     177 │     162 │     132 │     513 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs) *            │    5039 │    5300 │    5394 │    5501 │    5661 │    6181 │    7598 │     513 │
╘═════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛

Encode BSON with This Library
╒═════════════════════════════════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╤═════════╕
│ Metric                              │      p0 │     p25 │     p50 │     p75 │     p90 │     p99 │    p100 │ Samples │
╞═════════════════════════════════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╪═════════╡
│ (Alloc + Retain) - Release Δ *      │    5066 │    5251 │    5311 │    5375 │    5427 │    5531 │    5614 │     514 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Object allocs *                     │    3003 │    3123 │    3153 │    3199 │    3229 │    3293 │    3353 │     514 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Releases (K) *                      │      39 │      41 │      41 │      42 │      42 │      43 │      44 │     514 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Retains (K) *                       │      31 │      33 │      33 │      33 │      34 │      34 │      35 │     514 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Throughput (# / s) (#)              │     198 │     189 │     186 │     183 │     178 │     159 │      95 │     514 │
├─────────────────────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ Time (wall clock) (μs) *            │    5061 │    5280 │    5366 │    5464 │    5612 │    6275 │   10509 │     514 │
╘═════════════════════════════════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╧═════════╛
```

</details>


## Should I really be using BSON?

BSON is not for everyone. The rationales below are *not* good reasons to adopt BSON, at least by themselves.


### Saving disk space

BSON will save memory when parsing, but in typical use cases, a BSON file will occupy a similar amount of space as an equivalent JSON file, and offer a similar compression ratio.


### Serving to the web

BSON is generally considered a server side format, and there are few compelling reasons to synthesize it for the sole purpose of serving content to browsers.

That said, [JavaScript libraries](https://www.npmjs.com/package/bson) do exist for parsing BSON, so it is possible to use it on the client side. One good reason to do this is if you are storing BSON objects as static resources accessible from a CDN, and want clients to be able to download the BSON from the CDN instead of converting it dynamically to JSON via your HTTP server.


## Is it worth the effort?

Learning this library will enable you to use a high-performance binary serialization format across a wide range of platforms. The library is small, written in pure Swift, and organized around a few key patterns that emphasize maintainability in large codebases.

Although swift-bson cannot synthesize serialization code for you, its idioms are predictable and easily “paintable” by LLMs such as GitHub Copilot.


## What does the code look like?

In a “realistic” codebase, a BSON model type looks like this:

```swift
struct ExampleModel:BSONDocumentEncodable, BSONDocumentDecodable
{
    let id:Int64
    let name:String?
    let rank:Rank

    /// A custom enum type.
    enum Rank:Int32, BSONEncodable, BSONDecodable
    {
        case newModel
        case risingStar
        case aspiringModel
        case fashionista
        case glamourista
        case fashionMaven
        case runwayQueen
        case trendSetter
        case runwayDiva
        case topModel
    }

    /// The schema definition.
    enum CodingKey:String, Sendable
    {
        case id = "_id" // Chosen for compatibility with MongoDB
        case name = "D"
        case rank = "R"
    }

    /// The serialization logic.
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
        bson[.rank] = self.rank == .newModel ? nil : self.rank
    }

    /// The deserialization logic.
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.id = try bson[.id].decode()
        self.name = try bson[.name]?.decode()
        self.rank = try bson[.rank]?.decode() ?? .newModel
    }
}
```

The code to actually round-trip this to and from raw data looks like this:

```swift
let models:[ExampleModel] = [
    .init(id: 0, name: "Gigi", rank: .topModel),
    .init(id: 1, name: nil, rank: .newModel),
]

/// Round-trip one model
let document:BSON.Document = .init(encoding: models[0])
let _:ArraySlice<UInt8> = document.bytes
let model:ExampleModel = try .init(bson: document)

/// Round-trip a list of models
let list:BSON.List = .init(elements: models)
let _:ArraySlice<UInt8> = list.bytes
let array:[ExampleModel] = try .init(bson: list)
```


## Tutorials

- [Usage Examples](https://swiftinit.org/docs/swift-bson/bson/examples)
- [Protocols Explained](https://swiftinit.org/docs/swift-bson/bson/walkthrough)
- [Advanced Serialization Patterns](https://swiftinit.org/docs/swift-bson/bson/serialization-patterns)
- [Textures and Coordinates](https://swiftinit.org/docs/swift-bson/bson/textures-and-coordinates)


## License

The swift-bson library is Apache 2.0 licensed.
