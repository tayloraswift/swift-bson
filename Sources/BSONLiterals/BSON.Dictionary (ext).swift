import BSONABI

extension BSON.Document:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(BSON.Key, BSON.AnyValue)...)
    {
        self.init(fields: dictionaryLiteral)
    }
}
