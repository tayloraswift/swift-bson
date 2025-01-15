import BSONABI

extension Set:BSONEncodable, BSONListEncodable where Element:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.ListEncoder)
    {
        for element:Element in self
        {
            element.encode(to: &bson[+])
        }
    }
}
