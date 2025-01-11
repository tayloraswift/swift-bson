import BSON

struct BooleanContainer
{
    let b:Bool
}
extension BooleanContainer
{
    enum CodingKey:String, Sendable
    {
        case b = "b"
    }
}
extension BooleanContainer:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.b] = self.b
    }
}
extension BooleanContainer:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(b: try bson[.b].decode())
    }
}

do
{
    //  snippet.BINDING
    let full:[UInt8] = [
        0x09, 0x00, 0x00, 0x00, //  Document header
        0x08, 0x62, 0x00, 0x01, //  Document body
        0x00                    //  Trailing null byte
    ]
    let bson:BSON.Document = .init(bytes: full[4 ..< 8])
    //  snippet.end
    print(bson)

    //  snippet.DECODING
    let decoded:BooleanContainer = try .init(bson: bson)
    //  snippet.ENCODING
    let encoded:BSON.Document = .init(encoding: decoded)
    let data:ArraySlice<UInt8> = encoded.bytes
    //  snippet.end

    print(encoded)
    print(decoded)
    print(data == full[4 ..< 8])
}
