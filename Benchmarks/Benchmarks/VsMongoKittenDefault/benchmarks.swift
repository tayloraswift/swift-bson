@preconcurrency import Benchmark
import BSON
import MongoKittenBSON

struct DocumentModel:Codable
{
    let username:String
    let online:Bool
    let age:Int
    let emails:[Email]
    let profile:Profile

    enum CodingKeys:String, Swift.CodingKey
    {
        case username = "U"
        case online = "O"
        case age = "A"
        case emails = "E"
        case profile = "P"
    }

    enum CodingKey:String, Sendable
    {
        case username = "U"
        case online = "O"
        case age = "A"
        case emails = "E"
        case profile = "P"
    }
}
extension DocumentModel:BSONDocumentEncodable, BSONDocumentDecodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.username] = self.username
        bson[.online] = self.online
        bson[.age] = self.age
        bson[.emails] = self.emails
        bson[.profile] = self.profile
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.username = try bson[.username].decode()
        self.online = try bson[.online].decode()
        self.age = try bson[.age].decode()
        self.emails = try bson[.emails].decode()
        self.profile = try bson[.profile].decode()
    }
}
extension DocumentModel
{
    struct Email:Codable, BSONEncodable, BSONDecodable, RawRepresentable
    {
        let rawValue:String
    }
}
extension DocumentModel.Email
{
    static var random:Self
    {
        let provider:String
        switch Int.random(in: 0 ..< 3)
        {
        case 0: provider = "outlook.com"
        case 1: provider = "gmail.com"
        case 2: provider = "hotmail.com"
        case _: provider = "example.com"
        }

        return .init(rawValue: "user\(Int.random(in: 0 ..< 1000))@\(provider)")
    }
}
extension DocumentModel
{
    struct Profile:Codable
    {
        let name:String
        let bio:String?

        enum CodingKeys:String, Swift.CodingKey
        {
            case name = "N"
            case bio = "B"
        }

        enum CodingKey:String, Sendable
        {
            case name = "N"
            case bio = "B"
        }
    }
}
extension DocumentModel.Profile:BSONDocumentEncodable, BSONDocumentDecodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.name] = self.name
        bson[.bio] = self.bio
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.name = try bson[.name].decode()
        self.bio = try bson[.bio]?.decode()
    }
}
extension DocumentModel.Profile
{
    static var random:Self
    {
        .init(
            name: "User \(Int.random(in: 0 ..< 1000))",
            bio: Bool.random() ? nil : """
            Mother of dragons, breaker of chains, queen of the seven kingdoms, and protector \
            of the realm. Married to Khal Drogo, and mother of Rhaego. M7GA!!! 🐉🔥
            """)
    }
}

func generateRandomDocumentModels(_ count:Int = 10_000) -> [DocumentModel]
{
    (0 ..< count).map
    {
        _ in .init(
            username: "user\(Int.random(in: 0 ..< 1000))",
            online: Bool.random(),
            age: Int.random(in: 0 ..< 100),
            emails: (0 ..< Int.random(in: 1 ..< 5)).map { _ in .random },
            profile: .random)
    }
}

func encodeWithMongoKittenDefault(_ models:[DocumentModel]) -> Document
{
    try! BSONEncoder().encode(models)
}
func encodeWithThisLibrary(_ models:[DocumentModel]) -> BSON.List
{
    .init
    {
        for model:DocumentModel in models
        {
            $0[+] = model
        }
    }
}

func decodeWithMongoKittenDefault(_ bson:Document) throws -> [DocumentModel]
{
    try BSONDecoder().decode([DocumentModel].self, from: bson)
}
func decodeWithThisLibrary(_ bson:BSON.List) throws -> [DocumentModel]
{
    var models:[DocumentModel] = []
    var parsed:BSON.ListDecoder = bson.parsed
    while let model:DocumentModel = try parsed[+]?.decode()
    {
        models.append(model)
    }
    return models
}


@MainActor
let benchmarks:() -> () =
{
    Benchmark.defaultConfiguration.maxIterations = .count(1000)
    Benchmark.defaultConfiguration.maxDuration = .seconds(3)
    Benchmark.defaultConfiguration.metrics = [.throughput, .wallClock] + BenchmarkMetric.arc

    Benchmark.init("Encode BSON with MongoKitten Default")
    {
        (benchmark:Benchmark) in

        let models:[DocumentModel] = generateRandomDocumentModels(100)

        benchmark.startMeasurement()

        for _:Int in benchmark.scaledIterations
        {
            blackHole(encodeWithMongoKittenDefault(models))
        }
    }
    Benchmark.init("Encode BSON with This Library")
    {
        (benchmark:Benchmark) in

        let models:[DocumentModel] = generateRandomDocumentModels(100)

        benchmark.startMeasurement()

        for _:Int in benchmark.scaledIterations
        {
            blackHole(encodeWithMongoKittenDefault(models))
        }
    }

    Benchmark.init("Decode BSON with MongoKitten Default")
    {
        (benchmark:Benchmark) in

        let models:[DocumentModel] = generateRandomDocumentModels(100)
        let bson:Document = try! BSONEncoder().encode(models)

        benchmark.startMeasurement()

        for _:Int in benchmark.scaledIterations
        {
            blackHole(try decodeWithMongoKittenDefault(bson))
        }
    }

    Benchmark.init("Decode BSON with This Library")
    {
        (benchmark:Benchmark) in

        let models:[DocumentModel] = generateRandomDocumentModels(100)
        let bson:BSON.List = encodeWithThisLibrary(models)

        benchmark.startMeasurement()

        for _:Int in benchmark.scaledIterations
        {
            blackHole(try decodeWithThisLibrary(bson))
        }
    }
}
