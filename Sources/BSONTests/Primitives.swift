import Base16
import BSON
import BSONLiterals
import BSONReflection
import BSON_UUID
import UnixTime
import UUID
import Testing

@Suite
struct ValidBSON
{
    enum TestKey:String
    {
        case a
        case b
        case x
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/multi-type.json
    // cannot use this test, because it encodes a deprecated binary subtype, which is
    // (intentionally) impossible to construct with swift-bson.

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/maxkey.json
    @Test
    static func max() throws
    {
        try Self.test(
            canonical: "080000007F610000",
            expected: ["a": .max])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/minkey.json
    @Test
    static func min() throws
    {
        try Self.test(
            canonical: "08000000FF610000",
            expected: ["a": .min])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/null.json
    @Test
    static func null() throws
    {
        try Self.test(
            canonical: "080000000A610000",
            expected: ["a": .null])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/undefined.json
    @Test
    static func undefined() throws
    {
        try Self.test(
            degenerate: "0800000006610000",
            canonical: "080000000A610000",
            expected: ["a": .null])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/boolean.json
    @Test
    static func boolean() throws
    {
        try Self.test(
            canonical: "090000000862000100",
            expected: ["b": true])
        try Self.test(
            canonical: "090000000862000000",
            expected: ["b": false])

        try Self.test(
            canonical: "090000000862000100",
            expected: .init(TestKey.self) { $0[.b] = true })
        try Self.test(
            canonical: "090000000862000000",
            expected: .init(TestKey.self) { $0[.b] = false })
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/int32.json
    @Test
    static func int32() throws
    {
        try Self.test(
            canonical: "0C0000001069000000008000",
            expected: ["i": .int32(-2147483648)])

        try Self.test(
            canonical: "0C000000106900FFFFFF7F00",
            expected: ["i": .int32(2147483647)])

        try Self.test(
            canonical: "0C000000106900FFFFFFFF00",
            expected: ["i": .int32(-1)])

        try Self.test(
            canonical: "0C0000001069000000000000",
            expected: ["i": .int32(0)])

        try Self.test(
            canonical: "0C0000001069000100000000",
            expected: ["i": .int32(1)])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/int64.json
    @Test
    static func int64() throws
    {
        try Self.test(
            canonical: "10000000126100000000000000008000",
            expected: ["a": .int64(-9223372036854775808)])

        try Self.test(
            canonical: "10000000126100FFFFFFFFFFFFFF7F00",
            expected: ["a": .int64(9223372036854775807)])

        try Self.test(
            canonical: "10000000126100FFFFFFFFFFFFFFFF00",
            expected: ["a": .int64(-1)])

        try Self.test(
            canonical: "10000000126100000000000000000000",
            expected: ["a": .int64(0)])

        try Self.test(
            canonical: "10000000126100010000000000000000",
            expected: ["a": .int64(1)])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/timestamp.json
    @Test
    static func timestamp() throws
    {
        try Self.test(
            canonical: "100000001161002A00000015CD5B0700",
            expected: ["a": .timestamp(.init(123456789 << 32 | 42))])

        try Self.test(
            canonical: "10000000116100FFFFFFFFFFFFFFFF00",
            expected: ["a": .timestamp(.max)])

        try Self.test(
            canonical: "1000000011610000286BEE00286BEE00",
            expected: ["a": .timestamp(.init(4000000000 << 32 | 4000000000))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/top.json
    @Test
    static func top() throws
    {
        try Self.test(
            canonical: "0F00000010246B6579002A00000000",
            expected: ["$key": .int32(42)])

        try Self.test(
            canonical: "0E00000002240002000000610000",
            expected: ["$": "a"])

        try Self.test(
            canonical: "1000000002612E620002000000630000",
            expected: ["a.b": "c"])

        try Self.test(
            canonical: "0E000000022E0002000000610000",
            expected: [".": "a"])

        //  Truncated header
        try Self.test(
            degenerate: "0100000000",
            canonical: "0500000000",
            expected: [:])

        try Self.test(
            canonical: "0500000000",
            expected: [:])

        try Self.test(
            degenerate: "05000000_01",
            canonical: "05000000_00",
            expected: [:])

        try Self.test(
            degenerate: "05000000_FF",
            canonical: "05000000_00",
            expected: [:])

        try Self.test(
            degenerate: "05000000_70",
            canonical: "05000000_00",
            expected: [:])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/decimal128-1.json
    @Test
    static func decimal128() throws
    {
        try Self.test(
            canonical: "180000001364000000000000000000000000000000007C00",
            expected: ["d": .decimal128(.init(
                high: 0x7C00_0000_0000_0000,
                low:  0x0000_0000_0000_0000))])

        try Self.test(
            canonical: "18000000136400000000000000000000000000000000FC00",
            expected: ["d": .decimal128(.init(
                high: 0xFC00_0000_0000_0000,
                low:  0x0000_0000_0000_0000))])

        try Self.test(
            canonical: "180000001364000000000000000000000000000000007E00",
            expected: ["d": .decimal128(.init(
                high: 0x7E00_0000_0000_0000,
                low:  0x0000_0000_0000_0000))])

        try Self.test(
            canonical: "18000000136400000000000000000000000000000000FE00",
            expected: ["d": .decimal128(.init(
                high: 0xFE00_0000_0000_0000,
                low:  0x0000_0000_0000_0000))])

        // this only serves to verify we are handling byte-order correctly;
        // there is very little point in elaborating decimal128 tests further
        try Self.test(
            canonical: "18000000136400F2AF967ED05C82DE3297FF6FDE3C403000",
            expected: ["d": .decimal128(.init(
                high: 0x3040_3CDE_6FFF_9732,
                low:  0xDE82_5CD0_7E96_AFF2))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/datetime.json
    @Test
    static func millisecond() throws
    {
        try Self.test(
            canonical: "10000000096100000000000000000000",
            expected: ["a": .millisecond(.init(index: 0))])

        try Self.test(
            canonical: "10000000096100C5D8D6CC3B01000000",
            expected: ["a": .millisecond(.init(index: 1356351330501))])

        try Self.test(
            canonical: "10000000096100C33CE7B9BDFFFFFF00",
            expected: ["a": .millisecond(.init(index: -284643869501))])

        try Self.test(
            canonical: "1000000009610000DC1FD277E6000000",
            expected: ["a": .millisecond(.init(index: 253402300800000))])

        try Self.test(
            canonical: "10000000096100D1D6D6CC3B01000000",
            expected: ["a": .millisecond(.init(index: 1356351330001))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/double.json
    @Test
    static func double() throws
    {
        try Self.test(
            canonical: "10000000016400000000000000F03F00",
            expected: ["d": .double(1.0)])

        try Self.test(
            canonical: "10000000016400000000000000F0BF00",
            expected: ["d": .double(-1.0)])

        try Self.test(
            canonical: "10000000016400000000008000F03F00",
            expected: ["d": .double(1.0001220703125)])

        try Self.test(
            canonical: "10000000016400000000008000F0BF00",
            expected: ["d": .double(-1.0001220703125)])

        try Self.test(
            canonical: "100000000164002a1bf5f41022b14300",
            expected: ["d": .double(1.2345678921232e18)])

        try Self.test(
            canonical: "100000000164002a1bf5f41022b1c300",
            expected: ["d": .double(-1.2345678921232e18)])

        // remaining corpus test cases are pointless because swift cannot distinguish
        // between -0.0 and +0.0
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/oid.json
    @Test
    static func id() throws
    {
        let id:BSON.Identifier = 0x0123_4567_89AB_CDEF_4567_3210

        #expect(id.timestamp == 0x0123_4567)
        #expect(id.seed == (0x89, 0xAB, 0xCD, 0xEF, 0x45))
        #expect(id.ordinal == (0x67, 0x32, 0x10))

        #expect(id == .init(timestamp: id.timestamp, seed: id.seed, ordinal: id.ordinal))

        try Self.test(
            canonical: "1400000007610000000000000000000000000000",
            expected: ["a": .id(0x00000000_00000000_00_000000)])

        try Self.test(
            canonical: "14000000076100FFFFFFFFFFFFFFFFFFFFFFFF00",
            expected: ["a": .id(0xffffffff_ffffffff_ff_ffffff)])

        try Self.test(
            canonical: "1400000007610056E1FC72E0C917E9C471416100",
            expected: ["a": .id(0x56e1fc72_e0c917e9_c4_714161)])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/dbpointer.json
    @Test
    static func pointer() throws
    {
        try Self.test(
            canonical: "1A0000000C610002000000620056E1FC72E0C917E9C471416100",
            expected: ["a": .pointer(.init(from: "b"), .init(
                0x56e1fc72, 0xe0c917e9, 0xc4_714161))])

        try Self.test(
            canonical: "1B0000000C610003000000C3A90056E1FC72E0C917E9C471416100",
            expected: ["a": .pointer(.init(from: "é"), .init(
                0x56e1fc72, 0xe0c917e9, 0xc4_714161))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/binary.json
    @Test
    static func binary() throws
    {
        try Self.test(
            canonical: "0D000000057800000000000000",
            expected: ["x": .binary(.init(subtype: .generic, bytes: []))])

        try Self.test(
            canonical: "0F0000000578000200000000FFFF00",
            expected: ["x": .binary(.init(subtype: .generic,
                bytes: Base16.decode("ffff")))])

        try Self.test(
            canonical: "0F0000000578000200000001FFFF00",
            expected: ["x": .binary(.init(subtype: .function,
                bytes: Base16.decode("ffff")))])

        try Self.test(
            canonical: "0F0000000578000200000001FFFF00",
            expected: ["x": .binary(.init { $0.subtype = .function ; $0 += [0xff, 0xff] })])

        try Self.test(
            canonical: "1D000000057800100000000473FFD26444B34C6990E8E7D1DFC035D400",
            expected: ["x": .binary(.init(subtype: .uuid,
                bytes: Base16.decode("73ffd26444b34c6990e8e7d1dfc035d4")))])
        try Self.test(
            canonical: "1D000000057800100000000473FFD26444B34C6990E8E7D1DFC035D400",
            expected: .init(TestKey.self)
            {
                $0[.x] = UUID.init(0x73ffd26444b34c69, 0x90e8e7d1dfc035d4)
            })

        try Self.test(
            canonical: "1D000000057800100000000573FFD26444B34C6990E8E7D1DFC035D400",
            expected: ["x": .binary(.init(subtype: .md5,
                bytes: Base16.decode("73ffd26444b34c6990e8e7d1dfc035d4")))])

        try Self.test(
            canonical: "1D000000057800100000000773FFD26444B34C6990E8E7D1DFC035D400",
            expected: ["x": .binary(.init(subtype: .compressed,
                bytes: Base16.decode("73ffd26444b34c6990e8e7d1dfc035d4")))])

        try Self.test(
            canonical: "0F0000000578000200000080FFFF00",
            expected: ["x": .binary(.init(subtype: .custom(code: 0x80),
                bytes: Base16.decode("ffff")))])
        // TODO: tests for legacy binary subtype 0x02
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/document.json
    @Test
    static func document() throws
    {
        try Self.test(
            canonical: "0D000000037800050000000000",
            expected: ["x": [:]])

        try Self.test(
            canonical: "150000000378000D00000002000200000062000000",
            expected: ["x": ["": "b"]])

        try Self.test(
            canonical: "160000000378000E0000000261000200000062000000",
            expected: ["x": ["a": "b"]])

        try Self.test(
            canonical: "170000000378000F000000022461000200000062000000",
            expected: ["x": ["$a": "b"]])

        try Self.test(
            canonical: "160000000378000E0000000224000200000061000000",
            expected: ["x": ["$": "a"]])

        try Self.test(
            canonical: "180000000378001000000002612E62000200000063000000",
            expected: ["x": ["a.b": "c"]])

        try Self.test(
            canonical: "160000000378000E000000022E000200000061000000",
            expected: ["x": [".": "a"]])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/array.json
    @Test
    static func tuple() throws
    {
        try Self.test(
            canonical: "0D000000046100050000000000",
            expected: ["a": []])
        try Self.test(
            canonical: "140000000461000C0000001030000A0000000000",
            expected: ["a": [.int32(10)]])

        try Self.test(
            degenerate: "130000000461000B00000010000A0000000000",
            canonical: "140000000461000C0000001030000A0000000000",
            expected: ["a": [.int32(10)]])

        try Self.test(
            degenerate: "150000000461000D000000106162000A0000000000",
            canonical: "140000000461000C0000001030000A0000000000",
            expected: ["a": [.int32(10)]])

        try Self.test(
            degenerate: "1b000000046100130000001030000a000000103000140000000000",
            canonical: "1b000000046100130000001030000a000000103100140000000000",
            expected: ["a": [.int32(10), .int32(20)]])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/regex.json
    @Test
    static func regex() throws
    {
        try Self.test(
            canonical: "0A0000000B6100000000",
            expected: ["a": .regex(.init(pattern: "", options: []))])

        try Self.test(
            canonical: "0D0000000B6100616263000000",
            expected: ["a": .regex(.init(pattern: "abc", options: []))])

        try Self.test(
            canonical: "0F0000000B610061626300696D0000",
            expected: ["a": .regex(.init(pattern: "abc", options: [.i, .m]))])

        try Self.test(
            canonical: "110000000B610061622F636400696D0000",
            expected: ["a": .regex(.init(pattern: "ab/cd", options: [.i, .m]))])

        try Self.test(
            degenerate: "100000000B6100616263006D69780000",
            canonical: "100000000B610061626300696D780000",
            expected: ["a": .regex(.init(pattern: "abc", options: [.i, .m, .x]))])

        try Self.test(
            canonical: "100000000B610061625C226162000000",
            expected: ["a": .regex(.init(pattern: #"ab\"ab"#, options: []))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/string.json
    @Test
    static func string() throws
    {
        try Self.test(
            canonical: "0D000000026100010000000000",
            expected: ["a": ""])

        try Self.test(
            canonical: "0E00000002610002000000620000",
            expected: ["a": "b"])

        try Self.test(
            canonical: "190000000261000D0000006162616261626162616261620000",
            expected: ["a": "abababababab"])

        try Self.test(
            canonical: "190000000261000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
            expected: ["a": "\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}"])

        try Self.test(
            canonical: "190000000261000D000000E29886E29886E29886E298860000",
            expected: ["a": "\u{2606}\u{2606}\u{2606}\u{2606}"])

        try Self.test(
            canonical: "190000000261000D0000006162006261620062616261620000",
            expected: ["a": "ab\u{00}bab\u{00}babab"])

        try Self.test(
            canonical:
                """
                3200000002610026000000\
                61625C220102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F6162\
                0000
                """,
            expected:
            [
                "a":
                """
                ab\\\"\u{01}\u{02}\u{03}\u{04}\u{05}\u{06}\u{07}\u{08}\
                \t\n\u{0b}\u{0c}\r\u{0e}\u{0f}\u{10}\
                \u{11}\u{12}\u{13}\u{14}\u{15}\u{16}\u{17}\u{18}\u{19}\
                \u{1a}\u{1b}\u{1c}\u{1d}\u{1e}\u{1f}ab
                """
            ])

        try Self.test(
            canonical: "0E00000002610002000000E90000",
            expected: ["a": .string(.init(bytes: [0xe9]))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/symbol.json
    @Test
    static func symbol() throws
    {
        try Self.test(
            degenerate: "0D0000000E6100010000000000",
            canonical: "0D000000026100010000000000",
            expected: ["a": ""])

        try Self.test(
            degenerate: "0E0000000E610002000000620000",
            canonical: "0E00000002610002000000620000",
            expected: ["a": "b"])

        try Self.test(
            degenerate: "190000000E61000D0000006162616261626162616261620000",
            canonical: "190000000261000D0000006162616261626162616261620000",
            expected: ["a": "abababababab"])

        try Self.test(
            degenerate: "190000000E61000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
            canonical: "190000000261000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
            expected: ["a": "\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}"])

        try Self.test(
            degenerate: "190000000E61000D000000E29886E29886E29886E298860000",
            canonical: "190000000261000D000000E29886E29886E29886E298860000",
            expected: ["a": "\u{2606}\u{2606}\u{2606}\u{2606}"])

        try Self.test(
            degenerate: "190000000E61000D0000006162006261620062616261620000",
            canonical: "190000000261000D0000006162006261620062616261620000",
            expected: ["a": "ab\u{00}bab\u{00}babab"])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/code.json
    @Test
    static func javascript() throws
    {
        try Self.test(
            canonical: "0D0000000D6100010000000000",
            expected: ["a": .javascript(.init(from: ""))])

        try Self.test(
            canonical: "0E0000000D610002000000620000",
            expected: ["a": .javascript(.init(from: "b"))])

        try Self.test(
            canonical: "190000000D61000D0000006162616261626162616261620000",
            expected: ["a": .javascript(.init(from: "abababababab"))])

        try Self.test(
            canonical: "190000000D61000D000000C3A9C3A9C3A9C3A9C3A9C3A90000",
            expected: ["a": .javascript(.init(from: "\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}\u{e9}"))])

        try Self.test(
            canonical: "190000000D61000D000000E29886E29886E29886E298860000",
            expected: ["a": .javascript(.init(from: "\u{2606}\u{2606}\u{2606}\u{2606}"))])

        try Self.test(
            canonical: "190000000D61000D0000006162006261620062616261620000",
            expected: ["a": .javascript(.init(from: "ab\u{00}bab\u{00}babab"))])
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/code_w_scope.json
    @Test
    static func javascriptScope() throws
    {
        try Self.test(
            canonical: "160000000F61000E0000000100000000050000000000",
            expected: ["a": .javascriptScope([:], .init(from: ""))])

        try Self.test(
            canonical: "1A0000000F610012000000050000006162636400050000000000",
            expected: ["a": .javascriptScope([:], .init(from: "abcd"))])

        try Self.test(
            canonical: "1D0000000F61001500000001000000000C000000107800010000000000",
            expected: ["a": .javascriptScope(["x": .int32(1)], .init(from: ""))])

        try Self.test(
            canonical: "210000000F6100190000000500000061626364000C000000107800010000000000",
            expected: ["a": .javascriptScope(["x": .int32(1)], .init(from: "abcd"))])

        try Self.test(
            canonical: "1A0000000F61001200000005000000C3A9006400050000000000",
            expected: ["a": .javascriptScope([:], .init(from: "\u{e9}\u{00}d"))])
    }
}
extension ValidBSON
{
    private
    static func test(degenerate:String? = nil, canonical:String, expected:BSON.Document) throws
    {
        let canonical:[UInt8] = Base16.decode(canonical.utf8)
        let size:Int32 = canonical.prefix(4).withUnsafeBytes
        {
            .init(littleEndian: $0.load(as: Int32.self))
        }

        let document:BSON.Document = .init(
            slicing: canonical.dropFirst(4).dropLast())

        #expect(canonical.count == .init(size))
        #expect(document.header == size)

        #expect(expected == document)
        #expect(expected.bytes == document.bytes)

        if  let degenerate:String
        {
            let degenerate:[UInt8] = Base16.decode(degenerate.utf8)
            let document:BSON.Document = .init(
                slicing: degenerate.dropFirst(4).dropLast())

            let canonicalized:BSON.Document = try document.canonicalized()

            #expect(expected == document)
            #expect(expected.bytes == canonicalized.bytes)
        }
    }
}
