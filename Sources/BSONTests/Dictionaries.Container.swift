import BSON

extension Dictionaries
{
    struct Container
    {
        let dictionary:[NestedKey: String]

        init(_ dictionary:[NestedKey: String])
        {
            self.dictionary = dictionary
        }
    }
}
extension Dictionaries.Container
{
    enum CodingKey:String, Sendable
    {
        case dictionary
    }
}
extension Dictionaries.Container:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.dictionary] = self.dictionary.unordered
    }
}
extension Dictionaries.Container:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(try bson[.dictionary].decode(
            as: Dictionary<NestedKey, String>.UnorderedItems.self,
            with: \.dictionary))
    }
}
extension Dictionaries.Container
{
    func recode() throws -> Self
    {
        try .init(bson: BSON.Document.init(encoding: self))
    }
}
