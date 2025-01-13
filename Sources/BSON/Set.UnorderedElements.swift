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
extension Set.UnorderedElements:BSONEncodable, BSONListEncodable where Element:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.ListEncoder)
    {
        for element:Element in self.set
        {
            element.encode(to: &bson[+])
        }
    }
}
extension Set.UnorderedElements:BSONDecodable, BSONListDecodable_ where Element:BSONDecodable
{
    @inlinable public
    init(bson:consuming BSON.ListDecoder_) throws
    {
        var set:Set<Element> = []
        //  The explicit type `Element.self` (instead of `Element?.self`) guards against the
        //  rare scenario where a BSON list contains an interior `null` value.
        while let element:Element = try bson[+]?.decode(to: Element.self)
        {
            set.update(with: element)
        }
        self.init(set: set)
    }
}
