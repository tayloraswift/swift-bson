extension Substring:BSONStringDecodable
{
    /// Copies and validates the backing storage of the given UTF-8 string to a native Swift
    /// substring, repairing invalid code units if needed.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the string.
    @inlinable public
    init(bson:BSON.UTF8View<ArraySlice<UInt8>>)
    {
        self.init(decoding: bson.bytes, as: Unicode.UTF8.self)
    }
}
