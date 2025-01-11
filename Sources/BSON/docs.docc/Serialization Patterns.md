# Advanced Serialization Patterns

Level up your BSON encoding skills by learning these composable serialiation patterns. Internalizing these techniques will help you write more efficient and maintainable database applications by avoiding temporary allocations and reusing generic library code.


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

The swift-bson library provides a ``BSONDecodable`` implementation for ``Set`` through ``Set.UnorderedElements``, which can save you an array allocation when performing one-way BSON decoding. Keep in mind though, that round-tripping ``Set`` is bad for cache performance, since the output BSON will be different every time.
