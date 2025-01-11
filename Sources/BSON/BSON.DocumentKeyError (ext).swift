import TraceableErrors

extension BSON.DocumentKeyError:NamedError
{
    /// The name of the error.
    ///
    /// We customize this because otherwise the catcher of this error will mostly likely see
    /// the coding key type name as `CodingKey`, and that wouldn’t be very helpful.
    public
    var name:String
    {
        "DocumentKeyError<\(String.init(reflecting: Key.self))>"
    }
    public
    var message:String
    {
        switch self
        {
        case .duplicate(let key):
            "duplicate key '\(key)'"
        case .undefined(let key):
            "undefined key '\(key)'"
        }
    }
}
