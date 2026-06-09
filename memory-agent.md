# Project Memory / Agent Knowledge

This document stores context and memory for AI agents assisting with this project, preserving architectural decisions, ongoing task details, and overarching project goals.

## Project Context
- **Name**: Harmony Music
- **Package Name**: `harmonymusic`
- **Version**: 1.12.2+27
- **Forked From**: [anandnet/Harmony-Music](https://github.com/anandnet/Harmony-Music)
- **Remote Origin** (your fork): `https://github.com/North-Abyss/Harmony-Music`
- **Remote Upstream** (original): `https://github.com/anandnet/Harmony-Music`
- **Goal**: Develop and maintain the Harmony Music cross-platform music streaming app.
- **Framework**: Flutter (Dart SDK >=3.1.5 <4.0.0)

## Output Guidelines
- **Run on Chrome**: `flutter run -d chrome`
- **Run on Linux**: `flutter run -d linux`
- **Build Web Release**: `flutter build web --release`
- **Build APK**: `flutter build apk --release`
- **Sync with upstream**: `bash git-sync.sh`
- **Create release**: `bash git-release.sh`

## Ongoing Work & Goals
- [ ] Fix YouTube Music search not working (see `issues.md`)
- [ ] Add keyboard shortcuts for all player controls (see `issues.md`)
- [x] Establish initial project environment
- [x] Configure `git-sync.sh` for easy upstream integration
- [x] Track issues for faster clearance (see `issues.md`)

## Architectural & Design Decisions
- State management: GetX (`get` package)
- Local storage: Hive (`hive` / `hive_flutter`)
- Audio playback: `just_audio` + `audio_service`
- Networking: `dio` for HTTP, `youtube_explode_dart` for YouTube data
- UI fonts: Google Fonts (`google_fonts` package)

## Code Conventions
- Follow Flutter/Dart style guidelines
- Use existing GetX controller patterns for new features
- Keep platform-specific code in respective directories
