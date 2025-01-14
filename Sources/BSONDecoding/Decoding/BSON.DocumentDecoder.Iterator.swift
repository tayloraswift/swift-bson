extension BSON.DocumentDecoder
{
    @frozen public
    struct Iterator
    {
        @usableFromInline
        var base:Dictionary<CodingKey, BSON.AnyValue>.Iterator

        @inlinable
        init(base:Dictionary<CodingKey, BSON.AnyValue>.Iterator)
        {
            self.base = base
        }
    }
}
extension BSON.DocumentDecoder.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> BSON.FieldDecoder<CodingKey>?
    {
        self.base.next().map { .init(key: $0.key, value: $0.value) }
    }
}
