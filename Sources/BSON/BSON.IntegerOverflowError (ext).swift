extension BSON.IntegerOverflowError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .int32 (let value):
            "value '\(value)' of type 'int32' overflows decoded type '\(Overflowed.self)'"
        case .int64 (let value):
            "value '\(value)' of type 'int64' overflows decoded type '\(Overflowed.self)'"
        case .uint64(let value):
            "value '\(value)' of type 'uint64' overflows decoded type '\(Overflowed.self)'"
        }
    }
}
