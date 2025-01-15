extension BSON.BooleanSubtypeError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid boolean subtype code (\(self.code))"
    }
}
