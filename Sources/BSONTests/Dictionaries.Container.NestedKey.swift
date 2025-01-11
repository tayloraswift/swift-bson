import BSON

extension Dictionaries.Container
{
    struct NestedKey:BSON.Keyspace, Hashable
    {
        let id:Int

        init?(rawValue:String)
        {
            guard
            let id:Int = .init(rawValue)
            else
            {
                return nil
            }

            self.id = id
        }

        var rawValue:String { "\(self.id)" }
    }
}
extension Dictionaries.Container.NestedKey:ExpressibleByIntegerLiteral
{
    init(integerLiteral id:Int)
    {
        self.id = id
    }
}
