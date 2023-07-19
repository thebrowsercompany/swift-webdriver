import Foundation

public func isPNG(data: Data) -> Bool {
    // From https://www.w3.org/TR/png/#5PNG-file-signature
    let PNGSignature: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]

    let range: Range = data.range(of: Data(PNGSignature))!
    return range == 0..<8
}
