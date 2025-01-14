extension Dictionary
{
    @frozen public
    struct UnorderedItems where Key:BSON.Keyspace
    {
        public
        let dictionary:[Key: Value]

        @inlinable
        init(dictionary:[Key: Value])
        {
            self.dictionary = dictionary
        }
    }
}
extension Dictionary.UnorderedItems:BSONEncodable, BSONDocumentEncodable
    where Value:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<Key>)
    {
        for (key, value):(Key, Value) in self.dictionary
        {
            value.encode(to: &bson[key])
        }
    }
}
extension Dictionary.UnorderedItems:BSONDecodable, BSONKeyspaceDecodable
    where Value:BSONDecodable
{
    @inlinable public
    init(bson:consuming BSON.KeyspaceDecoder<Key>) throws
    {
        var index:[Key: Value] = [:]
        while let field:BSON.FieldDecoder<Key> = try bson[+]
        {
            guard
            case nil = index.updateValue(try field.decode(to: Value.self), forKey: field.key)
            else
            {
                throw BSON.DocumentKeyError<Key>.duplicate(field.key)
            }
        }

        self.init(dictionary: index)
    }
}
