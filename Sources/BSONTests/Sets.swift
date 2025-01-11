import BSON
import Testing

@Suite
struct Sets
{
    @Test
    static func Empty() throws
    {
        let container:Container = .init([])
        let decoded:Container = try container.recode()

        #expect(container.set == decoded.set)
    }

    @Test
    static func One() throws
    {
        let container:Container = .init(["aaa"])
        let decoded:Container = try container.recode()

        #expect(container.set == decoded.set)
    }

    @Test
    static func Many() throws
    {
        let container:Container = .init([
                "aaa",
                "bbb",
                "ccc",
                "ddd",
                "eee",
                "fff",
                "ggg",
                "hhh",
            ])
        let decoded:Container = try container.recode()

        #expect(container.set == decoded.set)
    }
}
