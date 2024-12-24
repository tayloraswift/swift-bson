# ``/BSON``

An umbrella module providing a BSON parser, encoder, and decoder.

## Linking the BSON libraries

This module re-exports the ``BSONABI``, ``BSONEncoding``, ``BSONDecoding``, and ``BSONArrays`` modules. Importing them directly is discouraged.

Some BSON modules (currently ``BSONLegacy`` and ``BSONReflection``) are considered ancillary and are not included in this umbrella module.
