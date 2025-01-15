extension BSON
{
    /// An efficient interface for checking the shape of a binary array at run time.
    @frozen public
    struct BinaryShape:Hashable, Sendable
    {
        public
        let bytes:Int

        @inlinable public
        init(bytes:Int)
        {
            self.bytes = bytes
        }
    }
}
extension BSON.BinaryShape
{
    /// Returns the quotient if the number of bytes in the array is a multiple of the specified
    /// stride, or throws a ``BinaryShapeError`` otherwise. If the stride is zero, this method
    /// also throws a ``BinaryShapeError``, unless the size of the array is zero as well.
    @inlinable public
    func expect(multipleOf stride:Int) throws -> Int
    {
        if  self.bytes == 0
        {
            return 0
        }

        guard stride > 0,
        case (let count, remainder: 0) = self.bytes.quotientAndRemainder(dividingBy: stride)
        else
        {
            throw BSON.BinaryShapeError.init(
                invalid: self.bytes,
                expected: .stride(of: stride))
        }

        return count
    }
}
