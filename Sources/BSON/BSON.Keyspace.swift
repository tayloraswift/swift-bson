extension BSON
{
    public
    protocol Keyspace:RawRepresentable<String>, Sendable
    {
        /// Returns a string representation of the key that must not contain any null bytes.
        override
        var rawValue:String { get }
    }
}
