import Flutter
import UIKit

public class SwiftPiAuthenticatorLegacyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pi_authenticator_legacy", binaryMessenger: registrar.messenger())
    let instance = SwiftPiAuthenticatorLegacyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // This function handels method calls,
  // TODO
  //  get name of method
  //  get parameters
  //  return result || error
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
