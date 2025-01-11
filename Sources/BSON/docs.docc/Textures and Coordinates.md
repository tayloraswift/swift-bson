# Textures and Coordinates

BSON documents can embed arbitrary binary data. This is useful for storing trivial repeating values like RGB colors or 3D coordinates, and can save an enormous amount of keying overhead, though at the cost of making the data un-queryable, as the database will not understand your custom data format.

## Endianness

Although most real-world systems are little-endian, you should always assume that your data will be read by and written from systems with varying endianness.

To help you avoid making mistakes, the swift-bson library provides the ``BSON.BinaryBuffer`` and ``BSON.BinaryArray`` abstractions. The latter, which accounts for endianness, is layered on top of the former, which does not. The ``BSON.BinaryPackable`` protocol serves as the bridge between the two.

## Worked Example

Below is a worked example of how to efficiently round trip a mesh of 3D triangles.

### Defining Point and Triangle Types

@Snippet(id: Triangles, slice: POINT)
@Snippet(id: Triangles, slice: TRIANGLE)


### Conforming to ``BSON.BinaryPackable``

@Snippet(id: Triangles, slice: POINT_BINARY_PACKABLE)
@Snippet(id: Triangles, slice: TRIANGLE_BINARY_PACKABLE)


### Defining the Mesh Buffer

@Snippet(id: Triangles, slice: MESH)


### Defining the Top-Level Document

@Snippet(id: Triangles, slice: MESH_CONTAINER)


### Round-tripping the Mesh

@Snippet(id: Triangles, slice: LAZY_ENCODE)
@Snippet(id: Triangles, slice: LAZY_DECODE)
