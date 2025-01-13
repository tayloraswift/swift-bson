extension BSON
{
    /// A thin wrapper around a native Swift array providing an efficient decoding
    /// interface for a ``BSON/List``.
    @available(*, deprecated, renamed: "ListDecoder_")
    @frozen public
    struct ListDecoder
    {
        public
        var elements:[BSON.AnyValue]

        @inlinable public
        init(_ elements:[BSON.AnyValue])
        {
            self.elements = elements
        }
    }
}
@available(*, deprecated)
extension BSON.ListDecoder:BSON.Decoder
{
    @inlinable public
    init(parsing bson:borrowing BSON.AnyValue) throws
    {
        try self.init(parsing: try .init(bson: copy bson))
    }
}
@available(*, deprecated)
extension BSON.ListDecoder
{
    /// Attempts to create a list decoder from the given list.
    ///
    /// To get a plain array with no decoding interface, call the list’s ``List/parse``
    /// method instead. Alternatively, you can use this function and access the
    /// ``elements`` property afterwards.
    ///
    /// >   Complexity:
    //      O(*n*), where *n* is the number of elements in the source list.
    @inlinable public
    init(parsing bson:borrowing BSON.List) throws
    {
        self.init(try bson.parse())
    }

    /// The shape of the list being decoded.
    @inlinable public
    var shape:BSON.Shape
    {
        .init(length: self.elements.count)
    }
}
@available(*, deprecated)
extension BSON.ListDecoder:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.elements.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.elements.endIndex
    }
    @inlinable public
    subscript(index:Int) -> BSON.FieldDecoder<Int>
    {
        .init(key: index, value: self.elements[index])
    }
}
