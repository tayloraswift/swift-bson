# Serialization Patterns

Level up your BSON encoding skills by learning these composable serialiation patterns. Internalizing these techniques will help you write more efficient and maintainable database applications by avoiding temporary allocations and reusing generic library code.


## Raw Representations

**Delegation to Raw Representation** is one of the most common patterns in BSON encoding. You can use it whenever a ``RawRepresentable`` type has a ``RawRepresentable/RawValue`` that is already ``BSONDecodable`` or ``BSONEncodable``.

@Snippet(id: Patterns, slice: RAW_REPRESENTATION)

Delegation to Raw Representation has no dedicated protocols; it is tied directly to ``BSONDecodable`` and ``BSONEncodable`` and is available whenever you conform to one of those protocols.


## String Representations

**Delegation to String Representation** is a pattern that allows you to use a type’s ``LosslessStringConvertible`` conformance to define its database representation.

Here’s an example of a type that stores a logical ``String`` and ``Int`` pair, and uses a formatted `host:port` ``String`` representation for encoding and decoding:

@Snippet(id: Patterns, slice: STRING_REPRESENTATION)

Delegation to String Representation is not enabled by default. You must opt-in to it by conforming to the ``BSONStringDecodable`` and ``BSONStringEncodable`` protocols.


## Lists and Sequences

The native Swift ``Array`` type is your best friend when working with sequences (See: [Best Practices](#Best-practices)). However, there are rare situations where you may want to use the library’s list abstractions instead.

The serialization of sequences is less symmetrical than the serialization of single values, due to memory allocation concerns.

### Encoding Sequences

The protocol for encoding sequences is ``BSONListEncodable``. Its default implementations are available for any ``Sequence`` with an ``Sequence/Element`` type that is ``BSONEncodable``.

The principal benefit of ``BSONListEncodable`` is that it avoids encoding many temporary BSON entities or any intermediate arrays to hold those temporary BSON fragments.

### Encoding Manually

Many applications will converge on ``Sequence``-powered encoding, as this involves the least amount of total code since your Swift logic likely also wants to use sequences. However, it is also possible to encode BSON lists manually.

The interface for manual ``BSON.List`` encoding is ``BSON.ListEncoder``. The ``BSONListEncodable.encode(to:) [requirement]`` witness you provide receives an instance of this type.

Here’s an example of manual BSON list encoding, which expands every element of a ``Range`` into a list of BSON integers:

@Snippet(id: Patterns, slice: LIST_ENCODING_MANUAL)

The ``BSON.ListEncoder`` type is a powerful interface that also allows you to encode arbitrary nested lists and documents. The example code below encodes alternating nested lists and documents within a larger list:

@Snippet(id: Patterns, slice: LIST_ENCODING_SILLY)

The JSON equivalent to the BSON it would produce would look something like this:

```json
[
    [0, 2], {"M": 0, "P": 2},
    [1, 3], {"M": 1, "P": 3},
    [2, 4], {"M": 2, "P": 4},
    [3, 5], {"M": 3, "P": 5},
]
```

>   Tip:
>   Manual list encoding is most useful when writing BSON DSL code, such as MongoDB queries. It’s not a good idea to use “clever” list formats in your application’s database schema, as this style of code is very hard to organize and maintain.

### Decoding Lists

The interface for decoding BSON lists is ``BSON.ListDecoder``. You receive an instance of this type by conforming to the ``BSONListDecodable`` protocol.

The ``BSON.ListDecoder`` type’s job is to provide a random-access intermediate for list decoding. Thus, it allocates a Swift array internally to index the positions of the list elements within the underlying BSON buffer.

You would usually use ``BSONListDecodable`` when you expect a list of a fixed size, or a length that is a multiple of some fixed stride. Here’s an example of a type `FirstAndLastName` that round-trips a pair of strings:

@Snippet(id: Patterns, slice: LIST_PAIR)

### Best Practices

BSON lists are essentially BSON documents with anonymous keys. The ``BSONListEncodable`` and especially ``BSONListDecodable`` protocols are best suited for schema with positionally-significant list items. However, unlike JSON, encoding with anonymous keys saves no space relative to encoding with named keys, so it just results in schema that is more brittle and harder to evolve.

Some kinds of data, like arrays of RGB colors, are logically well-modeled as lists, but can be represented far more efficiently as [packed binary data](Textures-and-Coordinates).

#### Prefer `Array`

There are few compelling reasons to use ``BSONListEncodable`` or ``BSONListDecodable`` in your schema design.

In virtually all remaining cases, ``Array`` should be your preferred abstraction for representing homogeneous sequences. Its ``BSONDecodable`` implementation is connected directly to the BSON parser, and can populate itself with no intermediate allocations.

#### Avoid Non-deterministic Sequences

Some Swift data structures (such as ``Set``) do not have a deterministic order.

The swift-bson library provides a ``BSONDecodable`` implementation for ``Set`` when the element type is ``BSONDecodable``, as this saves users an array allocation when performing one-way BSON decoding. However, ``Set`` does not have a first-class ``BSONEncodable`` conformance, because it would encode itself differently every time.

You should not attempt to provide this conformance yourself, as this would be terrible for caching and overall application performance, so it’s a very bad idea to round-trip instances of ``Set`` (or similar types) through your models.
