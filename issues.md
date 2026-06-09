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

### 2. UI 10 sec +/-
- **Priority**: Low
- **Status**: Open
- **Description**: the 10-second seek buttons in the player UI need them not present 
- **Affected screens**: `GesturePlayerScreen` (Player UI)


---

## ✅ Resolved

### 1. Keyboard Shortcuts control player and search simultaneously
- **Fix**: Re-structured `_handleKeyEvent` to explicitly ignore global shortcuts if a `TextField` has focus. Arrow keys now only control the player when the player panel is open or focused.
- **Files changed**: `player_controller.dart`

### 2. Double Tap to Seek in Player
- **Fix**: Added `onDoubleTapDown` handler to the `AlbumArtNLyrics` widget. Tapping the left half seeks backward by 10 seconds, right half seeks forward by 10 seconds.
- **Files changed**: `albumart_lyrics.dart`

### 3. Keyboard Shortcuts Help Menu
- **Fix**: Added a dedicated `Keyboard Shortcuts` section under `Settings -> Misc` detailing player and navigation keybinds.
- **Files changed**: `settings_screen.dart`

### 4. Share button copy option
- **Fix**: Added "Copy Link" options to all share sections natively (Song info sheet, Playlist, Album, and Artist screens) to complement `Share.share` native menus.
- **Files changed**: `songinfo_bottom_sheet.dart`, `playlist_screen.dart`, `album_screen.dart`, `artist_screen.dart`

### 5. Lyrics Reload & Translate
- **Fix**: Added `reloadLyrics()` to bypass local Hive cache, and `translateLyrics()` using the Google Translate API. Both are mapped to new buttons on the lyrics screen.
- **Files changed**: `player_controller.dart`, `synced_lyrics_service.dart`, `lyrics_switch.dart`

### 6. Update maintainer info and README
- **Fix**: Updated `README.md` and `lib/ui/screens/Settings/settings_screen.dart` to clearly state that this is a continued fork maintained by North-Abyss, while keeping credits to the original developer anandnet.
- **Files changed**: `README.md`, `lib/ui/screens/Settings/settings_screen.dart`, `lib/utils/helper.dart`, `lib/ui/widgets/new_version_dialog.dart`, `lib/models/playlist.dart`

### 7. YouTube Music search returning empty results
- **Fix**: Updated `music_service.dart` to parse `itemSectionRenderer` as the YouTube Music search API recently changed its structure.
- **Files changed**: `lib/services/music_service.dart`

### 8. `ionicons` package breaks with Flutter 3.44+
- **Fix**: Removed `ionicons` dependency, replaced with Material Icons (`Icons.shuffle`, `Icons.play_circle`, `Icons.ondemand_video`).
- **Files changed**: `pubspec.yaml`, `player_control.dart`, `mini_player.dart`, `gesture_player.dart`, `songinfo_bottom_sheet.dart`

### 9. `DialogTheme` type mismatch with Flutter 3.44+
- **Fix**: Changed `DialogTheme(...)` to `DialogThemeData(...)` in `theme_controller.dart:307`.

### 10. CMake mimalloc extraction fails with spaces in project path
- **Fix**: Patched `media_kit_libs_linux` CMakeLists.txt (line 93) — removed inner escaped quotes from tar extraction command.
- **Note**: This is a patch to the pub cache; will be overridden on `flutter pub cache clean`. Consider renaming the project directory or waiting for upstream fix.
