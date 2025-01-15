extension BSON.Regex.OptionError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid regex option '\(self.codepoint)'"
    }
}
