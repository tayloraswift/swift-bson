import BSON

extension BSON.Key
{
    init(_ codingKey:some CodingKey)
    {
        self.init(rawValue: codingKey.stringValue)
    }
}
