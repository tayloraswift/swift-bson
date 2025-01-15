extension BSON
{
    @frozen @usableFromInline
    enum RangeDecodingError:Error
    {
        case invalidBounds
    }
}
extension BSON.RangeDecodingError:CustomStringConvertible
{
    @usableFromInline
    var description:String
    {
        switch self
        {
        case .invalidBounds:    "invalid range bounds"
        }
    }
}
