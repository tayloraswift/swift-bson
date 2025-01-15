extension BSON.KeyspaceError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        could not map raw document key '\(key)' to key space '\(String.init(reflecting: space))'
        """
    }
}
