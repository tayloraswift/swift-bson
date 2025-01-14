extension BSON.List:BSONDecodable
{
    /// Attempts to unwrap a list from the given variant.
    ///
    /// This method will only attempt to parse statically-typed BSON lists; it will not
    /// inspect general documents to determine if they are valid lists.
    ///
    /// -   Returns:
    ///     The payload of the variant, if it matches ``AnyValue/list(_:) [case]``, nil
    ///     otherwise.
    ///
    /// >   Complexity:
    //      O(1)
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast(with: \.list)
    }
}
extension BSON.List
{
    @inlinable
    var values:Iterator { .init(input: .init(self.bytes)) }

    @inlinable public
    var parsed:BSON.ListDecoder_ { .init(input: self.values) }

    /// Splits this list’s inline key-value pairs into an array containing the
    /// values only. Parsing a list is slightly faster than parsing a general
    /// ``Document``, because this method ignores the document keys.
    ///
    /// This method does *not* perform any key validation.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this list’s backing storage.
    @inlinable package
    func parseAll() throws -> [BSON.AnyValue]
    {
        var parsed:[BSON.AnyValue] = []
        var values:Iterator = self.values
        while let next:BSON.AnyValue = try values.next()
        {
            parsed.append(next)
        }
        return parsed
    }
}
