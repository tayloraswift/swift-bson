import BSON

extension BSON.List
{
    func description(indent:BSON.Indent) -> String
    {
        self.isEmpty ? "[]" : BSON.Document.init(list: self).description(indent: indent)
    }
}
extension BSON.List:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.List:Equatable
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements, ignoring list key names. Returns `false` if either
    /// operand fails to parse.
    ///
    /// Some embedded documents that do not compare equal under byte-wise
    /// `==` comparison may also compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a `BSON//Value.string(_:)` value with the same contents.
    @inlinable public
    static func == (a:Self, b:Self) -> Bool
    {
        var a:BSON.ListDecoder = a.parsed
        var b:BSON.ListDecoder = b.parsed
        loop: do
        {
            switch (try a[+]?.value, try b[+]?.value)
            {
            case (let a?, let b?):
                if  a == b
                {
                    continue loop
                }

                return false

            case (_?, nil), (nil, _?):
                return false

            case (nil, nil):
                return true
            }
        }
        catch
        {
            return false
        }
    }
}
extension BSON.List
{
    /// Recursively parses and re-encodes this list-document, and any embedded documents
    /// (and list-documents) in its elements. The ordinal keys will be regenerated.
    @inlinable public
    func canonicalized() throws -> Self
    {
        var canonical:[BSON.AnyValue] = []
        var elements:BSON.ListDecoder = self.parsed
        while let next:BSON.FieldDecoder<Int> = try elements[+]
        {
            canonical.append(try next.value.canonicalized())
        }
        return .init(elements: canonical)
    }
}
