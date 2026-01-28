# Changelog

All notable changes since release will be documented in this file.

## [1.2.0] - 2026-01-28

## Fixed
- Correct visible action count calculation in three panels layout.
- Fixed a bug that did not update receiver's limit when changed on Settings.

## Added
- Added user platform detection.
- Added the ability to select files from the app's local storage for sending.
- Added user blocking feature.
- Added direct pairing feature via manual entry of local IP address.
- Enable folder opening in file explorer on Windows platforms.
- Add remote control feature to allow controlling another device's screen from Android to Windows.

## Changed
- Rename app to "P2Lan" and package to "dev.trongajtt.p2lan".
- Improve compact layout.
- Simplify transfer tab switching, not scroll to bottom anymore.
- Remove batch expand state feature from P2P settings and UI.

## Note
- This version also has integrated screen sharing, but it is hardcoded disabled by default because of incompatibility. You need to toggle it in the code so as to to test it.

## [1.1.0] - 2025-08-09

## Added
- Indicators to distinguish between incoming and outgoing transfer tasks.
- A toggle button to switch the view between incoming tasks, outgoing tasks, or both.
- A new setting in the General section to control whether tasks are cleared at app startup.
- A new setting in the General section to automatically check for updates once per day.
- A new “Author’s Productions” view on the About page.
- Internet connectivity checks added to the Supporters’ view page, Terms page, Check New Version page, and Author’s Productions page.

## Changed
- Completed task cleanup is now disabled by default.
- Transfer tasks are now fully saved to the database.

## [1.0.1], [1.0.2] - 2025-08-06

Hotfix

### Fixed
- The request for nearby Wi-Fi devices was moved to Android 13, so Android 12 devices are no longer asked for a non-existent permission.
- Fixed an issue where the update feature failed to find new updates.

## [1.0.0] - 2025-08-05

First release of the app.

### Added
- **Direct P2P sharing**: Send files directly between devices on the same network
- **Multiple file support**: Share multiple files at once
- **Resume capability**: Continue interrupted transfers where they left off
- **Transfer history**: Keep track of your recent file transfers
- **Simple messaging**: Send text messages between connected devices
- **Clipboard sync**: Automatically share clipboard content between devices
- **Media sharing**: Send images through chat with preview
- **Chat customization**: Configure clipboard sharing and auto-delete options
- **Security options**: Choose between no encryption, AES-GCM, or ChaCha20-Poly1305
- **Compression settings**: Reduce transfer time with configurable compression
- **Network configuration**: Customize network discovery and transfer settings
- **User interface**: Switch between normal and compact layout modes
- **Responsive design**: Adapts to different screen sizes (mobile/desktop)
- **Theme support**: Light, dark, and system theme options
- **Multi-language**: Available in English and Vietnamese
- **Settings persistence**: Your preferences are saved automatically