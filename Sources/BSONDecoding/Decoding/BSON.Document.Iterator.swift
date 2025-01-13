import BSONABI

extension BSON.Document
{
    @frozen @usableFromInline
    struct Iterator
    {
        @usableFromInline
        var input:BSON.Input

        @inlinable
        init(input:BSON.Input)
        {
            self.input = input
        }
    }
}
extension BSON.Document.Iterator
{
    @inlinable mutating
    func next() throws -> (key:String, value:BSON.AnyValue)?
    {
        guard
        let code:UInt8 = input.next()
        else
        {
            return nil
        }
        let type:BSON.AnyType = try .init(code: code)
        let key:String = try input.parse(as: String.self)
        return (key, try input.parse(variant: type))
    }
}
