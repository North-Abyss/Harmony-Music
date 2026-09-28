# Harmony Music V1.13.3 🎵
We are pushing a critical update to resolve the widespread "403 Forbidden" streaming errors, massively improve lyrics fetching, and refine the desktop user experience!

### 🐛 Bug Fixes & Stability
* **YouTube Streaming Restored:** Replaced deprecated InnerTube streaming clients with highly reliable `TV_EMBEDDED` and `WEB_EMBEDDED` configurations to seamlessly bypass the latest bot detection protocols.
* **Smart Visitor Token Handling:** We now capture and inject authentic `visitorData` tokens natively into API requests, preventing rate limits and IP bans.
* **Piped API Fallback:** Added the Piped API as an ultimate failsafe mechanism for stream extraction when conventional methods are blocked by YouTube.
* **Auto-Cache Clearing:** Wiping the internal URL cache gracefully on startup to permanently purge dead proxy addresses.
* **Upgraded Core Logic:** Bumped `youtube_explode_dart` to version 3.1.0 and fortified background Isolate memory maps against unexpected crashes.

### ✨ UI & Experience Enhancements
* **Advanced Lyrics Fetching:** Built a smart fallback that utilizes the `lrclib.net` search API to reliably find lyrics even when exact ID matches fail.
* **Beautiful Lyrics UI:** The currently active lyric line is now styled dynamically with bold text for much better readability.
* **Perfect Desktop Sidebar:** Re-engineered the animated desktop sidebar to calculate its height dynamically, entirely eliminating the ugly scrollbar bug on smaller screens.
* **Codebase Cleanup:** Completely stripped out bloated legacy third-party UI dependencies for a faster, lighter app.

*Thank you to all our contributors for keeping the music playing! ❤️*
This is Educational Purpose only !
