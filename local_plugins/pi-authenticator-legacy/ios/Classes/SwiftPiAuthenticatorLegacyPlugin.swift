import Flutter
import UIKit

public class SwiftPiAuthenticatorLegacyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "it.netknights.piauthenticator.legacy", binaryMessenger: registrar.messenger())
    let instance = SwiftPiAuthenticatorLegacyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    //print("HANDLE \(call.method)")
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
                    if key.starts(with: "firebaseconfig") {}
                    else if (key.starts(with: "privacyidea.authenticator")){}
                    else if (key.starts(with: "app_v3_")){}
                        
                    // Gather the public and private keys to merge with the push token at the end
                    else if key.starts(with: "piPub")  {
                        let val = String(data: value, encoding: .utf8)
                        pubsDict[key.replacingFirstOccurrence(of: "piPub", with: "")] = val
                    }
                    else if key.starts(with: "private") {
                        let val = String(data: value, encoding: .utf8)
                        privsDict[key.replacingFirstOccurrence(of: "private", with: "")] = val
                    }
                    else {
                        // Do nothing for normal token
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
                    if type == "pipush" {
                        if let serial = dict["serial"] as! String? {
                            dict["privateTokenKey"] = privsDict[serial]?.trimmingCharacters(in: .whitespacesAndNewlines)
                            dict["publicServerKey"] = pubsDict[serial]?.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    else if(type == "hotp" || type == "totp") {
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
                    }
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
            //print("Empty result, returning empty string")
            result("")
        } else {
            retJSONArray.removeLast(2)
            retJSONArray.append(contentsOf: "]")
            //print("retJSONArray: \(retJSONArray)")
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
    default:
        result("")
        break;
    }
  }
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

//  The following funcions are taken from:
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
public func base32Encode(_ data: Data) -> String {
    return data.withUnsafeBytes({ (ptr : UnsafeRawBufferPointer) in
        base32encode(ptr.baseAddress!, data.count, alphabetEncodeTable)
    })
}
