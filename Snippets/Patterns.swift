import BSON

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
struct FirstAndLastName:BSONListEncodable, BSONListDecodable_
{
    let firstName:String
    let lastName:String

    func encode(to bson:inout BSON.ListEncoder)
    {
        bson[+] = self.firstName
        bson[+] = self.lastName
    }

    init(bson:consuming BSON.ListDecoder_) throws
    {
        self.firstName = try bson[+].decode()
        self.lastName = try bson[+].decode()
        try bson.position.expect(length: 2)
    }
}
//  snippet.end
