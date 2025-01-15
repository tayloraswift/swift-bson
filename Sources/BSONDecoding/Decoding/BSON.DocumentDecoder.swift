import BSONABI

extension BSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a ``BSON/Document``.
    @frozen public
    struct DocumentDecoder<CodingKey>
        where   CodingKey:RawRepresentable<String>,
                CodingKey:Hashable,
                CodingKey:Sendable
    {
        @usableFromInline
        var index:[CodingKey: BSON.AnyValue]

        @inlinable public
        init(_ index:[CodingKey: BSON.AnyValue] = [:])
        {
            self.index = index
        }
    }
}
extension BSON.DocumentDecoder:BSON.Decoder
{
    /// Attempts to load a document decoder from the given variant.
    ///
    /// - Returns:
    ///     A document decoder derived from the payload of this variant if it matches
    ///     ``AnyValue/document(_:) [case]`` **or** ``AnyValue/list(_:) [case]``, nil otherwise.
    @inlinable public
    init(parsing bson:borrowing BSON.AnyValue) throws
    {
        try self.init(parsing: try .init(bson: copy bson))
    }
}
extension BSON.DocumentDecoder
{
    /// Attempts to create a decoder with typed coding keys from this document.
    ///
    /// This function will ignore fields whose keys do not correspond to valid
    /// instances of `CodingKey`. It will throw a ``DocumentKeyError`` if more
    /// than one non-ignored document field contains the same key.
    ///
    /// If `CodingKey` is ``Key``, this function will never ignore fields.
    ///
    /// Key duplication can interact with unicode normalization in unexpected
    /// ways. Because BSON is defined in UTF-8, other BSON encoders may not align
    /// with the behavior of ``String.==(_:_:) [9812Z]``, since that operator
    /// compares grapheme clusters and not UTF-8 code units.
    ///
    /// For example, if a document vends separate keys for `"\u{E9}" (`"é") and
    /// `"\u{65}\u{301}" (also `"é"`, perhaps, because the document is
    /// being used to bootstrap a unicode table), uniquing them by ``String``
    /// comparison would drop one of the values.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the number of fields in the source document.
    ///
    /// >   Warning:
    ///     When you convert an object to a dictionary representation, you lose the ordering
    ///     information for the object items. Re-encoding it may produce a BSON
    ///     document that contains the same data, but does not compare equal.
    @inlinable public
    init(parsing bson:borrowing BSON.Document) throws
    {
        try self.init(bson: bson.items)
    }

    @inlinable
    init(bson:consuming BSON.Document.Iterator) throws
    {
        self.init()
        while let (key, value):(String, BSON.AnyValue) = try bson.next()
        {
            guard
            let key:CodingKey = .init(rawValue: key)
            else
            {
                //  The difference between `DocumentDecoder` and something that could conform
                //  to ``BSONKeyspaceDecodable`` is `DocumentDecoder` ignores keys that it does
                //  not understand. This is a feature, not a bug.
                continue
            }

            if  case _? = self.index.updateValue(value, forKey: key)
            {
                throw BSON.DocumentKeyError<CodingKey>.duplicate(key)
            }
        }
    }
}
extension BSON.DocumentDecoder
{
    @inlinable public
    func contains(_ key:CodingKey) -> Bool
    {
        self.index.keys.contains(key)
    }

    /// Returns a dictionary of all the indexed fields in the original document. It does not
    /// include fields that were ignored per the schema definition.
    ///
    /// Iterating ``DocumentDecoder`` is an anti-pattern, and should only be used for debugging
    /// and reflection. The order of the fields in the dictionary is not stable, and
    /// constructing the dictionary is more expensive than iterating a type designed for
    /// sequential consumption, like ``BSON.KeyspaceDecoder``, which does not allocate storage.
    @inlinable public
    var indexedFields:[CodingKey: BSON.AnyValue] { self.index }

    @inlinable public
    var single:BSON.FieldDecoder<CodingKey>
    {
        consuming get throws
        {
            var single:BSON.FieldDecoder<CodingKey>? = nil
            for (key, value):(CodingKey, BSON.AnyValue) in self.index
            {
                if  case nil = single
                {
                    single = .init(key: key, value: value)
                }
                else
                {
                    throw BSON.SingleKeyError<CodingKey>.multiple
                }
            }
            guard let single
            else
            {
                throw BSON.SingleKeyError<CodingKey>.none
            }
            return single
        }
    }

    @inlinable public
    subscript(key:CodingKey) -> BSON.FieldAccessor<CodingKey>
    {
        .init(key: key, value: self.index[key])
    }
    @inlinable public
    subscript(key:CodingKey) -> BSON.FieldDecoder<CodingKey>?
    {
        self.index[key].map { .init(key: key, value: $0) }
    }
}
