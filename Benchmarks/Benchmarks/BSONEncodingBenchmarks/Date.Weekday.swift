import BSON

extension Date
{
    enum Weekday:String, CaseIterable
    {
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
}
extension Date.Weekday:BSONDecodable, BSONEncodable
{
}
