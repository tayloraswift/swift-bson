import Base16
import BSON
import BSONReflection
import Testing

@Suite
struct InvalidBSON
{
    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/boolean.json
    @Test
    static func boolean() throws
    {
        try Self.test("invalid-subtype",
            invalid: "090000000862000200",
            catching: BSON.BooleanSubtypeError.init(invalid: 2))

        try Self.test("invalid-subtype-negative",
            invalid: "09000000086200FF00",
            catching: BSON.BooleanSubtypeError.init(invalid: 255))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/int32.json
    @Test
    static func int32() throws
    {
        try Self.test("truncated",
            invalid: "09000000_10_6100_05_00",
            catching: BSON.InputError.init(expected: .bytes(4), encountered: 1))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/int32.json
    @Test
    static func int64() throws
    {
        try Self.test("truncated",
            invalid: "0C000000_12_6100_12345678_00",
            catching: BSON.InputError.init(expected: .bytes(8), encountered: 4))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/timestamp.json
    @Test
    static func uint64() throws
    {
        try Self.test("truncated",
            invalid: "0F000000_11_6100_2A00000015CD5B_00",
            catching: BSON.InputError.init(expected: .bytes(8), encountered: 7))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/top.json
    @Test
    static func top() throws
    {
        try Self.test("zeroes",
            invalid: "00000000_000000000000",
            //        ^~~~~~~~
            catching: BSON.HeaderError<BSON.DocumentFrame>.init(length: 0))

        try Self.test("invalid-length-over",
            invalid: "12000000_02_666F6F00_04000000_626172",
            //        ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0x12 - 4), encountered: 12))

        try Self.test("invalid-length-under",
            invalid: "12000000_02_666F6F00_04000000_62617200_00_DEADBEEF",
            //        ^~~~~~~~
            catching: BSON.InputError.init(expected: .end, encountered: 4))

        try Self.test("invalid-type-0x00",
            invalid: "07000000_00_0000",
            //                 ^~
            catching: BSON.TypeError.init(invalid: 0x00))

        try Self.test("invalid-type-0x80",
            invalid: "07000000_80_0000",
            //                 ^~
            catching: BSON.TypeError.init(invalid: 0x80))

        try Self.test("truncated",
            invalid: "12000000_02_666F",
            catching: BSON.InputError.init(expected: .bytes(0x12 - 4), encountered: 3))

        try Self.test("invalid-key",
            invalid: "0D000000_10_7800_00_0100000000",
            //                         ^~
            catching: BSON.TypeError.init(invalid: 0x00))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/datetime.json
    @Test
    static func millisecond() throws
    {
        try Self.test("truncated",
            invalid: "0C000000_0961001234567800",
            catching: BSON.InputError.init(expected: .bytes(8), encountered: 4))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/double.json
    @Test
    static func double() throws
    {
        // note: frameshift
        try Self.test("truncated",
            invalid: "0B000000_0164000000F03F00",
            //        ^~~~~~~~
            catching: BSON.InputError.init(expected: .end, encountered: 1))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/oid.json
    @Test
    static func id() throws
    {
        try Self.test("truncated",
            invalid: "12000000_07_6100_56E1FC72E0C917E9C471",
            //        ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0x12 - 4), encountered: 13))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/dbpointer.json
    @Test
    static func pointer() throws
    {
        try Self.test("invalid-length-negative",
            invalid: "1A000000_0C_6100_FFFFFFFF_620056E1FC72E0C917E9C471416100",
            //                         ^~~~~~~~
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: -1))

        try Self.test("invalid-length-zero",
            invalid: "1A000000_0C_6100_00000000_620056E1FC72E0C917E9C471416100",
            //                         ^~~~~~~~
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))

        try Self.test("truncated",
            invalid: "16000000_0C_6100_03000000_616200_56E1FC72E0C91700",
            catching: BSON.InputError.init(expected: .bytes(12), encountered: 7))

        try Self.test("truncated-identifier",
            invalid: "1A000000_0C_6100_03000000_616200_56E1FC72E0C917E9C4716100",
            catching: BSON.InputError.init(expected: .bytes(12), encountered: 11))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/binary.json
    @Test
    static func binary() throws
    {
        try Self.test("invalid-length-over",
            invalid: "1D000000_05_7800_FF000000_05_73FFD26444B34C6990E8E7D1DFC035D400",
            //                         ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0xFF + 1), encountered: 17))

        try Self.test("invalid-length-negative",
            invalid: "0D000000057800FFFFFFFF0000",
            catching: BSON.BinaryViewError.init(expected: .subtype))
        // TODO: tests for legacy binary subtype 0x02
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/document.json
    @Test
    static func document() throws
    {
        try Self.test("invalid-length-over",
            invalid: "18000000_03_666F6F00_0F000000_10_62617200_FFFFFF7F_0000",
            //                             ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0x0F - 4), encountered: 10))

        try Self.test("invalid-length-under",
            invalid: "15000000_03_666F6F00_0A000000_08_62617200_01_00_00",
            //                                                           ^~
            catching: BSON.InputError.init(expected: .bytes(1)))

        try Self.test("invalid-value",
            invalid: "1C000000_03_666F6F00_12000000_02_62617200_05000000_62617A000000",
            //                                                  ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))

        try Self.test("invalid-key",
            invalid: "15000000_03_7800_0D000000_10_6100_00010000_00_0000",
            //                                                   ^~
            catching: BSON.TypeError.init(invalid: 0))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/array.json
    @Test
    static func tuple() throws
    {
        try Self.test("invalid-length-over",
            invalid: "14000000_04_6100_0D000000_10_30000A00_00_000000",
            //                         ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0x0D - 4), encountered: 8))

        try Self.test("invalid-length-under",
            invalid: "14000000_04_6100_0B000000_10_30000A00_00_000000",
            //                         ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(4), encountered: 3))

        try Self.test("invalid-element",
            invalid: "1A000000_04_666F6F00_100000000230000500000062617A000000",
            //
            catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/regex.json
    @Test
    static func regex() throws
    {
        // note: frameshift
        try Self.test("invalid-pattern",
            invalid: "0F0000000B610061006300696D0000",
            catching: BSON.Regex.OptionError.init(invalid: "c"))
        // note: frameshift
        try Self.test("invalid-options",
            invalid: "100000000B61006162630069006D0000",
            catching: BSON.TypeError.init(invalid: 109))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/string.json
    @Test
    static func string() throws
    {
        try Self.test("missing-trailing-null-byte",
            invalid: "0C000000_02_6100_00000000_00",
            //                         ^~~~~~~~
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))

        try Self.test("invalid-length-negative",
            invalid: "0C000000_02_6100_FFFFFFFF_00",
            //                         ^~~~~~~~
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: -1))

        try Self.test("invalid-length-over",
            invalid: "10000000_02_6100_05000000_62006200_00",
            //                         ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))

        try Self.test("invalid-length-over-document",
            invalid: "12000000_02_00_FFFFFF00_666F6F6261720000",
            //                       ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0xffffff), encountered: 7))

        try Self.test("invalid-length-under",
            invalid: "0E000000_02_6100_01000000_00_00_00",
            //                                     ^~
            catching: BSON.TypeError.init(invalid: 0x00))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/code.json
    @Test
    static func javascript() throws
    {
        try Self.test("missing-trailing-null-byte",
            invalid: "0C000000_0D_6100_00000000_00",
            //                         ^~~~~~~~
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))

        try Self.test("invalid-length-negative",
            invalid: "0C0000000D6100FFFFFFFF00",
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: -1))

        try Self.test("invalid-length-over",
            invalid: "10000000_0D_6100_05000000_6200620000",
            //                         ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(5), encountered: 4))

        try Self.test("invalid-length-over-document",
            invalid: "12000000_0D_00_FFFFFF00_666F6F6261720000",
            //                       ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0xffffff), encountered: 7))

        try Self.test("invalid-length-under",
            invalid: "0E000000_0D_6100_01000000_00_00_00",
            //                                     ^~
            catching: BSON.TypeError.init(invalid: 0x00))
    }

    // https://github.com/mongodb/specifications/blob/master/source/bson-corpus/tests/code_w_scope.json
    @Test
    static func javascriptScope() throws
    {
        // note: we do not validate the redundant field length,
        // so those tests are not included

        // note: the length is actually too short, but because we use the component-wise
        // length headers instead of the field length, this manifests itself as a
        // frameshift error.
        try Self.test("invalid-length-frameshift-clips-scope",
            invalid: """
            28000000_0F_6100_20000000_04000000_61626364_00130000_0010780001000000107900010000000000
            """,
            //                                          ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0x00_00_13_00 - 4), encountered: 16))

        try Self.test("invalid-length-over",
            invalid: """
            28000000_0F_6100_20000000_06000000_616263640013_00000010_780001000000107900010000000000
            """,
            //                                              ^~~~~~~~
            catching: BSON.InputError.init(expected: .bytes(0x10_00_00_00 - 4), encountered: 14))
        // note: frameshift
        try Self.test("invalid-length-frameshift",
            invalid: """
            28000000_0F_6100_20000000_FF000000_61626364001300000010780001000000107900010000000000
            """,
            catching: BSON.InputError.init(expected: .bytes(255), encountered: 24))

        try Self.test("invalid-scope",
            invalid: """
            1C000000_0F_00_15000000_01000000_00_0C000000_02_00000000_00000000
            """,
            //                                              ^~~~~~~~
            catching: BSON.HeaderError<BSON.UTF8Frame>.init(length: 0))
    }
}
extension InvalidBSON
{
    private
    static func test(_ name:String,
        invalid:String,
        catching error:some Error & Equatable) throws
    {
        let invalid:[UInt8] = Base16.decode(invalid.utf8)

        var input:BSON.Input = .init(invalid[...])

        #expect(throws: error)
        {
            let document:BSON.Document = try input.parse(as: BSON.Document.self)
            try input.finish()
            _ = try document.canonicalized()
        }
    }
}
