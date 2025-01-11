extension Set
{
    @frozen public
    struct UnorderedElements
    {
        public
        let set:Set<Element>

        @inlinable
        init(set:Set<Element>)
        {
            self.set = set
        }
    }
}
extension Set.UnorderedElements:BSONEncodable where Element:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.encode(to: &field[as: BSON.ListEncoder.self])
    }

    @inlinable public
    func encode(to bson:inout BSON.ListEncoder)
    {
        for element:Element in self.set
        {
            element.encode(to: &bson[+])
        }
    }
}
extension Set.UnorderedElements:BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(bson: consume bson))
    }
    @inlinable public
    init(bson:BSON.List) throws
    {
        var set:Set<Element> = []
        try bson.parse
        {
            set.update(with: try $0.decode(to: Element.self))
        }
        self.init(set: set)
    }
}
