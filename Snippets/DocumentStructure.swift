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
extension BooleanContainer:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(b: try bson[.b].decode())
    }
}

do
{
    //  snippet.DOCUMENT_STRUCTURE
    let full:[UInt8] = [
        0x09, 0x00, 0x00, 0x00, //  Document header
        0x08, 0x62, 0x00, 0x01, //  Document body
        0x00                    //  Trailing null byte
    ]
    let bson:BSON.Document = .init(bytes: full[4 ..< 8])
    //  snippet.end
    print(bson)

    //  snippet.DECODING
    let decoded:BooleanContainer = try .init(
        bson: BSON.AnyValue.document(bson))
    //  snippet.end

    print(decoded)
}
