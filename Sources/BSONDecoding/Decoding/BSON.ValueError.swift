extension BSON
{
    /// A decoder successfully to cast a variant to an expected value type,
    /// but it was not a valid case of the expected destination type.
    @frozen public
    struct ValueError<Value, Cases>:Error where Value:Sendable
    {
        public
        let value:Value

        @inlinable public
        init(invalid value:Value)
        {
            self.value = value
        }
    }
}
extension BSON.ValueError:Equatable where Value:Equatable
{
}
