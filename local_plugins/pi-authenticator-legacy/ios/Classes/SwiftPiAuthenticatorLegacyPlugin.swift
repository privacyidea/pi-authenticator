import Flutter
import UIKit
import SwiftyRSA

public class SwiftPiAuthenticatorLegacyPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "it.netknights.piauthenticator.legacy", binaryMessenger: registrar.messenger())
        let instance = SwiftPiAuthenticatorLegacyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    let pubKeyAttr: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String:      4096,
         kSecAttrKeyClass as String:           kSecAttrKeyClassPublic]
    
    let privKeyAttr: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
         kSecAttrKeySizeInBits as String:      4096,
         kSecAttrKeyClass as String:           kSecAttrKeyClassPrivate]
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("HANDLE \(call.method)")
        switch call.method {
        case "load_all_tokens":
            let query: [String: Any] = [
                kSecClass as String : kSecClassGenericPassword,
                kSecReturnData as String  : kCFBooleanTrue as Any,
                kSecReturnAttributes as String : kCFBooleanTrue as Any,
                kSecReturnRef as String : kCFBooleanTrue as Any,
                kSecMatchLimit as String : kSecMatchLimitAll
            ]
            
            var resultObj: AnyObject?
            
            let lastResultCode = withUnsafeMutablePointer(to: &resultObj) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }
            
            var tokens = [String]()
            var pubsDict = [String:String]()
            var privsDict = [String:String]()
            
            if lastResultCode == noErr {
                let array = resultObj as? Array<Dictionary<String, Any>>
                for item in array! {
                    if let key = item[kSecAttrAccount as String] as? String,
                        let value = item[kSecValueData as String] as? Data {
                        
                        // Do not touch data that was saved by the new app or metadata
                        if (key.starts(with: "firebaseconfig") || key.starts(with: "privacyidea.authenticator")
                            || key.starts(with: "app_v3_") || key.starts(with: "private") || key.starts(with: "piPub")) {}
                            
                        // Gather the public and private keys to merge with the push token at the end
                        /*else if key.starts(with: "piPub")  {
                            let val = String(data: value, encoding: .utf8)
                            pubsDict[key.replacingFirstOccurrence(of: "piPub", with: "")] = val
                        }
                        else if key.starts(with: "private") {
                            let val = String(data: value, encoding: .utf8)
                            privsDict[key.replacingFirstOccurrence(of: "private", with: "")] = val
                        } */
                        else {
                            if let tokenstr = String(data: value, encoding:.utf8) {
                                tokens.append(tokenstr.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                        }
                    }
                }
            }
            
            var retJSONArray:String = "["
            
            // Adjust the loaded token to have the format that is expected by the new app
            for t in tokens {
                do {
                    var dict = try JSONSerialization.jsonObject(with: t.data(using: .utf8)!, options:[]) as! [String:Any]
                    if let type = dict["type"] as! String? {
                        if (type == "hotp" || type == "totp") {
                            // The secret of these token types has to be decoded using the jsondecoder first, because it contains the raw serialized data
                            // Then it can be encoded to a base32 String which is what the new app expects
                            if let secretString = dict["secret"] as! String? {
                                // Just decode the secret, not the whole token
                                struct Secret: Codable {
                                    var secret: Data
                                }
                                let json = "{\"secret\":\"" + secretString + "\"}"
                                let secretData: Data = json.data(using: .utf8)!
                                let decoder = JSONDecoder()
                                if let decoded = try? decoder.decode(Secret.self, from: secretData) {
                                    let b32 = base32Encode(decoded.secret)
                                    dict["secret"] = b32
                                }
                            }
                        }  /*else if type == "pipush" {
                            if let serial = dict["serial"] as! String? {
                                dict["privateTokenKey"] = privsDict[serial]?.trimmingCharacters(in: .whitespacesAndNewlines)
                                dict["publicServerKey"] = pubsDict[serial]?.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        } */
                    }
                    
                    let completed = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let tokenStr = String(bytes: completed, encoding: .utf8)!
                    //print("Completed Token: \(tokenStr)")
                    retJSONArray.append(tokenStr)
                    retJSONArray.append(contentsOf: ", ")
                } catch let error {
                    print(error)
                }
            }
            
            if (retJSONArray.count < 2) {
                print("Empty result, returning empty string")
                result("")
            } else {
                retJSONArray.removeLast(2)
                retJSONArray.append(contentsOf: "]")
                print("retJSONArray: \(retJSONArray)")
                result(retJSONArray)
            }
            break;
            
        case "load_firebase_config":
            var ret:String = ""
            
            let query: [String: Any] = [
                kSecClass as String : kSecClassGenericPassword,
                kSecReturnData as String  : kCFBooleanTrue as Any,
                kSecReturnAttributes as String : kCFBooleanTrue as Any,
                kSecReturnRef as String : kCFBooleanTrue as Any,
                kSecMatchLimit as String : kSecMatchLimitAll
            ]
            
            var thisResult: AnyObject?
            
            let lastResultCode = withUnsafeMutablePointer(to: &thisResult) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }
            
            if lastResultCode == noErr {
                let array = thisResult as? Array<Dictionary<String, Any>>
                
                for item in array! {
                    if let key = item[kSecAttrAccount as String] as? String,
                        let value = item[kSecValueData as String] as? Data {
                        if key.starts(with: "firebaseconfig") {
                            if var val = String(data: value, encoding: .utf8) {
                                val = val.trimmingCharacters(in: .whitespacesAndNewlines)
                                val = val.replacingFirstOccurrence(of: "\"appID\"", with: "\"appid\"")
                                val = val.replacingFirstOccurrence(of: "\"projNumber\"", with: "\"projectnumber\"")
                                val = val.replacingFirstOccurrence(of: "\"projID\"", with: "\"projectid\"")
                                val = val.replacingFirstOccurrence(of: "\"api_key\"", with: "\"apikey\"")
                                ret = val
                                break
                            }
                        }
                    }
                }
            }
            //print("Returning legacy firebase config: \(ret)")
            result(ret)
            break;
            
        case "sign":
            var ret: String? = nil
            // [serial, message]
            if let args = call.arguments as? [String:Any] {
                let serial = args["serial"] as? String
                let message = args["message"] as? String
                
                if (serial == nil || message == nil) {
                    print("missing argument for signing \(call.arguments ?? "empty")")
                }
                
                if let privateKeyStr = getEntryForSerial("private"+serial!) {
                    if let privateKeyData = stringToNSData(privateKeyStr) {
                        var error: Unmanaged<CFError>?
                        if let privateKey = SecKeyCreateWithData(privateKeyData, privKeyAttr as CFDictionary, &error) {
                            do {
                                let msg = try ClearMessage(string: message!, using: .utf8)
                                let key = try PrivateKey(reference: privateKey)
                                let signature = try msg.signed(with: key, digestType: .sha256)
                                let data = signature.data
                                ret = base32Encode(data)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            
            print("Returning \(ret ?? "empty string")")
            result(ret)
            break;
            
        case "verify":
            var verified: Bool = false
            
            if let args = call.arguments as? [String:Any] {
                // [serial, signedData, signature]
                let serial = args["serial"] as? String
                let signedData = args["signedData"] as? String
                let signatureb32 = args["signature"] as? String
                
                if (serial == nil || signedData == nil || signatureb32 == nil) {
                    print("missing argument for verification \(call.arguments ?? "empty")")
                }
                
                if let publicKeyStr = getEntryForSerial("piPub"+serial!) {
                    if let publicKeyData = stringToNSData(publicKeyStr) {
                        var error: Unmanaged<CFError>?
                        if let publicKey = SecKeyCreateWithData(publicKeyData, pubKeyAttr as CFDictionary, &error) {
                            do {
                                let sign = Signature(data: base32DecodeToData(signatureb32!)!)
                                let clear = try  ClearMessage(string: signedData!, using: .utf8)
                                let pubKey = try PublicKey(reference: publicKey)
                                
                                verified = try clear.verify(with: pubKey, signature: sign, digestType: .sha256)
                            } catch {
                                print("validation error \(error.localizedDescription)")
                                //return false
                            }
                        } else {
                            print("SecKeyCreateWithData failed with \(error.debugDescription)")
                        }
                    }
                }
            }
            print("Returning \(verified)")
            result(verified)
            break;
            
        default:
            result("")
            break;
        }
    }
}

private func stringToNSData(_ str: String) -> NSData? {
    return NSData(base64Encoded: str,
                  options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
}

public func getEntryForSerial(_ serial: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String : kSecClassGenericPassword,
        kSecReturnData as String  : kCFBooleanTrue as Any,
        kSecReturnAttributes as String : kCFBooleanTrue as Any,
        kSecReturnRef as String : kCFBooleanTrue as Any,
        kSecMatchLimit as String : kSecMatchLimitAll
    ]
    
    var thisResult: AnyObject?
    
    let lastResultCode = withUnsafeMutablePointer(to: &thisResult) {
        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    var ret:String? = nil
    if lastResultCode == noErr {
        let array = thisResult as? Array<Dictionary<String, Any>>
        for item in array! {
            if let key = item[kSecAttrAccount as String] as? String,
                let value = item[kSecValueData as String] as? Data {
                if key.starts(with: serial) {
                    if let val = String(data: value, encoding: .utf8) {
                        ret = val
                        break
                    }
                }
            }
        }
    }
    return ret;
}

public func clearKeychain() {
    let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
    for itemClass in secItemClasses {
        let spec: NSDictionary = [kSecClass: itemClass]
        SecItemDelete(spec)
    }
}

extension String {
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
}

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}

//
//  Base32.swift
//  TOTP
//
//  Created by 野村 憲男 on 1/24/15.
//
//  Copyright (c) 2015 Norio Nomura
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

// https://tools.ietf.org/html/rfc4648

// MARK: - Base32 Data <-> String

public func base32Encode(_ data: Data) -> String {
    return data.withUnsafeBytes({ (ptr : UnsafeRawBufferPointer) in
        base32encode(ptr.baseAddress!, data.count, alphabetEncodeTable)
    })
}

public func base32HexEncode(_ data: Data) -> String {
    return data.withUnsafeBytes({ (ptr : UnsafeRawBufferPointer) in
        base32encode(ptr.baseAddress!, data.count, extendedHexAlphabetEncodeTable)
    })
}

public func base32DecodeToData(_ string: String) -> Data? {
    return base32decode(string, alphabetDecodeTable).flatMap {
        Data(bytes: UnsafePointer<UInt8>($0), count: $0.count)
    }
}

public func base32HexDecodeToData(_ string: String) -> Data? {
    return base32decode(string, extendedHexAlphabetDecodeTable).flatMap {
        Data(bytes: UnsafePointer<UInt8>($0), count: $0.count)
    }
}

// MARK: - Base32 [UInt8] <-> String

public func base32Encode(_ array: [UInt8]) -> String {
    return base32encode(array, array.count, alphabetEncodeTable)
}

public func base32HexEncode(_ array: [UInt8]) -> String {
    return base32encode(array, array.count, extendedHexAlphabetEncodeTable)
}

public func base32Decode(_ string: String) -> [UInt8]? {
    return base32decode(string, alphabetDecodeTable)
}

public func base32HexDecode(_ string: String) -> [UInt8]? {
    return base32decode(string, extendedHexAlphabetDecodeTable)
}

// MARK: extensions

extension String {
    // base32
    public var base32DecodedData: Data? {
        return base32DecodeToData(self)
    }
    
    public var base32EncodedString: String {
        return utf8CString.withUnsafeBufferPointer {
            base32encode($0.baseAddress!, $0.count - 1, alphabetEncodeTable)
        }
    }
    
    public func base32DecodedString(_ encoding: String.Encoding = .utf8) -> String? {
        return base32DecodedData.flatMap {
            String(data: $0, encoding: .utf8)
        }
    }
    
    // base32Hex
    public var base32HexDecodedData: Data? {
        return base32HexDecodeToData(self)
    }
    
    public var base32HexEncodedString: String {
        return utf8CString.withUnsafeBufferPointer {
            base32encode($0.baseAddress!, $0.count - 1, extendedHexAlphabetEncodeTable)
        }
    }
    
    public func base32HexDecodedString(_ encoding: String.Encoding = .utf8) -> String? {
        return base32HexDecodedData.flatMap {
            String(data: $0, encoding: .utf8)
        }
    }
}

extension Data {
    // base32
    public var base32EncodedString: String {
        return base32Encode(self)
    }
    /*
     public var base32EncodedData: Data {
     return base32EncodedString.dataUsingUTF8StringEncoding
     }
     */
    public var base32DecodedData: Data? {
        return String(data: self, encoding: .utf8).flatMap(base32DecodeToData)
    }
    
    // base32Hex
    public var base32HexEncodedString: String {
        return base32HexEncode(self)
    }
    /*
     public var base32HexEncodedData: Data {
     return base32HexEncodedString.dataUsingUTF8StringEncoding
     }
     */
    public var base32HexDecodedData: Data? {
        return String(data: self, encoding: .utf8).flatMap(base32HexDecodeToData)
    }
}

// MARK: - private

// MARK: encode

let alphabetEncodeTable: [Int8] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7"].map { (c: UnicodeScalar) -> Int8 in Int8(c.value) }

let extendedHexAlphabetEncodeTable: [Int8] = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V"].map { (c: UnicodeScalar) -> Int8 in Int8(c.value) }

private func base32encode(_ data: UnsafeRawPointer, _ length: Int, _ table: [Int8]) -> String {
    if length == 0 {
        return ""
    }
    var length = length
    
    var bytes = data.assumingMemoryBound(to: UInt8.self)
    
    let resultBufferSize = Int(ceil(Double(length) / 5)) * 8 + 1    // need null termination
    let resultBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: resultBufferSize)
    var encoded = resultBuffer
    
    // encode regular blocks
    while length >= 5 {
        encoded[0] = table[Int(bytes[0] >> 3)]
        encoded[1] = table[Int((bytes[0] & 0b00000111) << 2 | bytes[1] >> 6)]
        encoded[2] = table[Int((bytes[1] & 0b00111110) >> 1)]
        encoded[3] = table[Int((bytes[1] & 0b00000001) << 4 | bytes[2] >> 4)]
        encoded[4] = table[Int((bytes[2] & 0b00001111) << 1 | bytes[3] >> 7)]
        encoded[5] = table[Int((bytes[3] & 0b01111100) >> 2)]
        encoded[6] = table[Int((bytes[3] & 0b00000011) << 3 | bytes[4] >> 5)]
        encoded[7] = table[Int((bytes[4] & 0b00011111))]
        length -= 5
        encoded = encoded.advanced(by: 8)
        bytes = bytes.advanced(by: 5)
    }
    
    // encode last block
    var byte0, byte1, byte2, byte3, byte4: UInt8
    (byte0, byte1, byte2, byte3, byte4) = (0,0,0,0,0)
    switch length {
    case 4:
        byte3 = bytes[3]
        encoded[6] = table[Int((byte3 & 0b00000011) << 3 | byte4 >> 5)]
        encoded[5] = table[Int((byte3 & 0b01111100) >> 2)]
        fallthrough
    case 3:
        byte2 = bytes[2]
        encoded[4] = table[Int((byte2 & 0b00001111) << 1 | byte3 >> 7)]
        fallthrough
    case 2:
        byte1 = bytes[1]
        encoded[3] = table[Int((byte1 & 0b00000001) << 4 | byte2 >> 4)]
        encoded[2] = table[Int((byte1 & 0b00111110) >> 1)]
        fallthrough
    case 1:
        byte0 = bytes[0]
        encoded[1] = table[Int((byte0 & 0b00000111) << 2 | byte1 >> 6)]
        encoded[0] = table[Int(byte0 >> 3)]
    default: break
    }
    
    // padding
    let pad = Int8(UnicodeScalar("=").value)
    switch length {
    case 0:
        encoded[0] = 0
    case 1:
        encoded[2] = pad
        encoded[3] = pad
        fallthrough
    case 2:
        encoded[4] = pad
        fallthrough
    case 3:
        encoded[5] = pad
        encoded[6] = pad
        fallthrough
    case 4:
        encoded[7] = pad
        fallthrough
    default:
        encoded[8] = 0
        break
    }
    
    // return
    if let base32Encoded = String(validatingUTF8: resultBuffer) {
        #if swift(>=4.1)
        resultBuffer.deallocate()
        #else
        resultBuffer.deallocate(capacity: resultBufferSize)
        #endif
        return base32Encoded
    } else {
        #if swift(>=4.1)
        resultBuffer.deallocate()
        #else
        resultBuffer.deallocate(capacity: resultBufferSize)
        #endif
        fatalError("internal error")
    }
}

// MARK: decode

let __: UInt8 = 255
let alphabetDecodeTable: [UInt8] = [
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x20 - 0x2F
    __,__,26,27, 28,29,30,31, __,__,__,__, __,__,__,__,  // 0x30 - 0x3F
    __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x40 - 0x4F
    15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x50 - 0x5F
    __, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,  // 0x60 - 0x6F
    15,16,17,18, 19,20,21,22, 23,24,25,__, __,__,__,__,  // 0x70 - 0x7F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
]

let extendedHexAlphabetDecodeTable: [UInt8] = [
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x00 - 0x0F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x10 - 0x1F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x20 - 0x2F
    0, 1, 2, 3,  4, 5, 6, 7,  8, 9,__,__, __,__,__,__,  // 0x30 - 0x3F
    __,10,11,12, 13,14,15,16, 17,18,19,20, 21,22,23,24,  // 0x40 - 0x4F
    25,26,27,28, 29,30,31,__, __,__,__,__, __,__,__,__,  // 0x50 - 0x5F
    __,10,11,12, 13,14,15,16, 17,18,19,20, 21,22,23,24,  // 0x60 - 0x6F
    25,26,27,28, 29,30,31,__, __,__,__,__, __,__,__,__,  // 0x70 - 0x7F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x80 - 0x8F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0x90 - 0x9F
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xA0 - 0xAF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xB0 - 0xBF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xC0 - 0xCF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xD0 - 0xDF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xE0 - 0xEF
    __,__,__,__, __,__,__,__, __,__,__,__, __,__,__,__,  // 0xF0 - 0xFF
]


private func base32decode(_ string: String, _ table: [UInt8]) -> [UInt8]? {
    let length = string.unicodeScalars.count
    if length == 0 {
        return []
    }
    
    // calc padding length
    func getLeastPaddingLength(_ string: String) -> Int {
        if string.hasSuffix("======") {
            return 6
        } else if string.hasSuffix("====") {
            return 4
        } else if string.hasSuffix("===") {
            return 3
        } else if string.hasSuffix("=") {
            return 1
        } else {
            return 0
        }
    }
    
    // validate string
    let leastPaddingLength = getLeastPaddingLength(string)
    if let index = string.unicodeScalars.firstIndex(where: {$0.value > 0xff || table[Int($0.value)] > 31}) {
        // index points padding "=" or invalid character that table does not contain.
        let pos = string.unicodeScalars.distance(from: string.unicodeScalars.startIndex, to: index)
        // if pos points padding "=", it's valid.
        if pos != length - leastPaddingLength {
            print("string contains some invalid characters.")
            return nil
        }
    }
    
    var remainEncodedLength = length - leastPaddingLength
    var additionalBytes = 0
    switch remainEncodedLength % 8 {
    // valid
    case 0: break
    case 2: additionalBytes = 1
    case 4: additionalBytes = 2
    case 5: additionalBytes = 3
    case 7: additionalBytes = 4
    default:
        print("string length is invalid.")
        return nil
    }
    
    // validated
    let dataSize = remainEncodedLength / 8 * 5 + additionalBytes
    
    // Use UnsafePointer<UInt8>
    return string.utf8CString.withUnsafeBufferPointer {
        (data: UnsafeBufferPointer<CChar>) -> [UInt8] in
        var encoded = data.baseAddress!
        
        let result = Array<UInt8>(repeating: 0, count: dataSize)
        var decoded = UnsafeMutablePointer<UInt8>(mutating: result)
        
        // decode regular blocks
        var value0, value1, value2, value3, value4, value5, value6, value7: UInt8
        (value0, value1, value2, value3, value4, value5, value6, value7) = (0,0,0,0,0,0,0,0)
        while remainEncodedLength >= 8 {
            value0 = table[Int(encoded[0])]
            value1 = table[Int(encoded[1])]
            value2 = table[Int(encoded[2])]
            value3 = table[Int(encoded[3])]
            value4 = table[Int(encoded[4])]
            value5 = table[Int(encoded[5])]
            value6 = table[Int(encoded[6])]
            value7 = table[Int(encoded[7])]
            
            decoded[0] = value0 << 3 | value1 >> 2
            decoded[1] = value1 << 6 | value2 << 1 | value3 >> 4
            decoded[2] = value3 << 4 | value4 >> 1
            decoded[3] = value4 << 7 | value5 << 2 | value6 >> 3
            decoded[4] = value6 << 5 | value7
            
            remainEncodedLength -= 8
            decoded = decoded.advanced(by: 5)
            encoded = encoded.advanced(by: 8)
        }
        
        // decode last block
        (value0, value1, value2, value3, value4, value5, value6, value7) = (0,0,0,0,0,0,0,0)
        switch remainEncodedLength {
        case 7:
            value6 = table[Int(encoded[6])]
            value5 = table[Int(encoded[5])]
            fallthrough
        case 5:
            value4 = table[Int(encoded[4])]
            fallthrough
        case 4:
            value3 = table[Int(encoded[3])]
            value2 = table[Int(encoded[2])]
            fallthrough
        case 2:
            value1 = table[Int(encoded[1])]
            value0 = table[Int(encoded[0])]
        default: break
        }
        switch remainEncodedLength {
        case 7:
            decoded[3] = value4 << 7 | value5 << 2 | value6 >> 3
            fallthrough
        case 5:
            decoded[2] = value3 << 4 | value4 >> 1
            fallthrough
        case 4:
            decoded[1] = value1 << 6 | value2 << 1 | value3 >> 4
            fallthrough
        case 2:
            decoded[0] = value0 << 3 | value1 >> 2
        default: break
        }
        
        return result
    }
}
