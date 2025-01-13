import BSONABI

extension BSON
{
    @frozen public
    struct KeyspaceDecoder<Key>
    {
        @usableFromInline
        var input:Document.Iterator

        @inlinable
        init(input:Document.Iterator)
        {
            self.input = input
        }
    }
}
extension BSON.KeyspaceDecoder where Key:RawRepresentable<String>, Key:Sendable
{
    @inlinable public
    subscript(_:(BSON.EndIndex) -> ()) -> BSON.FieldDecoder<Key>?
    {
        mutating get throws
        {
            guard
            let (key, value):(String, BSON.AnyValue) = try input.next()
            else
            {
                return nil
            }

            guard
            let key:Key = .init(rawValue: key)
            else
            {
                throw BSON.KeyspaceError.init(
                    mapping: BSON.Key.init(rawValue: key),
                    to: Key.self)
            }

            return .init(key: key, value: value)
        }
    }
}
