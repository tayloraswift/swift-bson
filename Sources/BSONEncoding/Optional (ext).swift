extension Optional:BSONEncodable where Wrapped:BSONEncodable
{
    /// Encodes this optional as an explicit ``BSON.AnyType/null``, if nil.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self?.encode(to: &field) ?? BSON.Null.init().encode(to: &field)
    }
}
