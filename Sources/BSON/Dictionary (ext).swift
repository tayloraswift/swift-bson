extension Dictionary where Key:BSON.Keyspace
{
    @inlinable public
    var unordered:UnorderedItems { .init(dictionary: self) }
}
