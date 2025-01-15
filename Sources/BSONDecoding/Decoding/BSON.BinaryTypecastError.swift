extension BSON
{
    /// A list had an invalid number of elements.
    @frozen public
    struct BinaryTypecastError:Equatable, Error
    {
        public
        let subtype:BinarySubtype
        public
        let expected:BinarySubtype?

        @inlinable public
        init(invalid:BinarySubtype, expected:BinarySubtype? = nil)
        {
            self.subtype = invalid
            self.expected = expected
        }
    }
}
