import BSON

struct ExampleModel:BSONDocumentEncodable, BSONDocumentDecodable
{
    let id:Int64
    let name:String?
    let rank:Rank

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
