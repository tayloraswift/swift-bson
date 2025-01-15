import BSONABI

extension Set:BSONDecodable, BSONListDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:consuming BSON.ListDecoder) throws
    {
        self.init()
        //  The explicit type `Element.self` (instead of `Element?.self`) guards against the
        //  rare scenario where a BSON list contains an interior `null` value.
        while let element:Element = try bson[+]?.decode(to: Element.self)
        {
            self.update(with: element)
        }
    }
}
