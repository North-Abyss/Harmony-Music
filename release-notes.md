# Harmony Music V1.13.1 Hotfix 🎵
We are pushing a quick hotfix to resolve some critical streaming bugs that snuck into the v1.13.0 release, ensuring you have uninterrupted music playback on all platforms!

### 🐛 Bug Fixes & Stability
* **Offline Playback Restored:** Fixed a bug where downloaded/offline tracks were accidentally being routed through the internal proxy server, crashing the player (`No host specified in URI file:///...`). Offline files now bypass the proxy perfectly!
* **Infinite Reload Loop Squashed:** Fixed a critical bug in `media_kit` where playback immediately aborted right after successfully auto-reloading a 403 Forbidden stream from YouTube. The transition from a dead stream to a fresh stream is now seamless.
* **Intelligent Auto-Reload:** We've introduced a robust stream-fallback mechanism. If a stream fails to load due to aggressive YouTube anti-bot protections, the app will safely pause for 1 second before intelligently retrying (up to 10 times in the background) until it secures a working stream. No more UI freezes or endless loading circles!

*Thank you to all our contributors for keeping the music playing! ❤️*
