extension BSON
{
    /// A `BinaryBuffer` is a typed view of an ``ArraySlice`` as a densely-packed buffer of
    /// trivial `Element`s. It’s a good idea to use something unpretentious like a tuple of
    /// fixed-width integers for the `Element` type, to avoid unexpected padding behavior.
    @frozen public
    struct BinaryBuffer<Element> where Element:BitwiseCopyable
    {
        @usableFromInline package
        var bytes:ArraySlice<UInt8>
        public
        let count:Int

        @inlinable
        init(bytes:ArraySlice<UInt8>, count:Int)
        {
            self.bytes = bytes
            self.count = count
        }
    }
}
extension BSON.BinaryBuffer
{
    /// Binds a raw buffer to a ``BinaryBuffer``, computing the element ``count`` from the
    /// buffer length.
    @inlinable public
    init(bytes:ArraySlice<UInt8>) throws
    {
        let shape:BSON.BinaryShape = .init(bytes: bytes.count)
        let count:Int = try shape.expect(multipleOf: MemoryLayout<Element>.size)
        self.init(bytes: bytes, count: count)
    }

    /// Allocates a ``BinaryBuffer`` of a given element count, initializing the storage to zero.
    @inlinable public
    init(count:Int)
    {
        self.init(
            bytes: .init(repeating: 0, count: count * MemoryLayout<Element>.size),
            count: count)
    }
}
extension BSON.BinaryBuffer:ExpressibleByArrayLiteral
{
    /// Creates an empty binary array.
    @inlinable public
    init(arrayLiteral:Never...) { self.init(count: 0) }
}
extension BSON.BinaryBuffer:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { 0 }

    @inlinable public
    var endIndex:Int { self.count }

    /// Accesses the element at the specified position.
    ///
    /// In any large MongoDB deployment, you should assume that your schema will be loaded and
    /// saved from machines with different endianness.
    ///
    /// This means that if the `Element` type is (or contains) an integer larger than a byte,
    /// you should explicitly specify the endianness when getting or setting through the
    /// subscript.
    ///
    /// For example, if you are coding with a tuple `(UInt32, UInt16)`, you should load the
    /// logical values as `(x, y) = (UInt32.init(bigEndian: $0), UInt16.init(bigEndian: $1))`
    /// and store them as `($0, $1) = (x.bigEndian, y.bigEndian)`.
    @inlinable public
    subscript(position:Int) -> Element
    {
        get
        {
            precondition(self.indices ~= position, "Index out of bounds")

            return self.bytes.withUnsafeBytes
            {
                $0.loadUnaligned(
                    fromByteOffset: position * MemoryLayout<Element>.size,
                    as: Element.self)
            }
        }
        set(value)
        {
            precondition(self.indices ~= position, "Index out of bounds")

            self.bytes.withUnsafeMutableBytes
            {
                $0.storeBytes(of: value,
                    toByteOffset: position * MemoryLayout<Element>.size,
                    as: Element.self)
            }
        }
    }
}
