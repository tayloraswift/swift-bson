extension BSON
{
    /// A field that may or may not exist in a document. This type is the return value of
    /// ``DocumentDecoder``’s non-optional subscript, and is useful for obtaining structured
    /// diagnostics for “key-not-found” scenarios.
    ///
    /// The name `OptionalDecoder` is counterintuitive because you would almost always use this
    /// type to access fields that you expect to be present. It is named as such because it does
    /// *not* unwrap the value (it contains an ``Optional``), leaving the nil state available
    /// for raising diagnostics.
    ///
    /// Compare with: ``FieldDecoder``.
    @frozen public
    struct OptionalDecoder<Key> where Key:Sendable
    {
        public
        let key:Key
        public
        let value:BSON.AnyValue?

        @inlinable public
        init(key:Key, value:BSON.AnyValue?)
        {
            self.key = key
            self.value = value
        }
    }
}
extension BSON.OptionalDecoder
{
    @inlinable public static
    func ?? (lhs:Self, rhs:@autoclosure () -> Self) -> Self
    {
        if case nil = lhs.value
        {
            rhs()
        }
        else
        {
            lhs
        }
    }
}
extension BSON.OptionalDecoder
{
    /// Gets the value of this key, throwing a ``BSON.DocumentKeyError``
    /// if it is nil. This is a distinct condition from an explicit
    /// ``BSON/AnyValue/null`` value, which will be returned without throwing an error.
    @inlinable public
    func decode() throws -> BSON.AnyValue
    {
        if  let value:BSON.AnyValue = self.value
        {
            return value
        }
        else
        {
            throw BSON.DocumentKeyError<Key>.undefined(self.key)
        }
    }
}
extension BSON.OptionalDecoder:BSON.TraceableDecoder
{
    /// Decodes the value of this implicit field with the given decoder, throwing a
    /// ``BSON.DocumentKeyError`` if it does not exist. Throws a
    /// ``BSON.DecodingError`` wrapping the underlying error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(BSON.AnyValue) throws -> T) throws -> T
    {
        // we cannot *quite* shove this into the `do` block, because we
        // do not want to throw a ``DecodingError`` just because the key
        // was not found.
        let value:BSON.AnyValue = try self.decode()
        do
        {
            return try decode(value)
        }
        catch let error
        {
            throw BSON.DecodingError.init(error, in: key)
        }
    }
}
