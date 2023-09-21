# pi-authenticator
OTP Authenticator App for privacyIDEA Authentication Server

The pi-authenticator currently support HOTP and TOTP (30 and 60 seconds) and also privacyIDEA's PUSH authentication. Supported hashing algorithms are SHA-1, SHA-256 and SHA-512.
It also supports scanning qr codes that match the [Google Authenticator Key URI](https://github.com/google/google-authenticator/wiki/Key-Uri-Format) format.

The App is best used with the [privacyIDEA Authentication Server](https://github.com/privacyidea/privacyidea), and runs on both Android and iOS.
The pi-authenticator can also be configured to support PUSH authentication without Firebase.

# Goals

* provide a more secure way of enrollment as
specified in our
[smartphone concept](https://github.com/privacyidea/privacyidea/wiki/concept%3A-SmartphoneApp) as well as the [pushtoken](https://github.com/privacyidea/privacyidea/wiki/concept%3A-PushToken) with support for user-configured firebase projects

# Development

We use the [Flutter](https://flutter.dev/) framework for developing our application. This enables us to use a single code base for both Android and iOS, for development itself we use [Android Studio](https://developer.android.com/studio) with the official [Flutter plugin](https://github.com/flutter/flutter-intellij).

The app can be build for android by running `flutter build apk [--release | --debug]` at the root of the project, for building the iOS version the command is `flutter build ipa`. Building for iOS requires to run this on an Apple device.
For testing purposes the application can be run in release mode by running `flutter run --release`.

For serializing the model of this application (i.e., the tokens) we use generated files. If the model was changed, run the script `update_serialization.sh` to update the generated files.

Building a version of the app prior to `v4.0.0` requires an old version of flutter, this can be done by, e.g., `git checkout tags/1.22.6`.

# Tests

Tests are located under `app/test`. These can be run from within Android Studio, if the necessary plugins are installed or directly by running `flutter test` at the root of the project. For additional information please view the official [Flutter documentation](https://flutter.dev/docs/testing).

![Unit and widget tests](https://github.com/privacyidea/pi-authenticator/workflows/flutter%20test/badge.svg?branch=master)

![Integrations tests](https://github.com/privacyidea/pi-authenticator/workflows/flutter%20driver/badge.svg?branch=master)

Integrations tests can be run by executing the shell script `run_driver.sh` directly.

# Contribution

If you want to contribute to this repository you can view the current todos under the issues tab. Ideas and pull requests are much welcome.

For setting up the development environment please visit the official [get started guide](https://flutter.dev/docs/get-started/install).

## Translations

If you want to help making this app more accessible for others you can translate this app into your native language.

Two files must be translated for this:

The first one is `pi-authenticator/lib/l10n/app_en.arb` that contains the (default) english translation. For translating the file to french for example, this file must be copied and the suffix must be changed accordingly:`app_fr.arb`. The file contains translations in the form:
~~~~
"otpValueCopiedMessage": "Password \"{otpValue}\" copied to clipboard.",
  "@otpValueCopiedMessage": {
    "description": "Tells the user that the otp value was copied to the clipboard.",
    "type": "text",
    "placeholders": {
      "otpValue": {
        "example": "055374"
      }
    }
  }
~~~~
where the part `Password \"{otpValue}\" copied to clipboard.` must be translated. Special signs such as `\"` and parameters such as `{otpValue}` must not be changed but can be rearanged to fit the translation.

The second file that must be translated is `pi-authenticator/res/guide/GUIDE_en.md`, which must also be copied and the suffix must also be changed, e.g., to `GUIDE_fr.md`. Words that reference the app, such as `Settings`, should be changed in accordance. For links, e.g., `![Manually polling by swiping down](resource:res/gif/help_manual_poll.gif)`, only the text part must be changed. In this case `Manually polling by swiping down`.
