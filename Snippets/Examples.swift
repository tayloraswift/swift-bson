import BSON

//  snippet.MODEL
struct Model:BSONDocumentEncodable, BSONDocumentDecodable
{
    let id:Int64
    let name:String

    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case name = "N"
    }

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.id = try bson[.id].decode()
        self.name = try bson[.name].decode()
    }
}

//  snippet.MODEL_OPTIONAL
struct ModelWithOptional:BSONDocumentEncodable, BSONDocumentDecodable
{
    let x:Int32?

    //  snippet.hide
    enum CodingKey:String, Sendable
    {
        case x
    }
    //  snippet.show

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.x] = self.x
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.x = try bson[.x]?.decode()
    }
}

//  snippet.MODEL_LIST
struct ModelWithList:BSONDocumentEncodable, BSONDocumentDecodable
{
    let x:[String]

    //  snippet.hide
    enum CodingKey:String, Sendable
    {
        case x
    }
    //  snippet.show

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.x] = self.x.isEmpty ? nil : self.x
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.x = try bson[.x]?.decode() ?? []
    }
}

//  snippet.MODEL_UNORDERED
struct ModelWithCollections:BSONDocumentEncodable, BSONDocumentDecodable
{
    let x:[BSON.Key: Int32]
    let y:Set<Double>

    //  snippet.hide
    enum CodingKey:String, Sendable
    {
        case x
        case y
    }
    //  snippet.show

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.x] = self.x.isEmpty ? nil : self.x.unordered
        bson[.y] = self.y.isEmpty ? nil : self.y.unordered
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.x = try bson[.x]?.decode(
            as: Dictionary<BSON.Key, Int32>.UnorderedItems.self,
            with: \.dictionary) ?? [:]

        self.y = try bson[.y]?.decode(
            as: Set<Double>.UnorderedElements.self,
            with: \.set) ?? []
    }
}

//  snippet.MODEL_NESTED
struct ModelWithNestedDocument:BSONDocumentEncodable, BSONDocumentDecodable
{
    let x:Model
    let y:Model?
    let z:[Model]

    //  snippet.hide
    enum CodingKey:String, Sendable
    {
        case x, y, z
    }
    //  snippet.show

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.x] = self.x
        bson[.y] = self.y
        bson[.z] = self.z.isEmpty ? nil : self.z
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.x = try bson[.x].decode()
        self.y = try bson[.y]?.decode()
        self.z = try bson[.z]?.decode() ?? []
    }
}

//  snippet.MODEL_NULL
struct ModelWithNoExplicitNull:BSONDocumentEncodable, BSONDocumentDecodable
{
    let x:String?

    //  snippet.hide
    enum CodingKey:String, Sendable
    {
        case x
    }

    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.x] = self.x
    }

    //  snippet.show
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.x = try bson[.x]?.decode(to: String.self)
    }
}

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
