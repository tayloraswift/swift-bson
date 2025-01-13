import BSONABI

extension BSON.List:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:BSON.AnyValue...)
    {
        self.init(elements: arrayLiteral)
    }
}
