import Flutter
import UIKit

public class SwiftPiAuthenticatorLegacyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    print("REGISTER")
    let channel = FlutterMethodChannel(name: "it.netknights.piauthenticator.legacy", binaryMessenger: registrar.messenger())
    let instance = SwiftPiAuthenticatorLegacyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("HANDLE")
    print(call.method)
    switch call.method {
    case "load_all_tokens":
        print("call method=load_all_tokens")
        
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
                    if key.starts(with: "firebaseconfig") {
                    }
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
                        tokens.append(String(data: value, encoding:.utf8)!.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
            }
        }
        
        var retJSONArray:String = "["
        
        for t in tokens {
            do {
                var dict = try JSONSerialization.jsonObject(with: t.data(using: .utf8)!, options:[]) as! [String:Any]
                if dict["type"] as! String == "pipush" {
                    let serial:String = dict["serial"] as! String
                    dict["privateTokenKey"] = privsDict[serial]
                    dict["publicServerKey"] = pubsDict[serial]
                }
                // TODO rename things?
                
                let completed = try JSONSerialization.data(withJSONObject: dict, options: [])
                let tokenStr = String(bytes: completed, encoding: .utf8)!
                print("Completed Token: \(tokenStr)")
                retJSONArray.append(tokenStr)
                retJSONArray.append(contentsOf: ", ")
            } catch let error {
                print(error)
            }
        }
        retJSONArray.removeLast(2)
        retJSONArray.append(contentsOf: "]")
        
        print("retJSONArray: \(retJSONArray)")
        result(retJSONArray)
        
        break;
        
    case "load_firebase_config":
        print("call method=load_firebase_config")
        var ret:String? = nil
        
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
                        var val = String(data: value, encoding: .utf8)
                        print("Found firebase config: \(val ?? "empty string")")
                        val = val?.trimmingCharacters(in: .whitespacesAndNewlines)
                        val = val?.replacingFirstOccurrence(of: "\"projNumber\"", with: "\"projectnumber\"")
                        val = val?.replacingFirstOccurrence(of: "\"projID\"", with: "\"projectid\"")
                        val = val?.replacingFirstOccurrence(of: "\"api_key\"", with: "\"apikey\"")
                        ret = val
                        break
                    }
                }
            }
        }
        result(ret)
        break;
    default:
        result(nil)
        break;
    }
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
