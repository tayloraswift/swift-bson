extension ClosedRange:BSON.BinaryPackable where Bound:BSON.BinaryPackable
{
    public
    typealias Storage = (Bound.Storage, Bound.Storage)

    @inlinable public
    static func get(_ storage:Storage) -> Self
    {
        let first:Bound = .get(storage.0)
        let last:Bound = .get(storage.1)
        if  last < first
        {
            return .init(uncheckedBounds: (last, first))
        }
        else
        {
            return .init(uncheckedBounds: (first, last))
        }
    }

    @inlinable public
    consuming func set() -> Storage
    {
        (self.lowerBound.set(), self.upperBound.set())
    }
}
