import BSONABI

extension BSON.Document:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast(with: \.document)
    }
}
extension BSON.Document
{
    @inlinable
    var items:Iterator { .init(input: .init(self.bytes)) }

    @inlinable public
    func parsed<Key>(_:Key.Type = Key.self) -> BSON.KeyspaceDecoder<Key>
    {
        .init(input: self.items)
    }

    @inlinable package
    func parseAll() throws -> [BSON.FieldDecoder<BSON.Key>]
    {
        var fields:[BSON.FieldDecoder<BSON.Key>] = []
        var parsed:BSON.KeyspaceDecoder<BSON.Key> = self.parsed()
        while let field:BSON.FieldDecoder<BSON.Key> = try parsed[+]
        {
            fields.append(field)
        }
        return fields
    }

    /// Decorates the ``BSON.AnyValue``-yielding overload of this method with one that
    /// yields the key-value pairs as fields.
    @available(*, deprecated)
    @inlinable public
    func parse(to decode:(_ field:BSON.FieldDecoder<BSON.Key>) throws -> ()) throws
    {
        try self.parse
        {
            try decode(.init(key: $0, value: $1))
        }
    }
}
