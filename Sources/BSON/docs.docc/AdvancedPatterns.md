# Advanced Patterns

Level up your BSON encoding skills by learning these composable serialiation patterns. Internalizing these techniques will help you write more efficient and maintainable database applications by avoiding temporary allocations and reusing generic library code.


## Delegation to Raw Representation

**Delegation to Raw Representation** is one of the most common patterns in BSON encoding. You can use it whenever a ``RawRepresentable`` type has a ``RawRepresentable/RawValue`` that is already ``BSONDecodable`` or ``BSONEncodable``.

@Snippet(id: AdvancedPatterns, slice: RAW_REPRESENTATION)

Delegation to Raw Representation has no dedicated protocols; it is tied directly to ``BSONDecodable`` and ``BSONEncodable`` and is available whenever you conform to one of those protocols.


## Delegation to String Representation

**Delegation to String Representation** is a pattern that allows you to use a type’s ``LosslessStringConvertible`` conformance to define its database representation.

Here’s an example of a type that stores a logical ``String`` and ``Int`` pair, and uses a formatted `host:port` ``String`` representation for encoding and decoding:

@Snippet(id: AdvancedPatterns, slice: STRING_REPRESENTATION)

Delegation to String Representation is not enabled by default. You must opt-in to it by conforming to the ``BSONStringDecodable`` and ``BSONStringEncodable`` protocols.


## Lists and Sequences

TODO

## Arrays of Coordinates

TODO
