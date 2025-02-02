extension BSON
{
    @frozen public
    struct DocumentEncoder<CodingKey> where CodingKey:RawRepresentable<String>
    {
        @usableFromInline
        var output:BSON.Output

        @inlinable public
        init(_ output:BSON.Output)
        {
            self.output = output
        }
    }
}
extension BSON.DocumentEncoder:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output { self.output }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}
extension BSON.DocumentEncoder
{
    /// Creates a field context with the given native key.
    @inlinable public
    subscript(key:CodingKey) -> BSON.FieldEncoder
    {
        _read   { yield  self.output[with: .init(key)] }
        _modify { yield &self.output[with: .init(key)] }
    }

    /// Creates a field context with the given generic key. We typically use this a layering
    /// shim, when using ``DocumentEncoder`` as the backend for a higher-level DSL encoder.
    @inlinable public
    subscript(with key:some RawRepresentable<String>) -> BSON.FieldEncoder
    {
        _read   { yield  self.output[with: .init(key)] }
        _modify { yield &self.output[with: .init(key)] }
    }
}
extension BSON.DocumentEncoder
{
    /// Appends the given key-value pair to this document builder, encoding the
    /// value as the field value using its ``BSONEncodable`` implementation.
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns nil.
    ///
    /// Every non-nil assignment to this subscript (including mutations
    /// that leave the value in a non-nil state after returning) will add
    /// a new field to the document, even if the key is the same.
    @inlinable public
    subscript<Value>(key:CodingKey) -> Value? where Value:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[with: key]) }
    }
}
