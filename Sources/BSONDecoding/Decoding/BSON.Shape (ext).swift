extension BSON.Shape
{
    /// Throws an ``ShapeError`` if the relevant collection does not
    /// contain the specified number of elements.
    @inlinable public
    func expect(length:Int) throws
    {
        guard self.length == length
        else
        {
            throw BSON.ShapeError.init(invalid: self.length, expected: .length(length))
        }
    }

    /// Converts a boolean status code into a thrown ``ShapeError``.
    /// To raise an error, return false from the closure.
    @inlinable public
    func expect(that predicate:(_ length:Int) throws -> Bool) throws
    {
        guard try predicate(self.length)
        else
        {
            throw BSON.ShapeError.init(invalid: self.length)
        }
    }
}
