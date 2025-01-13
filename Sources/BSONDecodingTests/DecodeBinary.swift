import BSON
import Testing

@Suite
struct DecodeBinary
{
    private
    enum CodingKey:String, Sendable
    {
        case x
    }

    @Test
    static func MD5() throws
    {
        let md5:BSON.BinaryView<ArraySlice<UInt8>> = .init(subtype: .md5,
            bytes: [0xff, 0xfe, 0xfd])
        let document:BSON.Document = .init(CodingKey.self)
        {
            $0[.x].encode(binary: md5)
        }

        let decoder:BSON.DocumentDecoder<CodingKey> = try .init(parsing: document)
        let decoded:BSON.BinaryView<ArraySlice<UInt8>> = try decoder[.x].decode()

        #expect(md5 == decoded)
    }
}
