extension BSON.TypeError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid variant type code (\(self.code))"
    }
}
