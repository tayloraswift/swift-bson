import TraceableErrors

extension BSON.DecodingError:Equatable where Location:Equatable
{
    /// Compares the ``location`` properties and the ``underlying``
    /// errors of the operands for equality, returning `true`
    /// if they are equal. Always returns `false` if (any of)
    /// the underlying ``Error`` existentials are not ``Equatable``.
    public
    static func == (a:Self, b:Self) -> Bool
    {
        a.location == b.location && a.underlying == b.underlying
    }
}
extension BSON.DecodingError:TraceableError
{
    /// Returns a single note that says
    /// [`"while decoding value for field '_'"`]().
    public
    var notes:[String]
    {
        ["while decoding value for field '\(self.location)'"]
    }
}
