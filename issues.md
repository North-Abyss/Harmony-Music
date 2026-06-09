# Issues Tracking

This file tracks ongoing issues, feature requests, and bug reports for faster clearance without needing to switch context to an external issue tracker.

---

## 🐛 Bugs

### 1. YouTube Music search not working
- **Priority**: High
- **Status**: Open
- **Description**: Search functionality for YouTube Music is broken — queries return no results or fail silently.
- **Notes**: May be related to `youtube_explode_dart` API changes upstream.

### 2. Build fails on Chrome (web target)
- **Priority**: Medium
- **Status**: Open (Known Limitation)
- **Description**: `flutter run -d chrome` fails due to multiple packages using `dart:ffi` which is unavailable on the web platform.
- **Affected packages**: `audiotags`, `jni`, `smtc_windows`, `media_kit_libs_linux`
- **Notes**: Web support would require conditional imports or web-compatible alternatives for these packages.

### 3. ListTile decoration warnings in debug mode
- **Priority**: Low
- **Status**: Open
- **Description**: Multiple "ListTile background color or ink splashes may be invisible" assertion warnings in debug mode. ListTiles wrapped in DecoratedBox with background color hide ink effects.
- **Notes**: Non-critical — wrap ListTiles in their own Material widget or remove background from DecoratedBox.

---

## ✨ Feature Requests

### 1. Keyboard shortcuts for all controls
- **Priority**: Medium
- **Status**: Open
- **Description**: Add keyboard shortcuts for all playback controls (play/pause, next, previous, volume, seek, etc.) to improve desktop usability.
- **Notes**: Relevant for Linux, Windows, macOS, and Web platforms.

---

## ✅ Resolved

### 1. `ionicons` package breaks with Flutter 3.44+ (IconData is final)
- **Fix**: Removed `ionicons` dependency, replaced with Material Icons (`Icons.shuffle`, `Icons.play_circle`, `Icons.ondemand_video`).
- **Files changed**: `pubspec.yaml`, `player_control.dart`, `mini_player.dart`, `gesture_player.dart`, `songinfo_bottom_sheet.dart`

### 2. `DialogTheme` type mismatch with Flutter 3.44+
- **Fix**: Changed `DialogTheme(...)` to `DialogThemeData(...)` in `theme_controller.dart:307`.

### 3. CMake mimalloc extraction fails with spaces in project path
- **Fix**: Patched `media_kit_libs_linux` CMakeLists.txt (line 93) — removed inner escaped quotes from tar extraction command.
- **Note**: This is a patch to the pub cache; will be overridden on `flutter pub cache clean`. Consider renaming the project directory or waiting for upstream fix.
