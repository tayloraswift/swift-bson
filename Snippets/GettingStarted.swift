import BSON

//  snippet.LEGACY_DECODABLE
import BSONLegacy

struct BooleanContainer:Decodable, Encodable
{
    let b:Bool

    init(b:Bool)
    {
        self.b = b
    }
}
// snippet.end

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

    //  snippet.LEGACY_DECODING
    let fromLegacy:BooleanContainer = try .init(
        from: BSON.AnyValue.document(bson))
    //  snippet.end

    print(fromLegacy)
}

//  snippet.EXAMPLE_MODEL_DEFINITION
struct ExampleModel
{
    let id:Int64
    let name:String?
    let rank:Rank

    enum Rank:Int32
    {
        case newModel
        case risingStar
        case aspiringModel
        case fashionista
        case glamourista
        case fashionMaven
        case runwayQueen
        case trendsetter
        case runwayDiva
        case topModel
    }
}
//  snippet.EXAMPLE_MODEL_CODING_KEY
extension ExampleModel
{
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case name = "D"
        case rank = "R"
    }
}
//  snippet.EXAMPLE_MODEL_DECODABLE
extension ExampleModel:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.id = try bson[.id].decode()
        self.name = try bson[.name]?.decode()
        self.rank = try bson[.rank]?.decode() ?? .newModel
    }
}
//  snippet.EXAMPLE_MODEL_RANK_DECODABLE
extension ExampleModel.Rank:BSONDecodable
{
}
//  snippet.EXAMPLE_MODEL_RANK_ENCODABLE
extension ExampleModel.Rank:BSONEncodable
{
}
//  snippet.EXAMPLE_MODEL_ENCODABLE
extension ExampleModel:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
        bson[.rank] = self.rank == .newModel ? nil : self.rank
    }
}
//  snippet.end
do
{
    //  snippet.PUTTING_IT_ALL_TOGETHER
    let originalModel:ExampleModel = .init(id: 1,
        name: "AAA",
        rank: .topModel)

    let encodedModel:BSON.Document = .init(encoding: originalModel)
    let decodedModel:ExampleModel = try .init(bson: encodedModel)

    print(originalModel)
    print(decodedModel)
    //  snippet.end
}
