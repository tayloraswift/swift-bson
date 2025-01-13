import BSONABI

/// A type that can be decoded from a BSON list-decoder. You should only conform to this
/// protocol if you need random-access decoding. Many arraylike data structures are
/// more-efficiently decoded from a ``BSON.List`` at the ``BSONDecodable`` level.
public
protocol BSONListDecodable_:BSONDecodable
{
    init(bson:consuming BSON.ListDecoder_) throws
}
extension BSONListDecodable_
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
extension BSONListDecodable_ where Self:RangeReplaceableCollection, Self.Element:BSONDecodable
{
    @inlinable public
    init(bson:consuming BSON.ListDecoder_) throws
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
