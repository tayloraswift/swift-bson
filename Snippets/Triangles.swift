import BSON

//  snippet.POINT
struct Point3D
{
    var x:Float
    var y:Float
    var z:Float
}
//  snippet.end
extension Point3D:CustomStringConvertible
{
    var description:String { "(\(self.x), \(self.y), \(self.z))" }
}

//  snippet.TRIANGLE
struct Triangle3D
{
    var a:Point3D
    var b:Point3D
    var c:Point3D
}
//  snippet.end
extension Triangle3D:CustomStringConvertible
{
    var description:String { "[\(self.a), \(self.b), \(self.c)]" }
}

//  snippet.POINT_BINARY_PACKABLE
extension Point3D:BSON.BinaryPackable
{
    typealias Storage = (UInt32, UInt32, UInt32)

    static func get(_ storage:Storage) -> Self
    {
        .init(x: .get(storage.0), y: .get(storage.1), z: .get(storage.2))
    }

    consuming func set() -> Storage
    {
        (self.x.set(), self.y.set(), self.z.set())
    }
}
//  snippet.TRIANGLE_BINARY_PACKABLE
extension Triangle3D:BSON.BinaryPackable
{
    typealias Storage = (Point3D.Storage, Point3D.Storage, Point3D.Storage)

    static func get(_ storage:Storage) -> Self
    {
        .init(a: .get(storage.0), b: .get(storage.1), c: .get(storage.2))
    }

    consuming func set() -> Storage
    {
        (self.a.set(), self.b.set(), self.c.set())
    }
}
//  snippet.end

//  snippet.MESH
struct Mesh3D
{
    let triangles:[Triangle3D]
}
extension Mesh3D:BSONArrayEncodable, RandomAccessCollection
{
    var startIndex:Int { self.triangles.startIndex }
    var endIndex:Int { self.triangles.endIndex }

    subscript(position:Int) -> Triangle3D { self.triangles[position] }
}
extension Mesh3D:BSONArrayDecodable
{
    init(from array:borrowing BSON.BinaryArray<Triangle3D>) throws
    {
        self.triangles = array.map(\.self)
    }
}

//  snippet.MESH_CONTAINER
struct MeshContainer<Value> where Value:BSONEncodable, Value:BSONDecodable
{
    let value:Value

    enum CodingKey:String, Sendable
    {
        case value = "V"
    }
}
extension MeshContainer:BSONDocumentEncodable, BSONDocumentDecodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.value] = self.value
    }

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.value = try bson[.value].decode()
    }
}
//  snippet.end

do
{
    //  snippet.LAZY_ENCODE
    let triangles:[Triangle3D] = [
        .init(
            a: .init(x: 0, y: 0, z: 0),
            b: .init(x: 1, y: 0, z: 0),
            c: .init(x: 0, y: 1, z: 0)),
        .init(
            a: .init(x: 1, y: 0, z: 0),
            b: .init(x: 1, y: 1, z: 0),
            c: .init(x: 0, y: 1, z: 0)),
    ]

    let mesh:MeshContainer<Mesh3D> = .init(value: .init(triangles: triangles))
    let meshEncoded:BSON.Document = .init(encoding: mesh)
    let meshDecoded:MeshContainer<Mesh3D> = try .init(bson: meshEncoded)

    print(meshDecoded.value.triangles)

    //  snippet.LAZY_DECODE
    let trianglesEagerlyEncoded:BSON.BinaryArray<Triangle3D> = triangles.indices.reduce(
        into: .init(count: triangles.count))
    {
        $0[$1] = triangles[$1]
    }
    let view:MeshContainer<BSON.BinaryArray<Triangle3D>> = .init(
        value: trianglesEagerlyEncoded)
    let viewEncoded:BSON.Document = .init(encoding: view)
    let viewDecoded:MeshContainer<BSON.BinaryArray<Triangle3D>> = try .init(
        bson: viewEncoded)

    for triangleLazilyDecoded:Triangle3D in viewDecoded.value
    {
        print(triangleLazilyDecoded)
    }
    //  snippet.end
}
