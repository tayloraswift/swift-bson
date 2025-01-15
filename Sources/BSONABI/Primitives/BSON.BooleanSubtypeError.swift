extension BSON
{
    /// A byte encoding a boolean value was not 0 or 1.
    @frozen public
    struct BooleanSubtypeError:Equatable, Error
    {
        public
        let code:UInt8

        @inlinable public
        init(invalid code:UInt8)
        {
            self.code = code
        }
    }
}
