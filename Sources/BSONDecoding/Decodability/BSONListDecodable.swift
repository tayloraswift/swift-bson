import BSONABI

/// A type that can be decoded from a BSON ``BSON.ListDecoder``.
public
protocol BSONListDecodable:BSONDecodable
{
    init(bson:consuming BSON.ListDecoder) throws
}
extension BSONListDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try BSON.List.init(bson: bson))
    }

    @inlinable public
    init(bson:BSON.List) throws
    {
        try self.init(bson: bson.parsed)
    }
}
extension BSONListDecodable where Self:RangeReplaceableCollection, Self.Element:BSONDecodable
{
    @inlinable public
    init(bson:consuming BSON.ListDecoder) throws
    {
        self.init()
        //  The explicit type `Element.self` (instead of `Element?.self`) guards against the
        //  rare scenario where a BSON list contains an interior `null` value.
        while let next:Element = try bson[+]?.decode(to: Element.self)
        {
            self.append(next)
        }
    }
}
