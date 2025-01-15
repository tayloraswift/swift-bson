extension BSON
{
    /// An overflow occurred while casting an integer value to a desired type.
    @frozen public
    enum IntegerOverflowError<Overflowed>:Equatable, Error where Overflowed:FixedWidthInteger
    {
        /// An overflow occurred while casting an ``Int32`` to an
        /// instance of `Overflowed`.
        case int32(Int32)
        /// An overflow occurred while casting an ``Int64`` to an
        /// instance of `Overflowed`.
        case int64(Int64)
        /// An overflow occurred while casting a ``UInt64`` to an
        /// instance of `Overflowed`.
        case uint64(UInt64)
    }
}
