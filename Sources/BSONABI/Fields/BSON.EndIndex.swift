extension BSON
{
    /// A syntactical abstraction used to express the “end index” of a list or document.
    /// This type has no inhabitants.
    @frozen public
    enum EndIndex {}
}
extension BSON.EndIndex
{
    /// A syntactical symbol used to express the “end index” of an list or document.
    @inlinable public
    static prefix func + (_:Self) {}
}
