import BSON
import Testing

@Suite
struct Dictionaries
{
    @Test
    static func Empty() throws
    {
        let container:Container = .init([:])
        let decoded:Container = try container.recode()

        #expect(container.dictionary == decoded.dictionary)
    }

    @Test
    static func One() throws
    {
        let container:Container = .init([5: "five"])
        let decoded:Container = try container.recode()

        #expect(container.dictionary == decoded.dictionary)
    }

    @Test
    static func Many() throws
    {
        let container:Container = .init([
                5: "five",
                6: "six",
                7: "seven",
                8: "eight",
                9: "nine",
                10: "ten",
                11: "eleven",
                12: "twelve",
            ])
        let decoded:Container = try container.recode()

        #expect(container.dictionary == decoded.dictionary)
    }
}
