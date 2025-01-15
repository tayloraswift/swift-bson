# BSON Usage Examples

Using BSON in production generally consists of three kinds of tasks: defining root types that model the documents you want to store as BSON, defining reusable supporting types to model fields in other types, and actually encoding and decoding BSON documents to and from binary data.


## Modeling Documents

To model a document, you must provide a ``BSONDocumentEncodable/CodingKey``, an ``BSONDocumentEncodable/encode(to:) [requirement]`` witness, and a ``BSONDocumentDecodable/init(bson:) [requirement]`` witness.

The two conformances are theoretically independent, though you will almost always want to implement both at the same time. Below is an example of a model type with two fields, `id` and `name`.

@Snippet(id: Examples, slice: MODEL)

In the rest of these examples, we’ll omit the `CodingKey` definitions unless they are truly interesting.

### Optionals

When encoding optional fields, the encoder stays the same, as ``BSON.DocumentEncoder.subscript(_:) -> Value?`` will simply omit the field if the assigned value is nil.

In the initializer, you should chain the accessed field with the optional chaining operator (`?`) before calling ``BSON.TracingDecoder/decode(to:)``. If you omit this, the decoder will throw an error if the field is missing.

@Snippet(id: Examples, slice: MODEL_OPTIONAL)


### Arrays

Native Swift arrays will encode themselves as BSON lists. Some applications find it convenient to elide list fields if they are empty, and this can be expressed concisely as shown below.

@Snippet(id: Examples, slice: MODEL_LIST)


### Sets and Dictionaries

For many applications, serializing ``Dictionary`` is problematic because its key-value pairs do not have a deterministic order. This is bad for caching. ``Set`` suffers from a similar problem. That said, both types are still round-trippable provided their elements are themselves round-trippable.

@Snippet(id: Examples, slice: MODEL_UNORDERED)

The ``Dictionary`` conformance is only available when the dictionary’s key type conforms to ``BSON.Keyspace``. This protocol refines ``RawRepresentable``, and imposes the additional semantic requirement that the ``RawRepresentable.rawValue`` string must not contain null bytes.

>   Important:
>   Returning a string with null bytes from ``BSON.Keyspace.rawValue`` will crash at runtime, because null bytes in document keys can be exploited to perform SQL injection attacks against MongoDB.


### Nested Documents

Any type that conforms to ``BSONEncodable`` and ``BSONDecodable`` can be used as a field in another type. Since ``BSONDocumentEncodable`` and ``BSONDocumentDecodable`` refine those respective protocols, this means any BSON model type can be used as a field in another BSON model type.

@Snippet(id: Examples, slice: MODEL_NESTED)


### Explicit Null Values

The distinction between a field that is missing and a field that is explicitly ``BSON.AnyValue/null`` is usually irrelevant, but if you need to distinguish between the two cases, supply the decoded type explicitly to ``BSON.TracingDecoder/decode(to:)``. This will fail with an error if the field is present, but contains a ``BSON.AnyValue/null`` value.

@Snippet(id: Examples, slice: MODEL_NULL)

If you don’t supply the type explicitly, the Swift compiler will infer a default type of `String?.Type` because the result of the call is being assigned to an optional. ``Optional``’s own conditional conformance to ``BSONDecodable`` maps ``BSON.AnyValue/null`` to ``Optional.none``, which is what you usually want instead.


## Primitive Types

The library provides conformances for a number of primitives.

| Primitive | Encodable? | Decodable? |
| --------- | ---------- | ---------- |
| ``Bool`` | ✓ | ✓ |
| ``Int32`` | ✓ | ✓ |
| ``Int64`` | ✓ | ✓ |
| ``Double`` | ✓ | ✓ |
| ``String`` | ✓ | ✓ |
| ``UnixMillisecond`` | ✓ | ✓ |
| ``BSON.Decimal128`` | ✓ | ✓ |
| ``BSON.Identifier`` | ✓ | ✓ |
| ``BSON.Timestamp`` | ✓ | ✓ |
| ``BSON.Regex`` | ✓ | ✓ |
| ``BSON.Max`` | ✓ | ✓ |
| ``BSON.Min`` | ✓ | ✓ |
| ``BSON.Null`` | ✓ | ✓ |

Prefer ``UnixMillisecond`` over ``BSON.Timestamp`` when representing dates.


### Integers and Floats

Although they are not all primitives, the library provides ``BSONDecodable`` conformances for all Swift integer types.

Integers of bit width less than 32 bits are round-trippable, but they will be represented as ``Int32`` in the database, so there is no storage benefit to using them.

| Primitive | Encodable? | Decodable? |
| --------- | ---------- | ---------- |
| ``Int`` | ✓ | ✓ |
| ``Int8`` | ✓ | ✓ |
| ``Int16`` | ✓ | ✓ |
| ``UInt8`` | ✓ | ✓ |
| ``UInt16`` | ✓ | ✓ |
| ``UInt32`` |   | ✓ |
| ``UInt64`` |   | ✓ |
| ``UInt`` |   | ✓ |
| ``Float`` |   | ✓ |

It is generally not a good idea to use ``UInt32``, ``UInt64``, or ``UInt`` in BSON schema. Unsigned integers can be encoded losslessly as their respective signed integer types, but they will sort incorrectly in MongoDB.

Similarly, ``Float`` is decodable, but not round-trippable. This is an inherent characteristic of IEEE-754 floating-point numbers, one example of which is `sNaN(0x1)` which will decode to `NaN(0x1)` if converted to ``Double``.

The library also provides overlays for the dimensional types from the ``UnixTime`` module.

| Primitive | Encodable? | Decodable? |
| --------- | ---------- | ---------- |
| ``Milliseconds`` | ✓ | ✓ |
| ``Seconds`` | ✓ | ✓ |
| ``Minutes`` | ✓ | ✓ |


### Strings and Characters

As a natural extension of the ``String`` primitive, the library provides error-handling conformances for ``Character`` and ``Unicode.Scalar``.


| Primitive | Encodable? | Decodable? |
| --------- | ---------- | ---------- |
| ``Substring`` | ✓ | ✓ |
| ``Character`` | ✓ | ✓ |
| ``Unicode.Scalar`` | ✓ | ✓ |

There is no performance benefit to decoding ``Substring`` instead of ``String``, as both will involve copying the underlying storage. However, using ``Substring`` over ``String`` may save some applications a buffer copy on the encoding side.


### Abstractions

``Never`` is abstractly round-trippable, which is useful in generic contexts.

Swift’s native lazy sequences are conditionally encodable, which can help avoid unnecessary allocations in some situations.

| Primitive | Encodable? | Decodable? |
| --------- | ---------- | ---------- |
| ``Never`` | ✓ | ✓ |
| ``LazyMapSequence`` | ✓ |   |
| ``LazyFilterSequence`` | ✓ |   |
| ``LazyDropWhileSequence`` | ✓ |   |
| ``LazyPrefixWhileSequence`` | ✓ |   |


## Custom Types

To encode and decode custom types, you must directly or indirectly implement the ``BSONEncodable.encode(to:) [requirement]`` and ``BSONDecodable.init(bson:) [requirement]`` requirements. The vast majority of custom types can obtain these witnesses via ``RawRepresentable`` or ``LosslessStringConvertible``.


### Delegation to Raw Representation

You can delegate to ``RawRepresentable`` whenever a type has a ``RawRepresentable/RawValue`` that is already ``BSONDecodable`` or ``BSONEncodable``.

@Snippet(id: Examples, slice: RAW_REPRESENTATION)


### Delegation to String Representation

You can delegate to ``LosslessStringConvertible`` to use a type’s ``String`` representation as its database representation.

Here’s an example of a type that stores a logical ``String`` and ``Int`` pair, and uses a formatted `host:port` string representation for encoding and decoding:

@Snippet(id: Examples, slice: STRING_REPRESENTATION)

Unlike delegation to raw representation, delegation to string representation is not enabled by default. You must opt-in to it by conforming to the ``BSONStringDecodable`` and ``BSONStringEncodable`` protocols.


## Converting to and from Raw Data

A complete BSON “file” is generally understood to consist of a single top-level container, usually a document.

### Binding to a Document

The snippet below contains a full BSON document — including the header and trailing null byte — in the variable `full`. We usually omit the top-level wrapper when storing BSON on disk, and this is the portion the ``BSON/Document.init(bytes:)`` initializer expects, so we slice `full` before binding it to `document`.

@Snippet(id: DocumentStructure, slice: BINDING)

Keep in mind that binding to a document performs no parsing, since the whole point of BSON is to do as little parsing as possible, as late as possible.


### Parsing a Document

To parse a document, pass it to ``BSONDocumentDecodable.init(bson:) (BSON.Document)``.

@Snippet(id: DocumentStructure, slice: DECODING)


### Serializing a Document

To serialize a model type, pass it to ``BSON.Document.init(encoding:) (BSONDocumentEncodable)``. You can then get the underlying ``ArraySlice`` of bytes from ``BSON.Document.bytes``.

@Snippet(id: DocumentStructure, slice: ENCODING)

