extension BSON.InputError:CustomStringConvertible
{
    public
    var description:String
    {
        self.encountered == 0 ?
            "expected \(self.expected)" :
            "expected \(self.expected), encountered \(self.encountered) byte(s)"
    }
}
