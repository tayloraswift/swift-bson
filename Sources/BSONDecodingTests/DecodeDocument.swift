import BSON
import Testing

@Suite
struct DecodeDocument
{
    private
    enum CodingKey:String, Sendable
    {
        case inhabited
        case missing
        case present
    }

    private
    let bson:BSON.DocumentDecoder<CodingKey>

    init() throws
    {
        let bson:BSON.Document = .init(CodingKey.self)
        {
            $0[.present] = BSON.Null.init()
            $0[.inhabited] = true
        }
        self.bson = try .init(parsing: bson)
    }
}
extension DecodeDocument
{
    @Test
    static func KeyNotUnique() throws
    {
        #expect(throws: BSON.DocumentKeyError<CodingKey>.duplicate(.present))
        {
            let degenerate:BSON.Document = .init(CodingKey.self)
            {
                $0[.present] = BSON.Null.init()
                $0[.present] = true
            }
            let decoder:BSON.DocumentDecoder<CodingKey> = try .init(parsing: degenerate)
            _ = try decoder[.missing].decode(to: Bool.self)
        }
    }
}
extension DecodeDocument
{
    @Test
    func KeyNotPresent() throws
    {
        #expect(throws: BSON.DocumentKeyError<CodingKey>.undefined(.missing))
        {
            try self.bson[.missing].decode(to: Bool.self)
        }
    }

    @Test
    func KeyNotMatching() throws
    {
        #expect(throws:
            BSON.DecodingError<CodingKey>.init(
                BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(invalid: .bool),
                in: .inhabited))
        {
            try self.bson[.inhabited].decode(to: String.self)
        }
    }

    @Test
    func KeyNotMatchingInhabited() throws
    {
        #expect(throws: BSON.DecodingError<CodingKey>.init(
            BSON.TypecastError<Bool>.init(invalid: .null),
            in: .present))
        {
            try self.bson[.present].decode(to: Bool.self)
        }
    }

    @Test
    func KeyInhabited() throws
    {
        #expect(try true == self.bson[.inhabited].decode(to: Bool?.self))
    }

    @Test
    func KeyMatching() throws
    {
        #expect(try true == self.bson[.inhabited].decode())
    }

    @Test
    func KeyNull() throws
    {
        #expect(try nil == self.bson[.present].decode(to: Bool?.self))
    }

    @Test
    func KeyOptional() throws
    {
        #expect(try nil == self.bson[.missing]?.decode(to: Bool.self))
    }

    @Test
    func KeyOptionalNull() throws
    {
        #expect(try .some(nil) == self.bson[.present]?.decode(to: Bool?.self))
    }

    @Test
    func KeyOptionalInhabited() throws
    {
        #expect(try true == self.bson[.inhabited]?.decode(to: Bool?.self))
    }

    @Test
    func KeyOptionalNotInhabited() throws
    {
        #expect(throws:
            BSON.DecodingError<CodingKey>.init(
                BSON.TypecastError<Bool>.init(invalid: .null),
                in: .present))
        {
            try self.bson[.present]?.decode(to: Bool.self)
        }
    }
}
