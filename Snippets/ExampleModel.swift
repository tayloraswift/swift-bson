import BSON

//  snippet.MODEL_DEFINITION
struct ExampleModel:BSONDocumentEncodable, BSONDocumentDecodable
{
    let id:Int64
    let name:String?
    let rank:Rank

    //  snippet.hide
    init(id:Int64, name:String?, rank:Rank)
    {
        self.id = id
        self.name = name
        self.rank = rank
    }
    //  snippet.show

    enum Rank:Int32, BSONEncodable, BSONDecodable
    {
        case newModel
        case risingStar
        case aspiringModel
        case fashionista
        case glamourista
        case fashionMaven
        case runwayQueen
        case trendSetter
        case runwayDiva
        case topModel
    }

    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case name = "D"
        case rank = "R"
    }

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
        bson[.rank] = self.rank == .newModel ? nil : self.rank
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.id = try bson[.id].decode()
        self.name = try bson[.name]?.decode()
        self.rank = try bson[.rank]?.decode() ?? .newModel
    }
}
//  snippet.end
extension ExampleModel:Equatable
{
}

do
{
    //  snippet.MODEL_USAGE
    let models:[ExampleModel] = [
        .init(id: 0, name: "Gigi", rank: .topModel),
        .init(id: 1, name: nil, rank: .newModel),
    ]

    /// Round-trip one model
    let document:BSON.Document = .init(encoding: models[0])
    let _:ArraySlice<UInt8> = document.bytes
    let model:ExampleModel = try .init(bson: document)

    /// Round-trip a list of models
    let list:BSON.List = .init(elements: models)
    let _:ArraySlice<UInt8> = list.bytes
    let array:[ExampleModel] = try .init(bson: list)

    //  snippet.end
    print(model == models[0])
    print(array == models)
}
