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
