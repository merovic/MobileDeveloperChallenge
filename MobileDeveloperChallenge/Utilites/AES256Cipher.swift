//
//  MobileDeveloperChallengeApp.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 10/08/2024.
//

import CryptoKit
import Foundation
import Security

enum AESError: Error {
    case keySizeError
    case keyDataError
    case ivSizeError
    case ivDataError
}

struct AES256Cipher {
    public static func encrypt(_ text: String) -> String? {
        let keyStr = Obfuscator().reveal(key: [113, 64, 72, 112, 82, 91, 82, 94, 83, 64, 0, 40, 103, 45, 91, 12, 81, 83, 65, 114, 68, 20, 38, 6, 10, 0, 2, 2, 18, 4, 122, 96, 42, 7, 90, 85, 5, 17, 115, 64, 20, 124, 92, 15, 3, 6, 3, 18, 80, 120, 55, 121, 82, 12, 1, 7, 77, 114, 19, 66, 37, 84, 15, 81])
        let nonceStr = Obfuscator().reveal(key: [35, 66, 65, 34, 0, 94, 82, 2, 81, 21, 7, 121, 103, 127, 6, 14, 86, 6, 23, 34, 69, 18, 112, 3, 89, 93, 84, 88, 68, 83, 123, 98])

        guard let keyData = Data(hexString: keyStr) else {
            return nil
        }

        guard let nonceData = Data(hexString: nonceStr) else {
            return nil
        }

        guard let passData = text.data(using: .utf8) else {
            return nil
        }

        do {
            let sealedData = try AES.GCM.seal(passData, using: SymmetricKey(data: keyData), nonce: AES.GCM.Nonce(data: nonceData))
            let combinedData = sealedData.ciphertext + sealedData.tag
            UserDefaults.standard.set(sealedData.tag, forKey: "TAG")
            return combinedData.base64EncodedString()
        } catch {
            return nil
        }
    }

    public static func decrypt(encryptedString: String) -> String? {
        guard encryptedString.isEmpty == false else { return nil }

        let keyStr = Obfuscator().reveal(key: [1,3,4,5,6])
        let nonceStr = Obfuscator().reveal(key: [1,3,4,5,6,7])

        guard let keyData = Data(hexString: keyStr) else {
            return nil
        }

        guard let nonceData = Data(hexString: nonceStr) else {
            return nil
        }

        guard let combinedData = Data(base64Encoded: encryptedString) ?? encryptedString.data(using: .utf8) else {
            return nil
        }

        do {
            let (encryptedData, tag) = try extractTagFromCombinedString(encryptedDataWithTag: combinedData)
            do {
                let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonceData), ciphertext: encryptedData, tag: tag)
                let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))
                if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                    return decryptedString
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        } catch {
            return nil
        }
    }

    public static func encryptModel(_ model: Codable) throws -> String? {
        let keyStr = Obfuscator().reveal(key: [113, 64, 72, 112, 82, 91, 82, 94, 83, 64, 0, 40, 103, 45, 91, 12, 81, 83, 65, 114, 68, 20, 38, 6, 10, 0, 2, 2, 18, 4, 122, 96, 42, 7, 90, 85, 5, 17, 115, 64, 20, 124, 92, 15, 3, 6, 3, 18, 80, 120, 55, 121, 82, 12, 1, 7, 77, 114, 19, 66, 37, 84, 15, 81])
        let nonceStr = Obfuscator().reveal(key: [35, 66, 65, 34, 0, 94, 82, 2, 81, 21, 7, 121, 103, 127, 6, 14, 86, 6, 23, 34, 69, 18, 112, 3, 89, 93, 84, 88, 68, 83, 123, 98])

        guard let keyData = Data(hexString: keyStr),
              let nonceData = Data(hexString: nonceStr) else {
            return nil
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(model)
            let sealedData = try AES.GCM.seal(data, using: SymmetricKey(data: keyData), nonce: AES.GCM.Nonce(data: nonceData))
            let combinedData = sealedData.ciphertext + sealedData.tag
            UserDefaults.standard.set(sealedData.tag, forKey: "TAG")
            return combinedData.base64EncodedString()

        } catch {
            return nil
        }
    }

    public static func decryptModel<T: Codable>(_ model: String, as type: T.Type) throws -> T? {
        guard model.isEmpty == false else { return nil }

        let keyStr = Obfuscator().reveal(key: [113, 64, 72, 112, 82, 91, 82, 94, 83, 64, 0, 40, 103, 45, 91, 12, 81, 83, 65, 114, 68, 20, 38, 6, 10, 0, 2, 2, 18, 4, 122, 96, 42, 7, 90, 85, 5, 17, 115, 64, 20, 124, 92, 15, 3, 6, 3, 18, 80, 120, 55, 121, 82, 12, 1, 7, 77, 114, 19, 66, 37, 84, 15, 81])
        let nonceStr = Obfuscator().reveal(key: [35, 66, 65, 34, 0, 94, 82, 2, 81, 21, 7, 121, 103, 127, 6, 14, 86, 6, 23, 34, 69, 18, 112, 3, 89, 93, 84, 88, 68, 83, 123, 98])

        guard let keyData = Data(hexString: keyStr) else {
            return nil
        }

        guard let nonceData = Data(hexString: nonceStr) else {
            return nil
        }

        guard let combinedData = Data(base64Encoded: model) ?? model.data(using: .utf8) else {
            return nil
        }

        do {
            let (model, tag) = try extractTagFromCombinedString(encryptedDataWithTag: combinedData)
            do {
                let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonceData), ciphertext: model, tag: tag)
                let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: keyData))

                let decoder = JSONDecoder()
                do {
                    let model = try decoder.decode(type.self, from: decryptedData)
                    return model
                } catch {
                    print("Error decoding: \(error)")
                    return nil
                }
            } catch {
                return nil
            }
        } catch {
            return nil
        }
    }

    public static func extractTagFromCombinedString(encryptedDataWithTag: Data) throws -> (encryptedData: Data, tag: Data) {
        let tagSize = 16
        let encryptedData = encryptedDataWithTag.prefix(encryptedDataWithTag.count - tagSize)
        let tag = encryptedDataWithTag.suffix(tagSize)
        return (encryptedData, tag)
    }
}

extension Data {
    init?(hexString: String) {
        let hexString = hexString.replacingOccurrences(of: " ", with: "")
        let length = hexString.count / 2
        var data = Data(capacity: length)

        for i in 0 ..< length {
            let start = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let end = hexString.index(start, offsetBy: 2)
            let range = start ..< end
            let byteString = hexString[range]

            guard let byte = UInt8(byteString, radix: 16) else {
                return nil
            }

            data.append(byte)
        }

        self = data
    }
}
