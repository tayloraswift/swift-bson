extension BSON
{
    @frozen public
    struct List:Sendable
    {
        public
        var output:BSON.Output

        /// Creates an empty list.
        @inlinable public
        init()
        {
            self.output = .init(preallocated: [])
        }
        @inlinable public
        init(bytes:ArraySlice<UInt8>)
        {
            self.output = .init(preallocated: bytes)
        }
    }
}
extension BSON.List:BSON.BufferTraversable
{
    public
    typealias Frame = BSON.DocumentFrame

    /// Stores the argument in ``bytes`` unchanged. Equivalent to ``init(bytes:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:ArraySlice<UInt8>)
    {
        self.init(bytes: bytes)
    }

    /// The raw data backing this list. This collection *does not* include the trailing null
    /// byte that appears after its inline elements list.
    @inlinable public
    var bytes:ArraySlice<UInt8> { self.output.bytes }
}
extension BSON.List
{
    /// Indicates if this list contains no elements.
    @inlinable public
    var isEmpty:Bool { self.bytes.isEmpty }

    /// The length that would be encoded in this list’s prefixed header.
    /// Equal to ``size``.
    @inlinable public
    var header:Int32 { .init(self.size) }

    /// The size of this list when encoded with its header and trailing
    /// null byte. This *is* the same as the length encoded in the header
    /// itself.
    @inlinable public
    var size:Int { 5 + self.bytes.count }
}
extension BSON.List
{
    /// Creates a list-document containing the given elements.
    @inlinable public
    init(elements:some Sequence<BSON.AnyValue>)
    {
        // we do need to precompute the ordinal keys, so we know the total length
        // of the document.
        let document:BSON.Document = .init(fields: elements.enumerated().map
        {
            (.init(index: $0.0), $0.1)
        })
        self.init(bytes: document.bytes)
    }
}
extension BSON.List
{
    @available(*, deprecated, message: "BSON.List is already a BSON.List")
    @inlinable public
    init(_ bson:Self)
    {
        self = bson
    }

    @available(*, deprecated, message: "BSON.List is already a BSON.List")
    @inlinable public
    init(bson:Self)
    {
        self = bson
    }
}
