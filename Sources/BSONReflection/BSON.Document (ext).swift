import BSON

extension BSON.Document
{
    func description(indent:BSON.Indent) -> String
    {
        if  self.isEmpty
        {
            return "[:]"
        }
        do
        {
            var string:String = indent.level == 0 ? "{" : "\(indent){"
            var items:BSON.KeyspaceDecoder<BSON.Key> = self.parsed()
            while let next:BSON.FieldDecoder<BSON.Key> = try items[+]
            {
                (indent + 1).print(key: next.key, value: next.value, to: &string)
            }
            string += "\(indent)}"
            return string
        }
        catch
        {
            return "{ corrupted }"
        }
    }
}
extension BSON.Document:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.Document
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements. Returns false if either operand fails to parse.
    ///
    /// Some documents that do not compare equal under byte-wise
    /// `==` comparison may compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a ``BSON.AnyValue/string(_:)`` value with the same contents.
    @inlinable public static
    func ~~ (a:Self, b:Self) -> Bool
    {
        var a:BSON.KeyspaceDecoder<BSON.Key> = a.parsed()
        var b:BSON.KeyspaceDecoder<BSON.Key> = b.parsed()
        loop: do
        {
            switch (try a[+], try b[+])
            {
            case (let a?, let b?):
                if  a.key == b.key, a.value ~~ b.value
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
extension BSON.Document
{
    /// Recursively parses and re-encodes this document, and any embedded documents
    /// (and list-documents) in its elements. The keys will not be changed or re-ordered.
    @inlinable public
    func canonicalized() throws -> Self
    {
        var canonical:[(BSON.Key, BSON.AnyValue)] = []
        var elements:BSON.KeyspaceDecoder<BSON.Key> = self.parsed()
        while let next:BSON.FieldDecoder<BSON.Key> = try elements[+]
        {
            canonical.append((next.key, try next.value.canonicalized()))
        }
        return .init(fields: canonical)
    }
}
