extension BSON
{
    /// A field that is already known to exist in a document. This type is the return value of
    /// ``DocumentDecoder``’s optional subscript.
    ///
    /// Compare with: ``FieldAccessor``.
    @frozen public
    struct FieldDecoder<Key> where Key:Sendable
    {
        public
        let key:Key
        public
        let value:BSON.AnyValue

        @inlinable public
        init(key:Key, value:BSON.AnyValue)
        {
            self.key = key
            self.value = value
        }
    }
}
extension BSON.FieldDecoder:BSON.TracingDecoder
{
    /// Decodes the value of this field with the given decoder.
    /// Throws a ``BSON/DecodingError`` wrapping the underlying
    /// error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(BSON.AnyValue) throws -> T) throws -> T
    {
        do
        {
            return try decode(self.value)
        }
        catch let error
        {
            throw BSON.DecodingError.init(error, in: self.key)
        }
    }
}
