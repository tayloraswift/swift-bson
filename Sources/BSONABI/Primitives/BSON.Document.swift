extension BSON
{
    /// The `Document` type models the “universal” BSON DSL.
    ///
    /// It is expected that more-specialized BSON DSLs will wrap an
    /// instance of `Document`.
    @frozen public
    struct Document:Sendable
    {
        public
        var output:BSON.Output

        /// Creates an empty document.
        @inlinable public
        init()
        {
            self.output = .init(preallocated: [])
        }

        /// Stores the argument in ``bytes`` unchanged.
        ///
        /// >   Complexity: O(1)
        @inlinable public
        init(bytes:ArraySlice<UInt8>)
        {
            self.output = .init(preallocated: bytes)
        }
    }
}
extension BSON.Document:BSON.BufferTraversable
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

    /// The raw data backing this document. This slice *does not* include the trailing null byte
    /// that typically appears after its inline field list.
    @inlinable public
    var bytes:ArraySlice<UInt8> { self.output.destination }
}
extension BSON.Document
{
    /// Indicates if this document contains no fields.
    @inlinable public
    var isEmpty:Bool { self.bytes.isEmpty }

    /// The length that would be encoded in this document’s prefixed header.
    /// Equal to ``size``.
    @inlinable public
    var header:Int32 { .init(self.size) }

    /// The size of this document when encoded with its header and trailing
    /// null byte. This *is* the same as the length encoded in the header itself.
    @inlinable public
    var size:Int { 5 + self.bytes.count }

    /// Rebinds the backing storage of this list to a ``BSON.Document``. This will cause the
    /// list to be interpreted as a document with keys numbered from 0 in base-10.
    @inlinable public
    init(list:BSON.List)
    {
        self.init(bytes: list.bytes)
    }

    @inlinable public mutating
    func append(contentsOf other:Self)
    {
        self.output.append(other.bytes)
    }
}
extension BSON.Document
{
    /// Creates a document containing the given fields, making two passes over
    /// the list of fields in order to encode the output without reallocations.
    /// The order of the fields will be preserved.
    @inlinable public
    init(fields:some Collection<(key:BSON.Key, value:BSON.AnyValue)>)
    {
        let size:Int = fields.reduce(0) { $0 + 2 + $1.key.rawValue.utf8.count + $1.value.size }
        var output:BSON.Output = .init(capacity: size)
            output.serialize(fields: fields)

        assert(output.destination.count == size, """
            precomputed size (\(size)) does not match output size (\(output.destination.count))
            """)

        self.init(bytes: output.destination)
    }

    /// Creates a document containing a single key-value pair.
    @inlinable public
    init(key:BSON.Key, value:BSON.AnyValue)
    {
        self.init(
            fields: CollectionOfOne<(key:BSON.Key, value:BSON.AnyValue)>.init((key, value)))
    }
}
extension BSON.Document
{
    @available(*, deprecated, message: "BSON.Document is already a BSON.Document")
    @inlinable public
    init(_ bson:Self)
    {
        self = bson
    }

    @available(*, deprecated, message: "BSON.Document is already a BSON.Document")
    @inlinable public
    init(bson:Self)
    {
        self = bson
    }
}
