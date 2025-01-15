extension BSON
{
    @frozen public
    struct HeaderError<Frame>:Equatable, Error where Frame:BufferFrameType
    {
        public
        let length:Int

        @inlinable public
        init(length:Int)
        {
            self.length = length
        }
    }
}
