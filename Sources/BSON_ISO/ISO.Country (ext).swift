import BSON
import ISO

extension ISO.Country:BSON.BinaryPackable
{
    @inlinable public
    static func get(_ storage:UInt16) -> Self { .init(rawValue: .get(storage)) }

    @inlinable public
    consuming func set() -> UInt16 { self.rawValue.set() }
}
extension ISO.Country:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.FieldEncoder)
    {
        Int32.init(self.rawValue).encode(to: &bson)
    }
}
extension ISO.Country:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue)throws
    {
        self.init(rawValue: try bson.cast { try $0.as(UInt16.self) })
    }
}
