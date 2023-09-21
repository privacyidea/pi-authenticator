#import "PiAuthenticatorLegacyPlugin.h"
#if __has_include(<pi_authenticator_legacy/pi_authenticator_legacy-Swift.h>)
#import <pi_authenticator_legacy/pi_authenticator_legacy-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pi_authenticator_legacy-Swift.h"
#endif

@implementation PiAuthenticatorLegacyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPiAuthenticatorLegacyPlugin registerWithRegistrar:registrar];
}
@end
