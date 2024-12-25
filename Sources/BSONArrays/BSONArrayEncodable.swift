import BSONEncoding

/// A type that can be encoded to a BSON binary array. Not to be confused with
/// ``BSONListEncodable``.
public
protocol BSONArrayEncodable<Element>:BSONBinaryEncodable
{
    associatedtype Element:BSON.BinaryPackable
}
extension BSONArrayEncodable where Self:RandomAccessCollection<Element>
{
    /// Encodes the elements of this collection to the binary encoder by densely copying each
    /// element’s raw memory representation, without any padding.
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.reserve(another: self.count * MemoryLayout<Element.Storage>.size)

        for element:Element in self
        {
            withUnsafeBytes(of: element.set()) { bson += $0 }
        }
    }
}
