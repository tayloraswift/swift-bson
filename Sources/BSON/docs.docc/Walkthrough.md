# BSON Decoding and Encoding, Explained

This article walks through the process of implementing ``BSONDocumentDecodable`` and ``BSONDocumentEncodable`` conformances for a model type in detail, and explains the rationale behind library’s design decisions.


## Decoding

BSON is a serialization format, so when you receive BSON, you almost always want to decode it into a **model type**.


### Decoding with Codable (Legacy API)

Many Swift users are familiar with the ``Decodable`` protocol, which is a format-agnostic deserialization system native to the Swift standard library. The swift-bson library provides compatibility shims for the ``Decodable`` protocol in the ``BSONLegacy`` module.

Here’s an example definition of a ``Decodable`` model type named `BooleanContainer`:

@Snippet(id: Walkthrough, slice: LEGACY_DECODABLE)

Here’s how you would decode an instance of `BooleanContainer` from a BSON Document:

@Snippet(id: Walkthrough, slice: LEGACY_DECODING)

And here’s the output you would see if you printed the decoded instance:

```text
BooleanContainer(b: true)
```

The Legacy API does not currently support encoding.


## Decoding with the BSON API

The format-agnostic ``Decodable`` protocol has well-known performance limitations, so the swift-bson library provides a set of BSON-specific serialization protocols for high-throughput use cases.

Below is a slightly more complex model type, `ExampleModel`, which has three stored properties: `id`, `name`, and `rank`. The `name` property is optional, and the `rank` property is a custom enum type with a ``RawRepresentable/RawValue`` of type ``Int32``.

@Snippet(id: Walkthrough, slice: EXAMPLE_MODEL_DEFINITION)

The bare minimum a type needs to decode itself from BSON is a ``BSONDecodable`` conformance. Many standard library types, such as ``Int32`` and ``Int64``, are already ``BSONDecodable``.


### Decodability protocols

The ``BSONDecodable`` protocol has a derived protocol named ``BSONDocumentDecodable``. Since we expect `ExampleModel` to appear as a BSON document, it is much easier to write a conformance against ``BSONDocumentDecodable`` than ``BSONDecodable``, because the former provides error handling and field indexing for free.


### Defining schema

Unlike the Legacy API, ``BSONDocumentDecodable`` requires an explicit schema definition in the form of a ``BSONDocumentDecodable/CodingKey``. This type must be ``RawRepresentable`` and backed by a ``String``. Moreover, because it can appear in error diagnostics, it must also be ``Sendable``, as ``Error`` itself requires ``Sendable``.

@Snippet(id: Walkthrough, slice: EXAMPLE_MODEL_CODING_KEY)

It’s good practice to use single-letter key names in the `CodingKey` ABI for two reasons.

1.  BSON always stores document keys inline, so long keys can increase file size (and memory usage) substantially.

2.  Single-letter keys are more resilient to schema changes, as you can change the property names in the model type without breaking the database ABI.


### Decoding fields

The interface for decoding documents is the ``BSON.DocumentDecoder`` type.

Types that conform to ``BSONDocumentDecodable`` must implement the ``BSONDocumentDecodable/init(bson:) [requirement]`` requirement. This initializer receives a ``BSON.DocumentDecoder`` keyed by the `CodingKey` type you provide.

To access a non-optional field, subscript the decoder with the field key and call the ``BSON.TracingDecoder/decode(to:)`` method. This method will throw an error with an attached diagnostic trace if the field is missing or has the wrong type.

To access an optional field, chain the subscript with the optional chaining operator (`?`) before calling ``BSON.TracingDecoder/decode(to:)``.

@Snippet(id: Walkthrough, slice: EXAMPLE_MODEL_DECODABLE)

This won’t compile just yet, because the `rank` property has type `Rank`, and we haven’t conformed it to ``BSONDecodable`` yet. So the last step is to make `Rank` conform to ``BSONDecodable`` by leveraging its existing ``RawRepresentable`` conformance.

@Snippet(id: Walkthrough, slice: EXAMPLE_MODEL_RANK_DECODABLE)

Because ``Int32`` is already ``BSONDecodable``, we don’t need to write any code to satisfy the conformance requirements.


## Encoding with the BSON API

Once you have implemented the decoding logic, you are already two-thirds of the way to making a model type round-trippable.

All that’s left in this example is to conform `ExampleModel.Rank` to ``BSONEncodable``, and write the encoding logic for `ExampleModel`’s ``BSONDocumentEncodable.encode(to:) [requirement]`` witness.

@Snippet(id: Walkthrough, slice: EXAMPLE_MODEL_RANK_ENCODABLE)


### Encoding fields

The interface for encoding documents is the ``BSON.DocumentEncoder`` type.

The library passes an instance of this type `inout` to your ``BSONDocumentEncodable/encode(to:) [requirement]`` witness. For maximum performance, it writes key-value pairs immediately to the BSON output stream when you assign to its subscripts. This means the order that the fields appear in the output document is determined by the order in which they were encoded in the encoding function.

@Snippet(id: Walkthrough, slice: EXAMPLE_MODEL_ENCODABLE)

The code looks simple, but the encoding syntax is quite powerful. When assigning to ``BSON.DocumentEncoder.subscript(_:) -> Value?``’s setter, nil values become no-ops. This means that the `name` property will not be encoded if it is `nil`, which is almost always what we want.

You can also get a little more creative with the encoding logic. In this example, we also elide the `rank` field if the model’s rank is `newModel`, to match the behavior of the decoding function, which infers a default rank of `newModel` if the field is missing. This could be profitable if `newModel` were a very common value for `rank`, and we wanted to save space by not encoding it.

>   Tip:
>   Avoid going overboard with model-level transformations in the encoding and decoding logic. Excessive transformations can make database queries more complex and harder to understand. You may also discover that “sensible” defaults are not so sensible after all, which could force you into a difficult schema migration down the line.


## Putting It All Together

Here’s an example of how to round-trip an instance of `ExampleModel` through the BSON API:

@Snippet(id: Walkthrough, slice: PUTTING_IT_ALL_TOGETHER)

When you run this code, you should see the following output:

```text
ExampleModel(id: 1, name: Optional("AAA"), rank: topModel)
ExampleModel(id: 1, name: Optional("AAA"), rank: topModel)
```
