extension BSON.BinaryArray:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        try self.init(bytes: bson.bytes)
    }
}
