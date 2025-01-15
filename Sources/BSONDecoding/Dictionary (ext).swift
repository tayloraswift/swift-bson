import BSONABI

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
