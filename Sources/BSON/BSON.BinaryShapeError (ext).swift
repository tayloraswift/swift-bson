extension BSON.BinaryShapeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self.expected
        {
        case nil:
            "invalid size (\(self.bytes))"

        case .size(let bytes)?:
            "invalid size (\(self.bytes)), expected \(bytes) bytes"

        case .stride(of: let stride)?:
            "invalid size (\(self.bytes)), expected multiple of \(stride)"
        }
    }
}
