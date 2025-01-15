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
