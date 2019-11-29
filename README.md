# pi-authenticator
OTP Authenticator App for privacyIDEA Authentication Server

The pi-authenticator currently implements support for HOTP and TOTP (30 and 60 seconds). Supported hashing algorithms are SHA-1, SHA-256 and SHA-512.

The App is best used with the
[privacyIDEA Authentication Server](https://github/privacyidea/privacyidea), and supports both Android and iOS.

# Goals

* provide support for scanning qr codes according to the
[Google Authenticator Key URI](https://github.com/google/google-authenticator/wiki/Key-Uri-Format).

* provide a more secure way of enrollment as
specified in our
[smartphone concept](https://github.com/privacyidea/privacyidea/wiki/concept%3A-SmartphoneApp) as well as the [pushtoken](https://github.com/privacyidea/privacyidea/wiki/concept%3A-PushToken) with support for user-configured firebase projects

# Development

We use the [Flutter](https://flutter.dev/) framework for developing our application. This enables us to use a single code base for both Android and iOS, for development itself we use [Android Studio](https://developer.android.com/studio) with the official [Flutter plugin](https://github.com/flutter/flutter-intellij).

# Tests

Tests are located under `app/test`. These can be run from within Android Studio, if the necessary plugins are installed or directly by running `flutter test` at the root of the project. For additional information please view the official [Flutter documentation](https://flutter.dev/docs/testing).

# Contribution

If you want to contribute to this repository you can view the current todos under the issues tab. Ideas and pull requests are much welcome.

For setting up the development environment please visit the official [get startet guide](https://flutter.dev/docs/get-started/install).
