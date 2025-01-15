extension BSON
{
    /// A parser did not receive the expected amount of input.
    @frozen public
    struct InputError:Equatable, Error
    {
        /// What the input should have yielded.
        public
        let expected:Expectation
        /// The number of bytes available in the input.
        public
        let encountered:Int

        @inlinable public
        init(expected:Expectation, encountered:Int = 0)
        {
            self.expected = expected
            self.encountered = encountered
        }
    }
}
