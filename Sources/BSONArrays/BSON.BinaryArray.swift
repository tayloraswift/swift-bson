import BSONDecoding
import BSONEncoding

extension BSON
{
    @frozen public
    struct BinaryArray<Element>:Sendable where Element:BinaryPackable
    {
        @usableFromInline
        var buffer:BSON.BinaryBuffer<Element.Storage>

        @inlinable
        init(buffer:BSON.BinaryBuffer<Element.Storage>)
        {
            self.buffer = buffer
        }
    }
}
extension BSON.BinaryArray:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Never...)
    {
        self.init(buffer: [])
    }
}
extension BSON.BinaryArray
{
    @inlinable public
    init(count:Int)
    {
        self.init(buffer: .init(count: count))
    }
}
extension BSON.BinaryArray:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { self.buffer.startIndex }

    @inlinable public
    var endIndex:Int { self.buffer.endIndex }

    @inlinable public
    subscript(position:Int) -> Element
    {
        get { .get(self.buffer[position]) }
        set(new) { self.buffer[position] = new.set() }
    }
}
extension BSON.BinaryArray:BSONBinaryEncodable
{
    public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        self.buffer.encode(to: &bson)
    }
}
extension BSON.BinaryArray:BSONBinaryDecodable
{
    public
    init(bson:BSON.BinaryDecoder) throws
    {
        self.init(buffer: try .init(bson: bson))
    }
}
