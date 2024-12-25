extension Float:BSON.BinaryPackable
{
    @inlinable public
    static func get(_ storage:UInt32) -> Self { .init(bitPattern: .get(storage)) }

    @inlinable public
    consuming func set() -> UInt32 { self.bitPattern.set() }
}
