# Harmony Music V1.13.0 🎵
We are thrilled to announce the highly anticipated v1.13.0 release! This update brings robust cross-platform stability, native fallback architectures, and major UX improvements for power users.

### 🚀 Key Features & Improvements
* **Cross-Platform QR Scanner:** Added a fully native QR Code Scanner using hardware cameras!
* **Linux Fallback Architecture:** Automatically detects if your Linux desktop lacks webcam drivers and provides a seamless "Scan from Image File" fallback.
* **YouTube-Style Search Navigation:** You can now use the `Arrow Up` and `Arrow Down` keys to seamlessly scroll through your search history and YouTube auto-complete suggestions.
* **Expanded Context Menus:** Added a quick "Copy Link" button natively into the song info bottom sheet.

### 🐛 Bug Fixes & Stability
* **Escape Key Crash Resolved:** Fixed a critical bug on desktop where pressing `Escape` closed the entire application. It now gracefully closes menus and dialogs as expected.
* **Multi-Camera Selector:** Added a dropdown to swap between front and rear cameras to prevent initialization crashes on multi-lens devices.
* **Scroll Physics:** Overhauled the desktop side-rail navigation to use ClampingScrollPhysics for a more grounded desktop feel.
* **Version Update Checker:** Improved version string parsing to correctly handle `v` prefixes, ensuring update prompts reliably appear when a new GitHub release is published.
* **Player UI Pixel Overflow Fixed:** Placed the +/- 10s seek buttons perfectly front-and-back of the progress bar and shifted the progress timestamps to the sides, fixing the RenderFlex overflow errors on narrow pane layouts.
* **Systematic Backup Names:** Exported backup files now use a systematic date-time format (`hm-backup-YYYY-MM-DD-HH-mm-ss.hmb`) for easier archiving.

### 🛠️ Under The Hood
* **Modernized Flutter Architecture:** Purged dozens of deprecated `Color` properties to make the codebase fully compliant and optimized for Flutter 3.24+.
* **Automated CI/CD:** Our deployment pipeline is now 100% automated using GitHub Actions v4! Android APKs, as well as native portable standalone builds for Windows (ZIP) and Linux (TAR.GZ) are now built and released directly, replacing the old `flutter_distributor` toolchain for greater reliability.

*Thank you to all our contributors for keeping the music playing! ❤️*
