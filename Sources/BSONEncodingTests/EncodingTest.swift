import BSON
import Testing

protocol EncodingTest
{
}
extension EncodingTest
{
    static func validate(encoded:BSON.Document, literal:BSON.Document) throws
    {
        #expect(encoded.bytes == literal.bytes)
    }
}
