import BSON
import Testing

@Suite
struct DecodeList
{
    private
    enum CodingKey:String, Sendable
    {
        case w
        case x
        case y
        case z
        case heterogenous
    }

    private
    let bson:BSON.DocumentDecoder<CodingKey>

    init() throws
    {
        let bson:BSON.Document = .init(CodingKey.self)
        {
            $0[.w](Int.self) { _ in }
            $0[.x](Int.self) { $0[+] = "a" ; $0[+] = "b" }
            $0[.y](Int.self) { $0[+] = "a" ; $0[+] = "b" ; $0[+] = "c" }
            $0[.z](Int.self) { $0[+] = "a" ; $0[+] = "b" ; $0[+] = "c" ; $0[+] = "d" }
            $0[.heterogenous](Int.self)
            {
                $0[+] = "a"
                $0[+] = "b"
                $0[+] = 0 as Int32
                $0[+] = "d"
            }
        }

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeList
{
    @Test
    func None() throws
    {
        #expect(throws:
            BSON.DecodingError<CodingKey>.init(
                BSON.DocumentKeyError<Int>.undefined(0),
                in: .w))
        {
            try self.bson[.w].decode
            {
                let _:String = try $0[+].decode()
            }
        }
    }

    @Test
    func Two() throws
    {
        try self.bson[.x].decode
        {
            try #expect($0[+].decode() == "a")
            try #expect($0[+].decode() == "b")
            try #expect($0[+] == nil)
        }
    }

    @Test
    func ThreeToTwo() throws
    {
        #expect(throws:
            BSON.DecodingError<CodingKey>.init(
                BSON.DecodingError<Int>.init(
                    BSON.TypecastError<Never>.init(invalid: .string),
                    in: 2),
                in: .y))
        {
            try self.bson[.y].decode
            {
                try #expect($0[+].decode() == "a")
                try #expect($0[+].decode() == "b")

                try $0[+]?.decode(to: Never.self)
            }
        }
    }

    @Test
    func Map() throws
    {
        #expect(try ["a", "b", "c", "d"] == self.bson[.z].decode())
    }

    @Test
    func MapInvalid() throws
    {
        #expect(throws:
            BSON.DecodingError<CodingKey>.init(
                BSON.DecodingError<Int>.init(
                    BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(invalid: .int32),
                    in: 2),
                in: .heterogenous))
        {
            try self.bson[.heterogenous].decode(to: [String].self)
        }
    }

    @Test
    func Element() throws
    {
        try self.bson[.z].decode
        {
            try #expect($0[+] != nil)
            try #expect($0[+] != nil)
            try #expect($0[+].decode() == "c")
        }
    }

    @Test
    func ElementInvalid() throws
    {
        #expect(throws:
            BSON.DecodingError<CodingKey>.init(
                BSON.DecodingError<Int>.init(
                    BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(invalid: .int32),
                    in: 2),
                in: .heterogenous))
        {
            try self.bson[.heterogenous].decode
            {
                try #expect($0[+] != nil)
                try #expect($0[+] != nil)
                return try $0[+].decode(to: String.self)
            }
        }
    }
}
