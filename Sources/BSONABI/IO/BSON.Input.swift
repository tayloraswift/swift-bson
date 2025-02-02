import UnixTime

extension BSON
{
    /// A type for managing BSON parsing state. Most users of this library
    /// should not need to interact with it directly.
    @frozen public
    struct Input:Sendable
    {
        @usableFromInline
        let bytes:ArraySlice<UInt8>
        @usableFromInline
        var index:Int

        /// Creates a parsing input view over the given `source` data,
        /// and initializes its `index` to the start index of the `source`.
        @inlinable public
        init(_ source:ArraySlice<UInt8>)
        {
            self.bytes = source
            self.index = self.bytes.startIndex
        }
    }
}
extension BSON.Input
{
    /// Consumes and returns a single byte from this parsing input.
    @inlinable public mutating
    func next() -> UInt8?
    {
        guard self.index < self.bytes.endIndex
        else
        {
            return nil
        }
        defer
        {
            self.bytes.formIndex(after: &self.index)
        }

        return self.bytes[self.index]
    }
    /// Advances the current index until encountering the specified `byte`.
    /// After this method returns, `index` points to the byte after
    /// the matched byte.
    ///
    /// -   Returns:
    ///         A range covering the bytes skipped. The upper-bound of
    ///         the range points to the matched byte.
    @discardableResult
    @inlinable public mutating
    func parse(through byte:UInt8) throws -> Range<Int>
    {
        let start:Int = self.index
        while self.index < self.bytes.endIndex
        {
            defer
            {
                self.bytes.formIndex(after: &self.index)
            }
            if  self.bytes[self.index] == byte
            {
                return start ..< self.index
            }
        }
        throw BSON.InputError.init(expected: .byte(byte))
    }
    /// Parses a null-terminated string.
    @inlinable public mutating
    func parse(as _:String.Type = String.self) throws -> String
    {
        .init(decoding: self.bytes[try self.parse(through: 0x00)], as: Unicode.UTF8.self)
    }
    /// Parses a MongoDB object identifier.
    @inlinable public mutating
    func parse(as _:BSON.Identifier.Type = BSON.Identifier.self) throws -> BSON.Identifier
    {
        let start:Int = self.index
        if  let end:Int = self.bytes.index(self.index, offsetBy: 12,
                limitedBy: self.bytes.endIndex)
        {
            self.index = end
            return .init { $0.copyBytes(from: self.bytes[start ..< end]) }
        }
        else
        {
            throw self.expected(.bytes(12))
        }
    }
    /// Parses a boolean.
    @inlinable public mutating
    func parse(as _:Bool.Type = Bool.self) throws -> Bool
    {
        switch self.next()
        {
        case 0?:
            return false
        case 1?:
            return true
        case let code?:
            throw BSON.BooleanSubtypeError.init(invalid: code)
        case nil:
            throw BSON.InputError.init(expected: .bytes(1))
        }
    }
    @inlinable public mutating
    func parse(as _:BSON.Decimal128.Type = BSON.Decimal128.self) throws -> BSON.Decimal128
    {
        let low:UInt64 = try self.parse(as: UInt64.self)
        let high:UInt64 = try self.parse(as: UInt64.self)
        return .init(high: high, low: low)
    }
    @inlinable public mutating
    func parse(as _:UnixMillisecond.Type = UnixMillisecond.self) throws -> UnixMillisecond
    {
        .init(index: try self.parse(as: Int64.self))
    }
    @inlinable public mutating
    func parse(as _:BSON.Regex.Type = BSON.Regex.self) throws -> BSON.Regex
    {
        let pattern:String = try self.parse(as: String.self)
        let options:String = try self.parse(as: String.self)
        return try .init(pattern: pattern, options: options)
    }
    /// Parses a little-endian integer.
    @inlinable public mutating
    func parse<LittleEndian>(as _:LittleEndian.Type = LittleEndian.self) throws -> LittleEndian
        where LittleEndian:FixedWidthInteger
    {
        let start:Int = self.index
        if  let end:Int = self.bytes.index(self.index,
                offsetBy: MemoryLayout<LittleEndian>.size,
                limitedBy: self.bytes.endIndex)
        {
            self.index = end
            return withUnsafeTemporaryAllocation(
                byteCount: MemoryLayout<LittleEndian>.size,
                alignment: MemoryLayout<LittleEndian>.alignment)
            {
                $0.copyBytes(from: self.bytes[start ..< end])
                return .init(littleEndian: $0.load(as: LittleEndian.self))
            }
        }
        else
        {
            throw self.expected(.bytes(MemoryLayout<LittleEndian>.size))
        }
    }

    @inlinable public mutating
    func parse<Frame>(_:Frame.Type) throws -> ArraySlice<UInt8>
        where Frame:BSON.BufferFrameType
    {
        let header:Int = .init(try self.parse(as: Int32.self))
        let stride:Int = header + Frame.skipped
        let count:Int = stride - Frame.suffix
        if  count < 0
        {
            throw BSON.HeaderError<Frame>.init(length: header)
        }
        let start:Int = self.index
        if  let end:Int = self.bytes.index(start, offsetBy: stride,
                limitedBy: self.bytes.endIndex)
        {
            self.index = end
            return self.bytes[start ..< self.bytes.index(start, offsetBy: count)]
        }
        else
        {
            throw self.expected(.bytes(stride))
        }
    }

    /// Parses a traversable BSON element. The output is typically opaque,
    /// which allows decoders to skip over regions of a BSON document.
    @inlinable public mutating
    func parse<View>(as _:View.Type = View.self) throws -> View
        where View:BSON.BufferTraversable
    {
        try .init(slicing: try self.parse(View.Frame.self))
    }

    /// Returns a slice of the input from the current `index` to the end
    /// of the input. Accessing this property does not affect the current
    /// `index`.
    @inlinable public
    var remaining:ArraySlice<UInt8>
    {
        self.bytes.suffix(from: self.index)
    }

    /// Asserts that there is no input remaining.
    @inlinable public
    func finish() throws
    {
        if self.index != self.bytes.endIndex
        {
            throw self.expected(.end)
        }
    }

    /// Creates an ``InputError`` with appropriate context for the specified expectation.
    @inlinable public
    func expected(_ expectation:BSON.InputError.Expectation) -> BSON.InputError
    {
        .init(expected: expectation,
            encountered: self.bytes.distance(from: self.index, to: self.bytes.endIndex))
    }
}

extension BSON.Input
{
    /// Parses a variant BSON value, assuming it is of the specified `variant` type.
    @inlinable public mutating
    func parse(variant:BSON.AnyType) throws -> BSON.AnyValue
    {
        switch variant
        {
        case .double:
            return .double(.init(bitPattern: try self.parse(as: UInt64.self)))

        case .string:
            return .string(try self.parse(as: BSON.UTF8View<ArraySlice<UInt8>>.self))

        case .document:
            return .document(try self.parse(as: BSON.Document.self))

        case .list:
            return .list(try self.parse(as: BSON.List.self))

        case .binary:
            return .binary(try self.parse(as: BSON.BinaryView<ArraySlice<UInt8>>.self))

        case .null:
            return .null

        case .id:
            return .id(try self.parse(as: BSON.Identifier.self))

        case .bool:
            return .bool(try self.parse(as: Bool.self))

        case .millisecond:
            return .millisecond(try self.parse(as: UnixMillisecond.self))

        case .regex:
            return .regex(try self.parse(as: BSON.Regex.self))

        case .pointer:
            let database:BSON.UTF8View<ArraySlice<UInt8>> = try self.parse(
                as: BSON.UTF8View<ArraySlice<UInt8>>.self)
            let object:BSON.Identifier = try self.parse(
                as: BSON.Identifier.self)
            return .pointer(database, object)

        case .javascript:
            return .javascript(try self.parse(as: BSON.UTF8View<ArraySlice<UInt8>>.self))

        case .javascriptScope:
            // possible micro-optimization here
            let _:Int32 = try self.parse(as: Int32.self)
            let code:BSON.UTF8View<ArraySlice<UInt8>> = try self.parse(
                as: BSON.UTF8View<ArraySlice<UInt8>>.self)
            let scope:BSON.Document = try self.parse(
                as: BSON.Document.self)
            return .javascriptScope(scope, code)

        case .int32:
            return .int32(try self.parse(as: Int32.self))

        case .timestamp:
            return .timestamp(.init(try self.parse(as: UInt64.self)))

        case .int64:
            return .int64(try self.parse(as: Int64.self))

        case .decimal128:
            return .decimal128(try self.parse(as: BSON.Decimal128.self))

        case .max:
            return .max
        case .min:
            return .min
        }
    }
}
