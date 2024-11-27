extension BSON
{
    public
    protocol BinaryPackable<Storage>
    {
        associatedtype Storage:BitwiseCopyable

        static func get(_ storage:Storage) -> Self
        consuming func set() -> Storage
    }
}
extension BSON.BinaryPackable where Storage == Self, Self:FixedWidthInteger
{
    @inlinable public
    static func get(_ storage:Self) -> Self { .init(bigEndian: storage) }

    @inlinable public consuming
    func set() -> Self { self.bigEndian }
}
