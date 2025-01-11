import BSON

extension Sets
{
    struct Container
    {
        let set:Set<String>

        init(_ set:Set<String>)
        {
            self.set = set
        }
    }
}
extension Sets.Container
{
    enum CodingKey:String, Sendable
    {
        case set
    }
}
extension Sets.Container:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.set] = self.set.unordered
    }
}
extension Sets.Container:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(try bson[.set].decode(as: Set<String>.UnorderedElements.self, with: \.set))
    }
}
extension Sets.Container
{
    func recode() throws -> Self
    {
        try .init(bson: BSON.Document.init(encoding: self))
    }
}
