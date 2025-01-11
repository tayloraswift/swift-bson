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

## Tutorials

- [Usage Examples](https://swiftinit.org/docs/swift-bson/bson/examples)
- [Protocols Explained](https://swiftinit.org/docs/swift-bson/bson/walkthrough)
- [Advanced Serialization Patterns](https://swiftinit.org/docs/swift-bson/bson/serialization-patterns)
- [Textures and Coordinates](https://swiftinit.org/docs/swift-bson/bson/textures-and-coordinates)


## License

The swift-bson library is Apache 2.0 licensed.
