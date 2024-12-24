import BSON

//  snippet.RAW_REPRESENTATION
enum Continent:Int32, BSONEncodable, BSONDecodable
{
    case africa
    case antarctica
    case asia
    case australia
    case europe
    case northAmerica
    case southAmerica
}
//  snippet.STRING_REPRESENTATION
struct Host:LosslessStringConvertible,
    BSONStringEncodable,
    BSONStringDecodable
{
    let name:String
    let port:Int?

    init?(_ string:String)
    {
        if  let i:String.Index = string.firstIndex(of:":"),
            let port:Int = .init(string[string.index(after:i)...])
        {
            self.name = String.init(string[..<i])
            self.port = port
        }
        else
        {
            self.name = string
            self.port = nil
        }
    }

    var description:String
    {
        self.port.map { "\(self.name):\($0)" } ?? self.name
    }
}
