extension BSON
{
    /// A BSON field key. This type wraps a ``rawValue`` that is
    /// guaranteed to never contain null bytes. (Null bytes in a
    /// BSON field key can be exploited to perform SQL injection.)
    @frozen public
    struct Key:Hashable, Keyspace, Sendable
    {
        public
        let rawValue:String

        @inlinable public
        init(rawValue:String)
        {
            precondition(!rawValue.utf8.contains(0))
            self.rawValue = rawValue
        }
    }
}
extension BSON.Key
{
    @inlinable public
    init(index:Int)
    {
        self.init(rawValue: index.description)
    }
    @inlinable public
    init(_ other:some RawRepresentable<String>)
    {
        self.init(rawValue: other.rawValue)
    }
}
extension BSON.Key:Comparable
{
    @inlinable public
    static func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension BSON.Key:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension BSON.Key:ExpressibleByStringLiteral, ExpressibleByStringInterpolation
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
