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
extension Dictionary.UnorderedItems:BSONEncodable where Value:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.encode(to: &field[as: BSON.DocumentEncoder<Key>.self])
    }

    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<Key>)
    {
        for (key, value):(Key, Value) in self.dictionary
        {
            value.encode(to: &bson[key])
        }
    }
}
extension Dictionary.UnorderedItems:BSONDecodable where Value:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(bson: consume bson))
    }

    @inlinable public
    init(bson:BSON.Document) throws
    {
        var index:[Key: Value] = [:]
        var items:BSON.KeyspaceDecoder<Key> = bson.parsed()
        while let field:BSON.FieldDecoder<Key> = try items[+]
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
