extension BSON
{
    /// An error that is thrown when a key cannot be mapped to a keyspace.
    ///
    /// Normally, the library ignores unrecognized document keys, in order to facilitate schema
    /// evolution. However, when using documents to represent arbitrary associative mappings,
    /// such as ``Dictionary``, it is often preferable to fail decoding instead of silently
    /// dropping items.
    @frozen public
    struct KeyspaceError:Error
    {
        public
        let key:Key
        public
        let space:any (RawRepresentable<String> & Sendable).Type

        @inlinable public
        init(mapping key:Key, to space:any (RawRepresentable<String> & Sendable).Type)
        {
            self.key = key
            self.space = space
        }
    }
}
extension BSON.KeyspaceError:Equatable
{
    @inlinable public
    static func == (a:Self, b:Self) -> Bool
    {
        a.key == b.key && a.space == b.space
    }
}
extension BSON.KeyspaceError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        could not map raw document key '\(key)' to key space '\(String.init(reflecting: space))'
        """
    }
}
