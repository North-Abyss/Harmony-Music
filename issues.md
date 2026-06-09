# Issues Tracking

This file tracks ongoing issues, feature requests, and bug reports for faster clearance without needing to switch context to an external issue tracker.

---

## 🐛 Bugs

### 1. Lyrics Reload button does not work
- **Priority**: High
- **Status**: Open
- **Description**: Lyrics Reload button needed if the lyrics fail to load and happens lot.
- **Notes**: "There is no lyrics reload button on the lyrics screen. It should reload the lyrics when clicked." 

### 2. Build fails on Chrome (web target)
- **Priority**: Medium
- **Status**: Open (Known Limitation)
- **Description**: `flutter run -d chrome` fails due to multiple packages using `dart:ffi` which is unavailable on the web platform.
- **Affected packages**: `audiotags`, `jni`, `smtc_windows`, `media_kit_libs_linux`
- **Notes**: Web support would require conditional imports or web-compatible alternatives for these packages.

---

## ✨ Feature Requests

### 1. Keyboard shortcuts for all controls
- **Priority**: Medium
- **Status**: Open
- **Description**: Add keyboard shortcuts for all playback controls (play/pause, next, previous, volume, seek, etc.) to improve desktop usability.
- **Notes**: Relevant for Linux, Windows, macOS, and Web platforms.

### 2. Lyrics english Translate to english option
- **Priority**: Medium
- **Status**: Open
- **Description**: Lyrics to be in english translation by using opensource lyrics sights or something.
- **Notes**: "There is no lyrics translate to english option on the lyrics screen. It should translate the lyrics to english when clicked."

---

## ✅ Resolved

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
