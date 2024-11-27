import BSONDecoding
import BSONEncoding

extension BSON
{
    @frozen public
    struct _BinaryArray<Element>:Sendable where Element:BinaryPackable
    {
        @usableFromInline
        var array:BSON.BinaryBuffer<Element.Storage>

        init(array:BSON.BinaryBuffer<Element.Storage>)
        {
            self.array = array
        }
    }
}
extension BSON._BinaryArray:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { self.array.startIndex }

    @inlinable public
    var endIndex:Int { self.array.endIndex }

    @inlinable public
    subscript(position:Int) -> Element
    {
        get { .get(self.array[position]) }
        set(new) { self.array[position] = new.set() }
    }
}
extension BSON._BinaryArray:BSONBinaryEncodable
{
    public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        self.array.encode(to: &bson)
    }
}
extension BSON._BinaryArray:BSONBinaryDecodable
{
    public
    init(bson:BSON.BinaryDecoder) throws
    {
        self.init(array: try .init(bson: bson))
    }
}
