import BSON
import Testing

@Suite
struct CodableByEnumeratedCodingKeys:Equatable
{
    enum CodingKey:String, Sendable
    {
        case a
        case b
        case c
    }

    let a:Int
    let b:[Int]
    let c:[[Int]]

    private
    init(a:Int, b:[Int], c:[[Int]])
    {
        self.a = a
        self.b = b
        self.c = c
    }

    init()
    {
        self.init(a: 5, b: [5, 6], c: [[5, 6, 7], [8]])
    }
}
extension CodableByEnumeratedCodingKeys:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.a] = self.a
        bson[.b] = self.b
        bson[.c] = self.c
    }
}
extension CodableByEnumeratedCodingKeys:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.a = try bson[.a].decode()
        self.b = try bson[.b].decode()
        self.c = try bson[.c].decode()
    }
}
extension CodableByEnumeratedCodingKeys
{
    @Test
    func roundtrip() throws
    {
        let bson:BSON.Document = .init(BSON.Key.self)
        {
            $0["a"] = 5
            $0["b"] = [5, 6]
            $0["c"] = [[5, 6, 7], [8]]
            $0["d"] = [[[5, 6, 7, 8], [9, 10]], [[11]]]
        }

        let decoded:Self = try .init(bson: bson)

        #expect(self == decoded)

        let encoded:BSON.Document = .init(with: decoded.encode(to:))

        #expect(encoded.bytes.count < bson.bytes.count)

        let redecoded:Self = try .init(bson: encoded)

        #expect(self == redecoded)

        let reencoded:BSON.Document = .init(with: redecoded.encode(to:))

        #expect(reencoded.bytes == encoded.bytes)
    }
}
