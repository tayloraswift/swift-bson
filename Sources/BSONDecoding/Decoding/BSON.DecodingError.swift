extension BSON
{
    /// An error occurred while decoding a document field.
    @frozen public
    struct DecodingError<Location>:Error where Location:Sendable
    {
        /// The location (key or index) where the error occurred.
        public
        let location:Location
        /// The underlying error that occurred.
        public
        let underlying:any Error

        @inlinable public
        init(_ underlying:any Error, in location:Location)
        {
            self.location = location
            self.underlying = underlying
        }
    }
}
