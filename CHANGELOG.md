# Changelog

## [3.2.0] - 2021-XX-XX

### Added

- Registered app to handle 'otpauth' links on Android and iOS

### Changed

- Updated plugins
- Replaced deprecated plugins for app theme and QR-code scanning
- Refactored for better life-cycle handling
- Use new framework for localizations and translations
- Migrated app to null-safety
- Added debug-'flavor' to allow parallel install of release and debug version on Android
- Add default firebase configuration for app

### Removed

- Removed support for custom firebase projects for non-SLA customers

## [3.1.1] - 2021-03-31

### Fixed

- Fixed attempt ui update on non-existing elements
- Fixed parsing of token issuer and label

## [3.1.0] - 2021-02-09

### Added

- Added error reporting to the application. Uncaught errors can be voluntarily send to support via e-mail. 

## [3.0.12] - 2021-02-09

### Added

- Added missing German translations for synchronizing push tokens

### Changed

- Notification with sound is shown when the app is open now too
- Synchronized progress indicator of totp tokens
- Migrating tokens from app versions prior to 3.0.0 is now a manual process accessible in the settings
- Synchronization of push tokens can be canceled

### Fixed

- Fixed errors occurring by automatic migration of tokens from prior versions by removing automatic migration
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


[3.2.0]: https://github.com/privacyidea/pi-authenticator/compare/vX.X.X...v3.2.0
[3.1.1]: https://github.com/privacyidea/pi-authenticator/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.12...v3.1.0
[3.0.12]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.8...v3.0.12
[3.0.8]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.7...v3.0.8
[3.0.7]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.6...v3.0.7
[3.0.6]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.4...v3.0.6
[3.0.4]: https://github.com/privacyidea/pi-authenticator/compare/v3.0.0...v3.0.4
