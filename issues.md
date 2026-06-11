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

## 🚀 Features

*(All requested features have been implemented!)*

---

## ✅ Resolved

### 🚀 New Features
23. **QR Code Sharing and Scanning**: Added a new "QR Code" option to share sheets for songs, albums, and playlists. Integrated `qr_flutter` to dynamically generate QR codes. Added a dedicated `QrScannerScreen` using `flutter_zxing`, accessible directly from both the Desktop and Mobile Search Bars, allowing users to scan any YouTube or Harmony Music QR code to instantly open the corresponding media.
24. **App Store Metadata & Packaging Integration**: Integrated comprehensive App Store metadata across all platforms. Added AppStream metadata (`metainfo.xml`) for Linux software centers (DEB/RPM/AppImage) including screenshots, categories, and descriptions. Appended the project link to the Android fastlane metadata (`full_description.txt`) and ensured Windows `make_config.yaml` has the correct publisher URLs.

### 🖥️ Search & Keyboard Navigation
1. **Search suggestions arrow navigation lacking visual feedback**: Converted `historyIndex` to reactive `RxInt`, wrapped `SearchBar` in `Focus`, and used `Obx` on `SearchItem` to actively highlight the background color as you navigate with arrow keys (like YouTube).
2. **Mini player keyboard focus missing**: Added a dedicated `miniPlayerFocus` node. Pressing `C` or using `Tab` now accurately targets the Mini Player controls when minimized.
3. **Shortcuts menu redesigned**: Transformed the shortcuts menu into a beautiful dialog (`KeyboardShortcutsMenu`) with dynamic keycaps that adapt to `ThemeData`, accessible via `?`.
4. **Keyboard Shortcuts control player and search simultaneously**: Re-structured `_handleKeyEvent` to explicitly ignore global shortcuts if a `TextField` has focus.
5. **Tab key gets trapped in text fields**: Added exceptions so `Tab` toggles UI panels seamlessly even when typing in a search bar.
6. **Keyboard Shortcuts (Tab Toggle)**: Changed `Tab` shortcut to explicitly toggle focus between the Player (`playerFocus`) and Home Screen (`centerPanelFocus`).
7. **Search 'x' button doesn't exit search**: Modified the trailing clear button in the Desktop Search Bar to correctly drop focus alongside resetting the query text.
8. **Keyboard Shortcuts Help Menu**: Added a dedicated section under `Settings -> Misc` detailing player and navigation keybinds.

### 🎵 Player & Media Controls
9. **Lyrics toggle missing globally**: Harmonized the `L` key shortcut and the mini player lyrics button to use the same `LyricsDialog` widget. Re-mapped `showDialog` to `Get.dialog` across the board to prevent glitchy multiple dialogs.
10. **10s seek buttons missing on Desktop/StandardPlayer**: Added visual `+/- 10` second jump buttons explicitly to the `StandardPlayer` control bar. Added `C` key shortcut to explicitly focus the player controls.
11. **UI 10 sec +/- missing on Mobile**: Re-added explicitly visible +/- 10-second seek buttons and a new Lyrics button directly onto the `GesturePlayerScreen` (Android UI).
12. **Double Tap to Seek in Player**: Added `onDoubleTapDown` handler to the `AlbumArtNLyrics` widget. Tapping left seeks backward 10s, right seeks forward 10s.
13. **Lyrics Reload & Translate**: Added `reloadLyrics()` to bypass local Hive cache, and `translateLyrics()` using the Google Translate API.

### 🎨 UI Tweaks & Fixes
14. **ListTile background color or ink splashes invisible**: Wrapped `ListTile` inside `QuickPicksWidget` with a `Material(color: Colors.transparent)` widget. Refactored the `Container` wrapper in `desktop_search_bar.dart` into a `Material` widget to natively support splash rendering and eliminate exceptions.
15. **Esc key quits app**: Removed `exit(0)` from the `Esc` key handler. It now safely pops routes or closes the player panel.
16. **RenderFlex overflow by 4.0 pixels in Home Screen**: Increased the `Container` height in `ContentListItem` from 180 to 200 to prevent text from overflowing.
17. **Share button copy option**: Added "Copy Link" options to all share sections natively (Song info sheet, Playlist, Album, and Artist screens) to complement `Share.share` native menus.

### ⚙️ Dependencies & Core
18. **YouTube Music search returning empty results**: Updated `music_service.dart` to parse `itemSectionRenderer` as the YouTube Music search API recently changed its structure.
19. **`ionicons` package breaks with Flutter 3.44+**: Removed `ionicons` dependency, replaced with Material Icons (`Icons.shuffle`, `Icons.play_circle`, `Icons.ondemand_video`).
20. **`DialogTheme` type mismatch with Flutter 3.44+**: Changed `DialogTheme(...)` to `DialogThemeData(...)` in `theme_controller.dart:307`.
21. **CMake mimalloc extraction fails with spaces**: Patched `media_kit_libs_linux` CMakeLists.txt (line 93) — removed inner escaped quotes from tar extraction command.
22. **Update maintainer info and README**: Updated `README.md` and `lib/ui/screens/Settings/settings_screen.dart` to clearly state that this is a continued fork maintained by North-Abyss.
