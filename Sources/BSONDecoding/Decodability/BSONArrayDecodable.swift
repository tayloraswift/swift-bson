public
protocol BSONArrayDecodable<CodingElement>:BSONBinaryDecodable
{
    associatedtype CodingElement:BitwiseCopyable

    /// Initializes an instance of this type from the given binary array, whose shape has been
    /// pre-validated to be a multiple of the ``CodingElement`` size.
    init(from array:borrowing BSON.BinaryBuffer<CodingElement>) throws
}
extension BSONArrayDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        try self.init(from: try .init(bson: bson))
    }
}
