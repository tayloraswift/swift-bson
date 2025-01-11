extension BSON
{
    /// A document had an invalid key scheme.
    @frozen public
    enum DocumentKeyError<Key>:Error where Key:Sendable
    {
        /// A document contained more than one field with the same key.
        case duplicate(Key)
        /// A document did not contain a field with the expected key.
        case undefined(Key)
    }
}
extension BSON.DocumentKeyError:Equatable where Key:Equatable
{
}
