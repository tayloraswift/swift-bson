import BSON
import Testing

protocol EncodingTest
{
}
extension EncodingTest
{
    static func validate(encoded:BSON.Document, literal:BSON.Document) throws
    {
        #expect(encoded == literal)

        let encoded:[BSON.FieldDecoder<BSON.Key>] = try encoded.parseAll()
        let literal:[BSON.FieldDecoder<BSON.Key>] = try literal.parseAll()

        #expect(encoded.map(\.key)   == literal.map(\.key))
        #expect(encoded.map(\.value) == literal.map(\.value))
    }
}
