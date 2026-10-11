# Harmony Music V1.13.4 🎵
We are thrilled to release version 1.13.4, addressing the YouTube streaming 403 Forbidden bot challenges, restoring intelligent "Based on last interaction" Discover recommendations, and introducing play-success deferred caching!

### 🚀 YouTube Streaming & Bot Bypass (`yt-dlp` Architecture)
* **InnerTube VISIONOS Pipeline:** Integrated `yt-dlp`'s visionOS InnerTube client architecture with automated session cookie extraction and persistent `visitorData` token management to completely bypass bot detection and 403 Forbidden responses.
* **Secondary TVHTML5 Samsung Fallback:** Added `yt-dlp`'s Samsung TV client fallback to seamlessly handle specialized tracks and videos flagged as "Made for kids".
* **Enhanced LocalProxy Range Streaming:** Upgraded internal streaming proxy with complete cookie forwarding and range seeking for desktop and mobile platforms.

### 🛡️ Play-Success Caching & Stability
* **Deferred Stream Caching:** URLs are only cached once audio playback is actively playing and confirmed healthy, preventing stale/dead URLs from being reused.
* **Transparent Cache Eviction:** If an expired stream or 403 error is detected, the cache is automatically evicted and the track is refetched seamlessly.
* **Isolate Safety:** Eliminated unsendable closure references and UI binding errors in background tasks.

### 🎧 Discover & Recommendations Restored
* **Dynamic Tab Parsing:** Resolved the "Based on last interaction" Discover issue caused by YouTube's newly added Comments tab by dynamically locating the Related endpoint (`MPTR...`).
* **Universal Playback Trigger:** Any song played across the app (search, playlist, album, or queue) now actively updates your personalized Discover feed.

*Special thanks to open-source reference implementations [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) and [`ytdlnis`](https://github.com/deniscerri/ytdlnis)!*
*Thank you to all our users and contributors! ❤️*
*(Educational purposes only)*
