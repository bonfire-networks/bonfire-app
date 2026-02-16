# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: link seen/read status (of messages or notifications) to the account rather than the user [#1775](https://github.com/bonfire-networks/bonfire-app/issues/1775) (thanks @mayel)
- ✨ Feature Proposal: settings to show the first post in thread above replies in feed instead of (or above) the reply being replied to [#1714](https://github.com/bonfire-networks/bonfire-app/issues/1714) (thanks @mayel and @ivanminutillo)
- ✨ Grouped notifications dont allow to see all the users grouped [#1682](https://github.com/bonfire-networks/bonfire-app/issues/1682) (thanks @ivanminutillo and @mayel)
- ✨ Add a preview for poll activity [#1363](https://github.com/bonfire-networks/bonfire-app/issues/1363) (thanks @ivanminutillo)
- ✨ Feature Proposal: setting to toggle whether to show the post being replied to when replies are shown in feeds [#1359](https://github.com/bonfire-networks/bonfire-app/issues/1359) (thanks @mayel)
- ✨ Browse feeds by media [#830](https://github.com/bonfire-networks/bonfire-app/issues/830) (thanks @mayel)
- ✨ Use Cmd + enter to publish a post [#397](https://github.com/bonfire-networks/bonfire-app/issues/397) (thanks @ivanminutillo and @sefsh)
- ✨ Add new CORS paths for openid and oauth token [PR #9](https://github.com/bonfire-networks/bonfire_ui_common/pull/9) (thanks @mediaformat)
- ✅ tests [`d9dfde9`](https://github.com/bonfire-networks/bonfire-app/commit/d9dfde95f2b0423d9dfd3ccd95125746527bde83) (thanks @mayel)

### Changed
- 🚀 make sure EXIF metadata is always stripped from uploads [#1794](https://github.com/bonfire-networks/bonfire-app/issues/1794) (thanks @mayel)
- 💅 in search results mentions adds a quote blank preview to the activity [#1760](https://github.com/bonfire-networks/bonfire-app/issues/1760) (thanks @ivanminutillo)
- 📝 One-to-one e2ee messaging [#1738](https://github.com/bonfire-networks/bonfire-app/issues/1738) (thanks @mayel)
- 📝 Use MRF for spam detection [#1049](https://github.com/bonfire-networks/bonfire-app/issues/1049) (thanks @mayel)
- 📝 nitpick: Fix typo in DEPLOY.md for admin command [PR #1792](https://github.com/bonfire-networks/bonfire-app/pull/1792) (thanks @bailey-coding)
- 📝 nitpick: Remove duplicate 'application/x-bzip2' from mime types [PR #3](https://github.com/bonfire-networks/bonfire_files/pull/3) (thanks @bailey-coding)
- 💅 doc/DEPLOY.md: Guix guide: Adapt for latest release. [PR #1768](https://github.com/bonfire-networks/bonfire-app/pull/1768) (thanks @fishinthecalculator)
- 📝 COMPILE_ALL_LOCALES [`2c1cc66`](https://github.com/bonfire-networks/bonfire-app/commit/2c1cc66bfc66b22ab2c7ffc7937091749096cab9) (thanks @mayel)
- 🚧 Bonfire Load Test Results [#1789](https://github.com/bonfire-networks/bonfire-app/issues/1789) [`e0627b2`](https://github.com/bonfire-networks/bonfire-app/commit/e0627b24d9b52794176bba4c20b7da1b82d06b68) (thanks @mayel and @ivanminutillo)
- 🚧 Push notifications in desktop app [#1800](https://github.com/bonfire-networks/bonfire-app/issues/1800) [`f51f101`](https://github.com/bonfire-networks/bonfire-app/commit/f51f10166227c99ff384493d8c0ee59a8a5f88fc), [`172dfd1`](https://github.com/bonfire-networks/bonfire-app/commit/172dfd1fa9e72f568d377e24a08686a4decf0408) (thanks @mayel)
- 🚧 Mastodon-compatible API [#916](https://github.com/bonfire-networks/bonfire-app/issues/916) [`f1c4a62`](https://github.com/bonfire-networks/bonfire-app/commit/f1c4a62ebea62316b11b3777ce1c3b8f1fb4e716) (thanks @ivanminutillo and @mayel)
- 📝 justfile [`2afc9de`](https://github.com/bonfire-networks/bonfire-app/commit/2afc9debd36dceaabcf488591bbe39f8e983744a) (thanks @ivanminutillo)
- 📝 nitpick: Fix typo in DEPLOY.md for admin command [`6fc13f9`](https://github.com/bonfire-networks/bonfire-app/commit/6fc13f9fd3946b5f78fdf89715b27c6522cb95e3) (thanks @bailey-coding)
- 📝 tauri [`114d90e`](https://github.com/bonfire-networks/bonfire-app/commit/114d90ec9824050907ccb1588e07778ea8463282) (thanks @mayel)
- 📝 tauri WIP [`6f3d343`](https://github.com/bonfire-networks/bonfire-app/commit/6f3d343edc6e51010aac9c710069321a89418d54) (thanks @mayel)

### Fixed
- 🐛 Fix search results broken previews using standard feed preload [#1797](https://github.com/bonfire-networks/bonfire-app/issues/1797) (thanks @ivanminutillo)
- 🐛 Sorting replies in flat mode (as opposed to threaded) shows wrong avatar [#1608](https://github.com/bonfire-networks/bonfire-app/issues/1608) (thanks @ccamara, @mayel, and @ivanminutillo)
- 🐛 Avatar in feed appears slowly, sometimes few seconds after the activity becomes visible on the screen [#1577](https://github.com/bonfire-networks/bonfire-app/issues/1577) (thanks @ivanminutillo)
- 🐛 fix prep of migrations in bare metal prod [`92c018e`](https://github.com/bonfire-networks/bonfire-app/commit/92c018ea3d13f3ba4410852ce0df6f38471a365b) (thanks @mayel)

