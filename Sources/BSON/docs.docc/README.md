# ``/BSON``

An umbrella module providing a BSON parser, encoder, and decoder.

## Topics

### Tutorials

-   <doc:Examples>
-   <doc:Walkthrough>
-   <doc:Serialization-Patterns>
-   <doc:Textures-and-Coordinates>


## Concepts

BSON, like JSON, is a recursive data structure with two native **container** types: ``BSON/Document`` (or object) and ``BSON/List`` (or array). A complete BSON “file” is generally understood to consist of a single top-level container, usually a document.


### Document Structure

When embedded as subtrees, BSON containers are bracketed by a **header** and a **trailing null byte**. The header is always four bytes long. The headers and trailers surrounding **nested containers** are needed for efficiently traversal of the BSON syntax tree, but don’t have any functional significance at the top level, so we usually strip them from the root node.

The snippet below contains a full BSON document — including the header and trailing null byte — in the variable `full`. The ``BSON/Document.init(bytes:)`` initializer expects a bare document without the header or trailing null byte, so we slice `full` before passing it to the initializer.

@Snippet(id: DocumentStructure, slice: DOCUMENT_STRUCTURE)

If we print the document, we see it contains a single key-value pair, `b: true`.

```text
{
    $0[b] = true
}
```


### No Eager Parsing

Unlike JSON parsing, BSON parsing is always lazy. This saves a tremendous amount of memory when decoding data from BSON. Thus, ``BSON/Document`` is nothing but a thin wrapper around a byte buffer.

This means that a document may contain corrupted subtrees. Indeed, the entire document may be corrupted, and this will not raise an error until the actual decoding takes place. If the corrupted fields are never accessed by a ``Decoder``, no error will be raised.


## Linking the BSON libraries

This module re-exports the ``BSONABI``, ``BSONEncoding``, ``BSONDecoding``, and ``BSONArrays`` modules. Importing them directly is discouraged.

Some BSON modules (currently ``BSONLegacy`` and ``BSONReflection``) are considered ancillary and are not included in this umbrella module.
