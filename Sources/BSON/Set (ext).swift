extension Set
{
    @inlinable public
    var unordered:UnorderedElements { .init(set: self) }
}
