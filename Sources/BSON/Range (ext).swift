extension Range
{
    /// The default BSON representation of a ``Range``, which is a BSON document keyed by
    /// `M` (``lowerBound``) and `V` (``upperBound``).
    ///
    /// The keys are chosen such that accidentally encoding a ``Range`` as a ``ClosedRange``
    /// will always result in a decoding error.
    ///
    /// Some applications that store arrays of ranges may benefit from a specialized buffer
    /// layout.
    @frozen public
    enum CodingKey:String, Sendable
    {
        case lowerBound = "M"
        case upperBound = "V"
    }
}
extension Range:BSONDocumentEncodable, BSONEncodable where Bound:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.lowerBound] = self.lowerBound
        bson[.upperBound] = self.upperBound
    }
}
extension Range:BSONDocumentDecodable, BSONDecodable where Bound:BSONDecodable
{
    /// If the range is invalid, the initializer throws an ``CodingError/invalidBounds`` error.
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let lowerBound:Bound = try bson[.lowerBound].decode()
        let upperBound:Bound = try bson[.upperBound].decode()

        if  upperBound < lowerBound
        {
            throw BSON.RangeDecodingError.invalidBounds
        }

        self.init(uncheckedBounds: (lower: lowerBound, upper: upperBound))
    }
}
