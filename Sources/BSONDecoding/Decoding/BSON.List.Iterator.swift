extension BSON.List
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
extension BSON.List.Iterator
{
    @inlinable mutating
    func next() throws -> BSON.AnyValue?
    {
        guard
        let code:UInt8 = self.input.next()
        else
        {
            return nil
        }
        let type:BSON.AnyType = try .init(code: code)
        try self.input.parse(through: 0x00)
        return try self.input.parse(variant: type)
    }
}
