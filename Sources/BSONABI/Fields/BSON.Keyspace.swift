extension BSON
{
    /// A keyspace is a type that is used to identify an arbitrary associative mapping within
    /// a ``BSON.Document``. Keyspaces are not the same as schema keys, which are a fixed (but
    /// evolving) set of names that are used to identify structural properties in a model type.
    ///
    /// The main functional difference between a keyspace and a schema key is that failing to
    /// convert a string key to a keyspace is an error, but failing to convert a string key to
    /// a schema key is not.
    public
    protocol Keyspace:RawRepresentable<String>, Sendable
    {
        /// Returns a string representation of the key that must not contain any null bytes.
        override
        var rawValue:String { get }
    }
}
