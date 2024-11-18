import BSONEncoding
import Testing

@Suite
struct TypeInference:EncodingTest
{
    @Test
    static func binary() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = BSON.BinaryView<[UInt8]>.init(subtype: .generic,
                    bytes: [0xff, 0xff, 0xff])
            },
            literal:
            [
                "a": .binary(.init(subtype: .generic,
                    bytes: [0xff, 0xff, 0xff])),
            ])
    }

    @Test
    static func max() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["max"] = BSON.Max.init()
            },
            literal:
            [
                "max": .max,
            ])
    }

    @Test
    static func min() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["min"] = BSON.Min.init()
            },
            literal:
            [
                "min": .min,
            ])
    }

    @Test
    static func null() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["null"] = (nil as Never?) as Never??
            },
            literal:
            [
                "null": .null,
            ])
    }
}
