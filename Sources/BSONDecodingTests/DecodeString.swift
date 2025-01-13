import BSON
import Testing

@Suite
struct DecodeString
{
    enum CodingKey:String
    {
        case string
        case character
        case codepoint
    }

    private
    let bson:BSON.DocumentDecoder<CodingKey>

    init() throws
    {
        let bson:BSON.Document = .init(CodingKey.self)
        {
            $0[.string] = "e\u{0301}e\u{0301}"
            $0[.character] = "e\u{0301}" as Character
            $0[.codepoint] = "e" as Unicode.Scalar
        }

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeString
{
    @Test
    func UnicodeScalarFromString() throws
    {
        #expect(throws: BSON.DecodingError<CodingKey>.init(
            BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}e\u{0301}"),
            in: .string))
        {
            try self.bson[.string].decode(to: Unicode.Scalar.self)
        }
    }

    @Test
    func UnicodeScalarFromCharacter() throws
    {
        #expect(throws: BSON.DecodingError<CodingKey>.init(
            BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}"),
            in: .character))
        {
            try self.bson[.character].decode(to: Unicode.Scalar.self)
        }
    }

    @Test
    func UnicodeScalarFromUnicodeScalar() throws
    {
        #expect(try "e" == self.bson[.codepoint].decode(to: Unicode.Scalar.self))
    }

    @Test
    func CharacterFromString() throws
    {
        #expect(throws: BSON.DecodingError<CodingKey>.init(
            BSON.ValueError<String, Character>.init(invalid: "e\u{0301}e\u{0301}"),
            in: .string))
        {
            try self.bson[.string].decode(to: Character.self)
        }
    }

    @Test
    func CharacterFromCharacter() throws
    {
        #expect(try "e\u{0301}" == self.bson[.character].decode(to: Character.self))
    }

    @Test
    func StringFromString() throws
    {
        #expect(try "e\u{0301}e\u{0301}" == self.bson[.string].decode(to: String.self))
    }
}
