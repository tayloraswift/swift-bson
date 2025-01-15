import BSON

extension BSON
{
    struct KeyedDecoder<Key> where Key:CodingKey
    {
        let codingPath:[any CodingKey]
        let allKeys:[Key]
        let items:[BSON.Key: BSON.AnyValue]

        init(bson:BSON.Document, path:[any CodingKey]) throws
        {
            self.codingPath = path

            var recognizedKeys:[Key] = []
            var items:[BSON.Key: BSON.AnyValue] = [:]
            var bson:BSON.KeyspaceDecoder<BSON.Key> = bson.parsed()
            while let field:BSON.FieldDecoder = try bson[+]
            {
                items[field.key] = field.value

                if  let key:Key = .init(stringValue: field.key.rawValue)
                {
                    recognizedKeys.append(key)
                }
            }

            self.items = items
            self.allKeys = recognizedKeys
        }
    }
}
extension BSON.KeyedDecoder
{
    // local `Key` type may be different from the dictionary’s `Key` type
    func diagnose<T>(_ key:some CodingKey,
        _ decode:(BSON.AnyValue) throws -> T?) throws -> T
    {
        var path:[any CodingKey]
        {
            self.codingPath + CollectionOfOne<any CodingKey>.init(key)
        }
        guard let value:BSON.AnyValue = self.items[.init(key)]
        else
        {
            let context:DecodingError.Context = .init(codingPath: path,
                debugDescription: "key '\(key)' not found")
            throw DecodingError.keyNotFound(key, context)
        }
        do
        {
            if let decoded:T = try decode(value)
            {
                return decoded
            }

            throw DecodingError.init(annotating: BSON.TypecastError<T>.init(
                    invalid: value.type),
                initializing: T.self,
                path: path)
        }
        catch let error
        {
            throw DecodingError.init(annotating: error,
                initializing: T.self,
                path: path)
        }
    }
}

extension BSON.KeyedDecoder:KeyedDecodingContainerProtocol
{
    public
    func contains(_ key:Key) -> Bool
    {
        self.items.keys.contains(.init(key))
    }

    public
    func decode<T>(_:T.Type, forKey key:Key) throws -> T where T:Decodable
    {
        try .init(from: try self.singleValueContainer(forKey: key))
    }
    func decodeNil(forKey key:Key) throws -> Bool
    {
        try self.diagnose(key) { $0.as(BSON.Null.self) != nil }
    }
    public
    func decode(_:Bool.Type, forKey key:Key) throws -> Bool
    {
        try self.diagnose(key) { $0.as(Bool.self) }
    }
    public
    func decode(_:Float.Type, forKey key:Key) throws -> Float
    {
        try self.diagnose(key) { $0.as(Float.self) }
    }
    public
    func decode(_:Double.Type, forKey key:Key) throws -> Double
    {
        try self.diagnose(key) { $0.as(Double.self) }
    }
    public
    func decode(_:String.Type, forKey key:Key) throws -> String
    {
        try self.diagnose(key) { $0.as(String.self) }
    }
    public
    func decode(_:Int.Type, forKey key:Key) throws -> Int
    {
        try self.diagnose(key) { try $0.as(Int.self) }
    }
    public
    func decode(_:Int64.Type, forKey key:Key) throws -> Int64
    {
        try self.diagnose(key) { try $0.as(Int64.self) }
    }
    public
    func decode(_:Int32.Type, forKey key:Key) throws -> Int32
    {
        try self.diagnose(key) { try $0.as(Int32.self) }
    }
    public
    func decode(_:Int16.Type, forKey key:Key) throws -> Int16
    {
        try self.diagnose(key) { try $0.as(Int16.self) }
    }
    public
    func decode(_:Int8.Type, forKey key:Key) throws -> Int8
    {
        try self.diagnose(key) { try $0.as(Int8.self) }
    }
    public
    func decode(_:UInt.Type, forKey key:Key) throws -> UInt
    {
        try self.diagnose(key) { try $0.as(UInt.self) }
    }
    public
    func decode(_:UInt64.Type, forKey key:Key) throws -> UInt64
    {
        try self.diagnose(key) { try $0.as(UInt64.self) }
    }
    public
    func decode(_:UInt32.Type, forKey key:Key) throws -> UInt32
    {
        try self.diagnose(key) { try $0.as(UInt32.self) }
    }
    public
    func decode(_:UInt16.Type, forKey key:Key) throws -> UInt16
    {
        try self.diagnose(key) { try $0.as(UInt16.self) }
    }
    public
    func decode(_:UInt8.Type, forKey key:Key) throws -> UInt8
    {
        try self.diagnose(key) { try $0.as(UInt8.self) }
    }

    func superDecoder() throws -> any Decoder
    {
        try self.singleValueContainer(forKey: Super.super, typed: Super.self)
    }
    public
    func superDecoder(forKey key:Key) throws -> any Decoder
    {
        try self.singleValueContainer(forKey: key) as any Decoder
    }

    public
    func singleValueContainer<T>(forKey key:T,
        typed _:T.Type = T.self) throws -> BSON.SingleValueDecoder
        where T:CodingKey
    {
        let value:BSON.AnyValue = try self.diagnose(key){ $0 }
        let decoder:BSON.SingleValueDecoder = .init(value,
            path: self.codingPath + CollectionOfOne<any CodingKey>.init(key))
        return decoder
    }
    public
    func nestedUnkeyedContainer(forKey key:Key) throws -> any UnkeyedDecodingContainer
    {
        let path:[any CodingKey] = self.codingPath + CollectionOfOne<any CodingKey>.init(key)
        let container:BSON.UnkeyedDecoder =
            try .init(try self.diagnose(key) { try .init(bson: $0) }, path: path)
        return container as any UnkeyedDecodingContainer
    }
    public
    func nestedContainer<NestedKey>(keyedBy _:NestedKey.Type,
        forKey key:Key) throws -> KeyedDecodingContainer<NestedKey>
    {
        let path:[any CodingKey] = self.codingPath + CollectionOfOne<any CodingKey>.init(key)
        let container:BSON.KeyedDecoder<NestedKey> = try .init(
            bson: try self.diagnose(key) { try BSON.Document.init(bson: $0) },
            path: path)
        return .init(container)
    }
}
