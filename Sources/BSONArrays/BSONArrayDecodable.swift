import BSONDecoding

/// A type that can be decoded from a BSON binary array. Not to be confused with
/// ``BSONListDecodable``.
public
protocol BSONArrayDecodable<Element>:BSONBinaryDecodable
{
    associatedtype Element:BSON.BinaryPackable

    /// Initializes an instance of this type from the given binary array, whose shape has been
    /// pre-validated to be a multiple of the ``Element`` storage size.
    init(from array:borrowing BSON.BinaryArray<Element>) throws
}
extension BSONArrayDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        try self.init(from: try .init(bson: bson))
    }
}
