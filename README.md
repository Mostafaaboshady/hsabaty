# Khiat

Khiat is a cross-platform financial management app built with Flutter. It helps users track revenues, expenses, supplies, debts, and manage bank/cash balances. The app supports multiple languages and runs on Windows, Android, iOS, Linux, macOS, and web.

## Features

- Track revenues, expenses, supplies, and debts
- Manage bank and cash balances
- Multi-language support
- Settings and customization
- Cross-platform: Windows, Android, iOS, Linux, macOS, Web

## Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Fetch dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Folder Structure

- `lib/` - Main Dart code (UI, providers, models)
- `android/`, `ios/`, `linux/`, `macos/`, `windows/` - Platform-specific code
- `test/` - Widget and unit tests

## Dependencies

- `provider` - State management
- `sqflite_common_ffi` - SQLite database support (especially for Windows)

## License

Add your license information here.
