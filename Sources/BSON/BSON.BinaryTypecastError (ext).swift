extension BSON.BinaryTypecastError:CustomStringConvertible
{
    public
    var description:String
    {
        self.expected.map
        {
            "invalid subtype '\(subtype)', expected '\($0)'"
        } ?? "invalid subtype '\(subtype)'"
    }
}
