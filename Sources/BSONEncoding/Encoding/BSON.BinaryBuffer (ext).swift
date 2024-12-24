extension BSON.BinaryBuffer:BSONBinaryEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.reserve(another: self.bytes.count)
        bson += self.bytes
    }
}
