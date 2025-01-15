extension BSON.BinaryShape
{
    /// Throws an ``BinaryShapeError`` if the array does not
    /// contain the specified number of bytes.
    @inlinable public
    func expect(size bytes:Int) throws
    {
        guard self.bytes == bytes
        else
        {
            throw BSON.BinaryShapeError.init(invalid: self.bytes, expected: .size(bytes))
        }
    }

    /// Converts a boolean status code into a thrown ``BinaryShapeError``.
    /// To raise an error, return false from the closure.
    @inlinable public
    func expect(that predicate:(_ bytes:Int) throws -> Bool) throws
    {
        guard try predicate(self.bytes)
        else
        {
            throw BSON.BinaryShapeError.init(invalid: self.bytes)
        }
    }
}
