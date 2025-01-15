extension BSON
{
    /// A binary array had an invalid number of bytes.
    @frozen public
    struct BinaryShapeError:Equatable, Error
    {
        public
        let bytes:Int
        public
        let expected:Criteria?

        @inlinable public
        init(invalid:Int, expected:Criteria? = nil)
        {
            self.bytes = invalid
            self.expected = expected
        }
    }
}
extension BSON.BinaryShapeError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self.expected
        {
        case nil:
            "Invalid size (\(self.bytes))."

        case .size(let bytes)?:
            "Invalid size (\(self.bytes)), expected \(bytes) bytes."

        case .stride(of: let stride)?:
            "Invalid size (\(self.bytes)), expected multiple of \(stride)."
        }
    }
}
