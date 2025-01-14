import BSON
import UnixTime

extension BSON.AnyValue
{
    func description(indent:BSON.Indent) -> String
    {
        switch self
        {
        case .document(let document):
            document.description(indent: indent)
        case .list(let list):
            list.description(indent: indent)
        case .binary(let binary):
            "{ binary data, type \(binary.subtype.rawValue) }"
        case .bool(let bool):
            "\(bool)"
        case .decimal128(let decimal128):
            "\(decimal128) as BSON.Decimal128"
        case .double(let double):
            "\(double)"
        case .id(let id):
            "\(id)"
        case .int32(let int32):
            "\(int32)"
        case .int64(let int64):
            "\(int64) as Int64"
        case .javascript(let javascript):
            "'\(javascript)'"
        case .javascriptScope(_, _):
            "{ javascript with scope }"
        case .max:
            "max"
        case .millisecond(let millisecond):
            "\(millisecond.index) as UnixMillisecond"
        case .min:
            "min"
        case .null:
            "null"
        case .pointer(let database, let id):
            "\(database) + \(id)"
        case .regex(let regex):
            "\(regex)"
        case .string(let utf8):
            "\"\(utf8)\""
        case .timestamp(let timestamp):
            "\(timestamp)"
        }
    }
}
extension BSON.AnyValue:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.AnyValue:Equatable
{
    /// Performs a type-aware equivalence comparison.
    /// If both operands are a ``document(_:)`` (or ``list(_:)``), performs a recursive
    /// type-aware comparison by calling ``BSON/Document.==(_:_:)``.
    /// If both operands are a ``string(_:)``, performs unicode-aware string comparison.
    /// If both operands are a ``double(_:)``, performs floating-point-aware
    /// numerical comparison.
    ///
    /// >   Warning:
    ///     Comparison of ``decimal128(_:)`` values uses bitwise equality. This library does
    ///     not support decimal equivalence.
    ///
    /// >   Warning:
    ///     Comparison of ``millisecond(_:)`` values uses integer equality. This library does
    ///     not support calendrical equivalence.
    ///
    /// >   Note:
    ///     The embedded document in the deprecated `javascriptScope(_:_:)` variant
    ///     also receives type-aware treatment.
    ///
    /// >   Note:
    ///     The embedded UTF-8 string in the deprecated `pointer(_:_:)` variant
    ///     also receives type-aware treatment.
    @inlinable public
    static func == (a:Self, b:Self) -> Bool
    {
        switch (a, b)
        {
        case (.document     (let a), .document    (let b)):
            a == b
        case (.list         (let a), .list        (let b)):
            a == b
        case (.binary       (let a), .binary      (let b)):
            a == b
        case (.bool         (let a), .bool        (let b)):
            a == b
        case (.decimal128   (let a), .decimal128  (let b)):
            a == b
        case (.double       (let a), .double      (let b)):
            a == b
        case (.id           (let a), .id          (let b)):
            a == b
        case (.int32        (let a), .int32       (let b)):
            a == b
        case (.int64        (let a), .int64       (let b)):
            a == b
        case (.javascript   (let a), .javascript  (let b)):
            a == b
        case (.javascriptScope(let a, let aCode), .javascriptScope(let b, let bCode)):
            aCode == bCode && a == b
        case (.max,                     .max):
            true
        case (.millisecond  (let a), .millisecond (let b)):
            a.index == b.index
        case (.min,                     .min):
            true
        case (.null,                    .null):
            true
        case (.pointer(let a, let aID), .pointer(let b, let bID)):
            aID == bID && a == b
        case (.regex        (let a), .regex       (let b)):
            a == b
        case (.string       (let a), .string      (let b)):
            a == b
        case (.timestamp    (let a), .timestamp   (let b)):
            a == b

        default:
            false
        }
    }
}
extension BSON.AnyValue
{
    /// Recursively parses and re-encodes any embedded documents (and list-documents)
    /// in this variant value.
    @inlinable public
    func canonicalized() throws -> Self
    {
        switch self
        {
        case    .document(let document):
            .document(try document.canonicalized())
        case    .list(let list):
            .list(try list.canonicalized())
        case    .binary,
                .bool,
                .decimal128,
                .double,
                .id,
                .int32,
                .int64,
                .javascript:
            self
        case    .javascriptScope(let scope, let utf8):
            .javascriptScope(try scope.canonicalized(), utf8)
        case    .max,
                .millisecond,
                .min,
                .null,
                .pointer,
                .regex,
                .string,
                .timestamp:
            self
        }
    }
}
