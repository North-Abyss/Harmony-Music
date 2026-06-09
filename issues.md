# Issues Tracking

This file tracks ongoing issues, feature requests, and bug reports for faster clearance without needing to switch context to an external issue tracker.

---



## 🐛 Bugs

### 1. Build fails on Chrome (web target)
- **Priority**: Medium
- **Status**: Open (Known Limitation)
- **Description**: `flutter run -d chrome` fails due to multiple packages using `dart:ffi` which is unavailable on the web platform.
- **Affected packages**: `audiotags`, `jni`, `smtc_windows`, `media_kit_libs_linux`
- **Notes**: Web support would require conditional imports or web-compatible alternatives for these packages.

---

## ✅ Resolved

### 1. Lyrics Reload button does not work
- **Fix**: Added a `reloadLyrics()` method in `PlayerController` to bypass local Hive cache and fetch synced lyrics forcefully via LRCLib, with a dedicated reload button in `LyricsSwitch`.
- **Files changed**: `player_controller.dart`, `synced_lyrics_service.dart`, `lyrics_switch.dart`

### 2. Lyrics translate to english option
- **Fix**: Added `translateLyrics()` in `PlayerController` using the Google Translate API, and mapped it to a new Translate button on the lyrics screen.
- **Files changed**: `player_controller.dart`, `lyrics_switch.dart`

### 3. Keyboard shortcuts for all controls
- **Fix**: Wrapped the Home Scaffold in `CallbackShortcuts` and linked Space, Arrow keys, and Media keys to their respective player controls (play/pause, volume up/down, seek forward/back).
- **Files changed**: `home.dart`, `player_controller.dart`

### 1. Update setting app info to both the og repo and say this repo as new continuer and update readme
- **Fix**: Updated `README.md` and `lib/ui/screens/Settings/settings_screen.dart` to clearly state that this is a continued fork maintained by North-Abyss, while keeping credits to the original developer anandnet.
- **Files changed**: `README.md`, `lib/ui/screens/Settings/settings_screen.dart`, `lib/utils/helper.dart`, `lib/ui/widgets/new_version_dialog.dart`, `lib/models/playlist.dart`

### 1. YouTube Music search not working (Returns empty results)
- **Fix**: Updated `music_service.dart` to parse `itemSectionRenderer` as the YouTube Music search API recently changed its structure and stopped wrapping results in `musicShelfRenderer`.
- **Files changed**: `lib/services/music_service.dart`

### 2. `ionicons` package breaks with Flutter 3.44+ (IconData is final)
- **Fix**: Removed `ionicons` dependency, replaced with Material Icons (`Icons.shuffle`, `Icons.play_circle`, `Icons.ondemand_video`).
- **Files changed**: `pubspec.yaml`, `player_control.dart`, `mini_player.dart`, `gesture_player.dart`, `songinfo_bottom_sheet.dart`

### 2. `DialogTheme` type mismatch with Flutter 3.44+
- **Fix**: Changed `DialogTheme(...)` to `DialogThemeData(...)` in `theme_controller.dart:307`.

### 3. CMake mimalloc extraction fails with spaces in project path
- **Fix**: Patched `media_kit_libs_linux` CMakeLists.txt (line 93) — removed inner escaped quotes from tar extraction command.
- **Note**: This is a patch to the pub cache; will be overridden on `flutter pub cache clean`. Consider renaming the project directory or waiting for upstream fix.
