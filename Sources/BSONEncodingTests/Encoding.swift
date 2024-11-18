import BSONEncoding
import Testing

@Suite
struct Encoding:EncodingTest
{
    @Test
    static func document() throws
    {
        /// Verify that we do not crash when creating an empty document.
        let _:BSON.Document = [:]

        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = [:]
                $0["b"](BSON.Key.self)
                {
                    $0["x"] = 1
                }
                $0["c"](BSON.Key.self)
                {
                    $0["x"] = 1
                    $0["y"] = 2
                }
            },
            literal:
            [
                "a": [:],
                "b": ["x": 1],
                "c": ["x": 1, "y": 2],
            ])
    }

    @Test
    static func list() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = [] as [Never]
                $0["b"] = [1]
                $0["c"](Int.self)
                {
                    $0[+] = 1
                    $0[+] = "x"
                    $0[+] = 5.5
                }
            },
            literal:
            [
                "a": [],
                "b": [1],
                "c": [1, "x", 5.5],
            ])
    }

    @Test
    static func string() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["a"] = ""
                $0["b"] = "foo"
                $0["c"] = "foo\u{0}"
            },
            literal:
            [
                "a": "",
                "b": "foo",
                "c": "foo\u{0}",
            ])
    }

    @Test
    static func null() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["elided"] = nil as Never??
                $0["inhabited"] = BSON.Null.init()
            },
            literal:
            [
                "inhabited": .null,
            ])
    }

    @Test
    static func optionals() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["elided"] = nil as Int??
                $0["inhabited"] = (5 as Int?) as Int??
                $0["uninhabited"] = (nil as Int?) as Int??
            },
            literal:
            [
                "inhabited": 5,
                "uninhabited": .null,
            ])
    }

    @Test
    static func elision() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["elided"] = nil as Int?
                $0["inhabited"] = 5
            },
            literal:
            [
                "inhabited": 5,
            ])
    }

    @Test
    static func duplication() throws
    {
        try Self.validate(
            encoded: .init(BSON.Key.self)
            {
                $0["inhabited"] = 5
                $0["uninhabited"] = nil as Never??
                $0["inhabited"] = 7
                $0["uninhabited"] = nil as Never??
            },
            literal:
            [
                "inhabited": 5,
                "inhabited": 7,
            ])
    }
}
