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

        let encoded:[(key:BSON.Key, value:BSON.AnyValue)] = try encoded.parse { ($0, $1) }
        let literal:[(key:BSON.Key, value:BSON.AnyValue)] = try literal.parse { ($0, $1) }

        #expect(encoded.map(\.key)   == literal.map(\.key))
        #expect(encoded.map(\.value) == literal.map(\.value))
    }
}
