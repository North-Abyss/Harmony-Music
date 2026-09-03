# Harmony Music V1.13.3 Hotfix 🎵
We are pushing a critical hotfix to resolve the widespread "403 Forbidden" and "Sign in to confirm you're not a bot" errors caused by recent YouTube API changes, ensuring uninterrupted music playback!

### 🐛 Bug Fixes & Stability
* **YouTube Streaming Restored:** Replaced deprecated InnerTube streaming clients with highly reliable `TV_EMBEDDED` and `WEB_EMBEDDED` configurations to seamlessly bypass the latest bot detection protocols.
* **Smart Visitor Token Handling:** We now capture and inject authentic `visitorData` tokens natively into API requests, preventing rate limits and IP bans.
* **Piped API Fallback:** Added the Piped API as an ultimate failsafe mechanism for stream extraction when conventional methods are blocked by YouTube.
* **Auto-Cache Clearing:** Wiping the internal URL cache gracefully on startup to permanently purge dead proxy addresses.
* **Upgraded Core Logic:** Bumped `youtube_explode_dart` to version 3.1.0 and fortified background Isolate memory maps against unexpected crashes.

*Thank you to all our contributors for keeping the music playing! ❤️*

