import BSON

struct Date
{
    let year:Year
    let month:Month
    let day:Int
    let weekday:Weekday
    var comment:String

    init(year:Year, month:Month, day:Int, weekday:Weekday)
    {
        self.year = year
        self.month = month
        self.day = day
        self.weekday = weekday
        self.comment = ""
        self.comment = self.description
    }
}
extension Date:CustomStringConvertible
{
    var description:String
    {
        "\(self.weekday) \(self.month) \(self.day), \(self.year)"
    }
}
extension Date:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson["year"] = self.year
        bson["month"] = self.month
        bson["day"] = self.day
        bson["weekday"] = self.weekday
        bson["comment"] = self.comment
    }
}
