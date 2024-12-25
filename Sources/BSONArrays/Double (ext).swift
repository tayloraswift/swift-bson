extension Double:BSON.BinaryPackable
{
    @inlinable public
    static func get(_ storage:UInt64) -> Self { .init(bitPattern: .get(storage)) }

    @inlinable public
    consuming func set() -> UInt64 { self.bitPattern.set() }
}
