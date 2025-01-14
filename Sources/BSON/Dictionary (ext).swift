extension Dictionary:BSONEncodable, BSONDocumentEncodable
    where Key:BSON.Keyspace, Value:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<Key>)
    {
        for (key, value):(Key, Value) in self
        {
            value.encode(to: &bson[key])
        }
    }
}
extension Dictionary:BSONDecodable, BSONKeyspaceDecodable
    where Key:BSON.Keyspace, Value:BSONDecodable
{
    @inlinable public
    init(bson:consuming BSON.KeyspaceDecoder<Key>) throws
    {
        self.init()
        while let field:BSON.FieldDecoder<Key> = try bson[+]
        {
            guard
            case nil = self.updateValue(try field.decode(to: Value.self), forKey: field.key)
            else
            {
                throw BSON.DocumentKeyError<Key>.duplicate(field.key)
            }
        }
    }
}
