extension BSON.ValueError:CustomStringConvertible
{
    public
    var description:String
    {
        "value '\(self.value)' does not encode a valid instance of type '\(Cases.self)'"
    }
}
