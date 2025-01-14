extension BSON
{
    /// An iterable type that produces this list’s elements, with associated indices. Parsing a
    /// list is slightly faster than parsing a general ``Document``, because this method ignores
    /// the document keys.
    ///
    /// This type does *not* perform any key validation.
    @frozen public
    struct ListDecoder
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
extension BSON.ListDecoder
{
    @inlinable public
    var position:Int { self.index }

    @inlinable public
    subscript(_:(BSON.EndIndex) -> ()) -> BSON.OptionalDecoder<Int>
    {
        mutating get throws
        {
            guard
            let value:BSON.AnyValue = try self.input.next()
            else
            {
                return .init(key: self.index, value: nil)
            }
            defer
            {
                self.index += 1
            }
            return .init(key: self.index, value: value)
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
