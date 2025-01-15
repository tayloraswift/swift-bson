extension BSON.HeaderError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        length declared in header (\(self.length)) is less than \
        the minimum for '\(Frame.self)' (\(Frame.suffix - Frame.skipped) bytes)
        """
    }
}
