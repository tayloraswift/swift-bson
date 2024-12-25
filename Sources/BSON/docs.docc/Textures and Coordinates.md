# Textures and Coordinates

Coordinate buffers are a specialized use case that is nevertheless critical to master when using BSON in resource-constrained systems.

THIS IS A WORK IN PROGRESS

### Binary Data

BSON documents can embed arbitrary binary data. This is extremely useful for storing trivial repeating values like RGB colors or 3D coordinates. This can save an enormous amount of keying overhead, at the cost of making the data un-queryable, as the database will not understand your custom data format.

#### Endianness

Although most real-world systems are little-endian, you should always assume that your data will be read by and written from systems with varying endianness.

To help you avoid making mistakes, the swift-bson library provides the ``BSON.BinaryBuffer`` and ``BSON.BinaryArray`` abstractions. The latter, which accounts for endianness, is layered on top of the former, which does not. The ``BSON.BinaryPackable`` protocol serves as the bridge between the two.

### Binary Buffers

A ``BSON.BinaryBuffer``
