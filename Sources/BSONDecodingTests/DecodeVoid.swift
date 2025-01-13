import BSON
import Testing

@Suite
struct DecodeVoid
{
    enum CodingKey:String
    {
        case null
        case max
        case min
    }

    private
    let bson:BSON.DocumentDecoder<CodingKey>

    init() throws
    {
        let bson:BSON.Document = .init(CodingKey.self)
        {
            $0[.null] = BSON.Null.init()
            $0[.max] = BSON.Max.init()
            $0[.min] = BSON.Min.init()
        }

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeVoid
{
    @Test
    func Null() throws
    {
        #expect(try BSON.Null.init() == self.bson[.null].decode())
    }

    @Test
    func Max() throws
    {
        #expect(try BSON.Max.init() == self.bson[.max].decode())
    }

    @Test
    func Min() throws
    {
        #expect(try BSON.Min.init() == self.bson[.min].decode())
    }
}

