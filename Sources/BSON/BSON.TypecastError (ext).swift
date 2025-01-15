extension BSON.TypecastError:CustomStringConvertible
{
    public
    var description:String
    {
        "cannot cast variant of type '\(self.variant)' to type '\(Value.self)'"
    }
}
