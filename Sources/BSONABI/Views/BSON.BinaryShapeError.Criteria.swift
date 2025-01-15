extension BSON.BinaryShapeError
{
    /// What shape you expected a list or binary array to have.
    @frozen public
    enum Criteria:Hashable, Sendable
    {
        case size(Int)
        case stride(of:Int)
    }
}
