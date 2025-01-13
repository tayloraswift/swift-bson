/// A type that can be decoded from a ``BSON.KeyspaceDecoder``.
public
protocol BSONKeyspaceDecodable<CodingKey>:BSONDecodable
{
    associatedtype CodingKey:RawRepresentable<String> & Sendable = BSON.Key

    init(bson:consuming BSON.KeyspaceDecoder<CodingKey>) throws
}
extension BSONKeyspaceDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        let bson:BSON.Document = try .init(bson: bson)
        try self.init(bson: bson.parsed(CodingKey.self))
    }

    @inlinable public
    init(bson:BSON.Document) throws
    {
        try self.init(bson: bson.parsed(CodingKey.self))
    }
}
