import BSON

do
{
    let full:[UInt8] = [
        0x09, 0x00, 0x00, 0x00, //  Document header
        0x08, 0x62, 0x00, 0x01, //  Document body
        0x00                    //  Trailing null byte
    ]
    let bson:BSON.Document = .init(bytes: full[4 ..< 8])

    print(bson)
}
