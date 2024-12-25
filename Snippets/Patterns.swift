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
        if  let i:String.Index = string.firstIndex(of: ":"),
            let port:Int = .init(string[string.index(after: i)...])
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
//  snippet.end

//  snippet.LIST_ENCODING_MANUAL
struct NumbersExpanded:BSONListEncodable
{
    let range:Range<Int32>

    func encode(to bson:inout BSON.ListEncoder)
    {
        for value:Int32 in self.range
        {
            bson[+] = value
        }
    }
}
//  snippet.end
struct NumbersExpanded2:BSONListEncodable
{
    let range:Range<Int32>

    //  snippet.LIST_ENCODING_SILLY
    enum SillyElementKey:String, Sendable
    {
        case minusOne = "M"
        case plusOne = "P"
    }

    func encode(to bson:inout BSON.ListEncoder)
    {
        for value:Int32 in self.range
        {
            bson
            {
                $0[+] = value - 1
                $0[+] = value + 1
            }
            bson(SillyElementKey.self)
            {
                $0[.minusOne] = value - 1
                $0[.plusOne] = value + 1
            }
        }
    }
    //  snippet.end
}
//  snippet.LIST_PAIR
struct FirstAndLastName:BSONListEncodable, BSONListDecodable
{
    let firstName:String
    let lastName:String

    func encode(to bson:inout BSON.ListEncoder)
    {
        bson[+] = self.firstName
        bson[+] = self.lastName
    }

    init(bson:BSON.ListDecoder) throws
    {
        try bson.shape.expect(length: 2)

        self.firstName = try bson[0].decode()
        self.lastName = try bson[1].decode()
    }
}
//  snippet.end
