extension BSON
{
    @frozen public
    struct ListDecoder_
    {
        @usableFromInline
        var input:List.Iterator
        @usableFromInline
        var index:Int

        @inlinable
        init(input:List.Iterator)
        {
            self.input = input
            self.index = 0
        }
    }
}
extension BSON.ListDecoder_
{
    @inlinable public
    var position:BSON.Shape { .init(length: self.index) }

    @inlinable public
    subscript(_:(BSON.EndIndex) -> ()) -> BSON.OptionalDecoder<Int>
    {
        mutating get throws
        {
            defer { self.index += 1 }
            return .init(key: self.index, value: try self.input.next())
        }
    }

    @inlinable public
    subscript(_:(BSON.EndIndex) -> ()) -> BSON.FieldDecoder<Int>?
    {
        mutating get throws
        {
            guard
            let value:BSON.AnyValue = try self.input.next()
            else
            {
                return nil
            }
            defer
            {
                self.index += 1
            }
            return .init(key: self.index, value: value)
        }
    }
}
