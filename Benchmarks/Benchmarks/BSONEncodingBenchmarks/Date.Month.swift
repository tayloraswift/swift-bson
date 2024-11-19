import BSON

extension Date
{
    enum Month:Int32, CaseIterable
    {
        case january = 1
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
    }
}
extension Date.Month:BSONDecodable, BSONEncodable
{
}
