extension BSON
{
    @frozen public
    enum RangeDecodingError:Error
    {
        case invalidBounds
    }
}
extension BSON.RangeDecodingError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .invalidBounds:    "Invalid range bounds"
        }
    }
}
