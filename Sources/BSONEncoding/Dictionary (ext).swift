/// We generally do *not* want dictionaries to be ``BSONEncodable``,
/// and dictionary literals generate dictionaries by default.
extension [BSON.Key: Never]:BSONEncodable
{
    /// Encodes this dictionary as an empty document.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(document: [:])
    }
}
