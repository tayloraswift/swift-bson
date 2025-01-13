extension BSON
{
    @frozen public
    enum SingleKeyError<CodingKey>:Equatable, Error
    {
        case none
        case multiple
    }
}
