# Changelog

## [4.2.0] - TBD
 - Support for daypasswordtokens
 - Added folders to group tokens
 - Added an errorlog menu to settings
 - Token can be sorted per drag and drop now to work with folders
 - Replaced the button to view the onboarding with a button to create a new folder
 - Replaced the splashscreen with a new one
 - Removed migration option from settings
 - Fixed a problem when the Image of a token could not be loaded (no internet connection or wrong url)

## [4.1.1] - 2023-05-12

- Communicate declined push requests to the server 
- Fixed notification permissions for Android 13
- Fixed causes for crashes related to networking

## [4.1.0] - 2022-11-25

### Added

- Push token can be locked
- Polish translation
- 'appimage' field in QR codes will be read and the image will be shown on the left side of the row

### Fixed
- Fixed several causes for app crashes
- Fixed scanning of QR codes which do not adhere strictly to the standard
- Fixed cancellation of scanning process on iOS
- Fixed a problem where each time the onboarding screen was closed, a new main screen was stacked on top the already existing one


## [4.0.0] - 2022-06-13

### Added

- Registered app to handle 'otpauth' links on Android and iOS
- Totp percent indicator
- Improved look and feel
- Onboarding experience
- Reorder token
- Lock tokens by default functionality
- Improved error handling
- Automatically enable poll on push token
- Poll on app resume


### Changed

- Updated plugins
- Replaced deprecated plugins for app theme and QR-code scanning
- Refactored for better life-cycle handling
- Use new framework for localizations and translations
- Migrated app to null-safety
- Added debug-'flavor' to allow parallel install of release and debug version on Android
- Add default firebase configuration for app
- Added option to secure tokens by requiring device credentials or biometrics to access otps and to accept push challenges
- Improvements to the User Interface

### Removed

- Removed support for custom firebase projects


## [3.1.5] - 2021-10-21

### Changed

- Changed error message on failing POST request (due to null values in body) to be more informative
- Generalized custom method for GET requests and added error handling for parameters that are null
- Automatic polling does not get deactivated if no push token exists
- Made error reports more helpful by also reporting the error type besides it's own description

## [3.1.4] - 2021-07-22

### Added

- Added description for why the app need network access on iOS

### Changed

- Changed android api target level to 30
- Subject of error reports now start with version number
- Enable automatic polling per default on all devices (to fix missing push challenges on iOS)
- Reduced automatic polling interval to three (3) seconds

### Fixed

- Fixed failing network request when rolling out push tokens on iOS 14+
- Added fix for null check operator being used on null value in the animation controller for TOTP
  tokens

## [3.1.3] - 2021-06-24

### Added

- Added support for poll-only tokens introduced in privacyIDEA v3.7.+
- Added french translation, thanks to *NicolasB CD48*

### Changed

- Removed error reporting on known exception when push tokens are used but no network connection is
  available
- The issuer of tokens is shown additionally to its label
- The issuer of tokens is parsed from the label part of the otpauth URI also

### Fixed

- Fixed calling animation controller when it doesn't exist
- Fixed error when receiving challenges for non-existing tokens
- Fixed PaddingError on loading tokens on some devices

## [3.1.2] - 2021-04-22

### Fixed

- Fixed broken ui updates for TOTP tokens
- Fixed parsing issues for QR codes
- Fixed error when scanning qr codes is interrupted
- Added fix for secure storage issue, including dialog to inform affected users how to fix the error

## [3.1.1] - 2021-03-31

### Fixed

- Fixed attempt ui update on non-existing elements
- Fixed parsing of token issuer and label

## [3.1.0] - 2021-02-09

### Added

- Added error reporting to the application. Uncaught errors can be voluntarily send to support via
  e-mail.

## [3.0.12] - 2021-02-09

### Added

- Added missing German translations for synchronizing push tokens

### Changed

- Notification with sound is shown when the app is open now too
- Synchronized progress indicator of totp tokens
- Migrating tokens from app versions prior to 3.0.0 is now a manual process accessible in the
  settings
- Synchronization of push tokens can be canceled

### Fixed

- Fixed errors occurring by automatic migration of tokens from prior versions by removing automatic
  migration
- Handle failing synchronization of push tokens by informing the user and closing the dialog
- To prevent bugs, push settings are only accessible if at least one push token is fully enrolled
- Uri encoded characters (e.g. @ as %40) are now correctly displayed for token labels

## [3.0.8] - 2021-01-07

### Added

- Automatic synchronization of push tokens
- Manual synchronization of push tokens through apps settings
- Added user agent property to network requests
- User guide on app start, that explains some functionality

### Changed

- Changed logos in app from png to svg to better support different screen sizes

### Fixed

- Fixed calculation of otp for TOTP tokens with shorter seed length

## [3.0.7] - 2020-11-12

### Fixed

- Fixed showing push notifications that were received when the app is closed
- Fixed deleting expired push request when the app is opened

## [3.0.6] - 2020-11-11

### Added

- Automatic migration of tokens from version prior to 3.0.0
- Push challenges can now be activly polled from the server
- Added option to automatically poll push challenges from server (only when the app is open)

## [3.0.4] - 2020-09-30

### Changed

- Changed internal serialization of the tokens

## 3.0.0 - 2020-09-15

### Added

- Tokens can be renamed or deleted by swiping to the left side of the screen
- Added theme setting to the app, the user can choose between a light and a dark theme

### Changed

- Using new engine to program the app
- parallel development of android and ios version

[4.0.0]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.5...v4.0.0

[3.1.5]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.4...v3.1.5

[3.1.4]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.3...v3.1.4

[3.1.3]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.2...v3.1.3

[3.1.2]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.1...v3.1.2

[3.1.1]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.0...v3.1.1

[3.1.0]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.12...v3.1.0

[3.0.12]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.8...v3.0.12

[3.0.8]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.7...v3.0.8

[3.0.7]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.6...v3.0.7

[3.0.6]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.4...v3.0.6

[3.0.4]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.0...v3.0.4
