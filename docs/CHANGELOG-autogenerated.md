# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Added a new "Stream" interface preset: a flatter, content-first look for feeds, threads and widgets — selectable per user or instance in settings, together with the existing "typographic" preset remaining the default (thanks @ivan)
- ✨ Long discussion threads now start with heavy reply branches folded behind a compact summary row (replier avatars + reply count) that expands in place, so big conversations are easier to scan (thanks @ivan)
- ✨ Added time-gap dividers between thread replies ("2 years later/earlier"), so revived old discussions are easy to spot (thanks @ivan)
- ✨ Added a compact context header that appears when the original post scrolls out of view on a discussion, showing the author and a shortcut back to the top  (thanks @ivan)
- ✨ Added a compact, horizontally scrollable circles widget to dashboards, with direct links to each circle (thanks @ivan)
- ✨ Added an empty state that helps people create their first circle when none exist. (thanks @ivan)

### Changed
- 🎨 Reworked the dark theme palette: neutral dark surfaces with clearer contrast steps, and a blue accent replacing amber as the primary colour (thanks @ivan)
- 💅 Polished the audience selector when composing: options are now rounded, evenly spaced rows with clearer icons and selection state (thanks @ivan)
- 💅 Redesigned the "Top discussions" dashboard widget as a compact ranked list, with reply totals and participant previews that make active conversations easier to scan (thanks @ivan)
- 📱 Redesigned the logged-out mobile navigation dock with instance branding (thanks @ivan)
- 🎨 Redesigned Circle pages with a stronger identity-focused header, member avatar collage, clearer ownership and visibility details (thanks @ivan)
- 🐛 Improved Timeline reading positions UX (thanks @ivan)
- 💅 Redesigned the “Recent Articles” sidebar widget in the Stream layout as a compact, single-layer list that is easier to scan (thanks @ivan)
- 📝 fixes [`749b238`](https://github.com/bonfire-networks/bonfire-app/commit/749b23839cc4562d7e7642a6a9ed03d4e4cf1b06), [`2ecd598`](https://github.com/bonfire-networks/bonfire-app/commit/2ecd5981fa868b9826f0e73e6c4444b80f687a6a) (thanks @mayel)
- 🚧 Make the `:local`/`:remote` feeds fast by recording activity locality at write time [#2168](https://github.com/bonfire-networks/bonfire-app/issues/2168) [`ec57bc1`](https://github.com/bonfire-networks/bonfire-app/commit/ec57bc1831eba35c04752e16cb0d9fdd58970a6d) (thanks @mayel)
- 📝 locale [`3c345ed`](https://github.com/bonfire-networks/bonfire-app/commit/3c345ed48b22fc36fed27bab5a16c6cbabbe2733) (thanks @mayel)
- 📝 transfer profile to another account capabality for admins [`6b7f50f`](https://github.com/bonfire-networks/bonfire-app/commit/6b7f50fe4fa489a26cee3a917e52eeada40793cf) (thanks @mayel)
- 📝 versions [`b6b2604`](https://github.com/bonfire-networks/bonfire-app/commit/b6b2604f024ae3abb76df1f3b7b324b54f11ec92) (thanks @mayel)

### Fixed
- 🐛 Fixed full-width buttons (like the audience selector) appearing to shift sideways on hover (thanks @ivan)
- 🐛 Replies to a deleted or restricted comment no longer silently disappear from discussions: they stay in place under an "unavailable comment" placeholder (thanks @ivan)
- 🐛 Fixed thread connector lines not aligning with avatars in the Stream layout, and the missing connector to a folded branch's summary row (thanks @ivan)
- 📱 Fixed post previews getting stuck on a blank loading screen when the connection dropped at the wrong moment (e.g. reopening the app on mobile): the preview now waits for the connection to return instead (thanks @ivan)
- 🐛 Fixed back navigation sometimes skipping an extra page after reloading while viewing a post opened from a feed (thanks @ivan)
- 📱 Fixed mobile back-swipe navigation: swiping back after opening a post from a feed no longer needs a phantom extra swipe, flashes the wrong page, or unexpectedly jumps you back to the feed a moment later (thanks @ivan)
- 🐛 Fixed browser back/forward behaving erratically after using post previews, and made back navigation return you to your previous scroll position even on pages that load content progressively (thanks @ivan)
- 🐛 Fix missing `bonfire_ui_reactions` dependency [PR #2](https://github.com/bonfire-networks/ember/pull/2) (thanks @ju1m)
- 🐛 fix @ mention search [`77425c1`](https://github.com/bonfire-networks/bonfire-app/commit/77425c1d2431c79254451442dab4a406a45141d4), [`5148b51`](https://github.com/bonfire-networks/bonfire-app/commit/5148b51e8962c3a093dba4d9e8c30768f970da29) (thanks @mayel)
- 🐛 fix indexable [`1a67238`](https://github.com/bonfire-networks/bonfire-app/commit/1a67238e5186dffc225d4c5c81b385939cefccb4) (thanks @mayel)
