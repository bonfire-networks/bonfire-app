# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: link seen/read status (of messages or notifications) to the account rather than the user [#1775](https://github.com/bonfire-networks/bonfire-app/issues/1775) (thanks @mayel)
- ✨ Feature Proposal: settings to show the first post in thread above replies in feed instead of (or above) the reply being replied to [#1714](https://github.com/bonfire-networks/bonfire-app/issues/1714) (thanks @mayel and @ivanminutillo)
- ✨ Add a preview for poll activity [#1363](https://github.com/bonfire-networks/bonfire-app/issues/1363) (thanks @ivanminutillo)
- ✨ Feature Proposal: setting to toggle whether to show the post being replied to when replies are shown in feeds [#1359](https://github.com/bonfire-networks/bonfire-app/issues/1359) (thanks @mayel)
- ✨ Add new CORS paths for openid and oauth token [PR #9](https://github.com/bonfire-networks/bonfire_ui_common/pull/9) (thanks @mediaformat)
- ✅ tests [`d9dfde9`](https://github.com/bonfire-networks/bonfire-app/commit/d9dfde95f2b0423d9dfd3ccd95125746527bde83) (thanks @mayel)

### Changed
- 💅 in search results mentions adds a quote blank preview to the activity [#1760](https://github.com/bonfire-networks/bonfire-app/issues/1760) (thanks @ivanminutillo)
- 📝 Use MRF for spam detection [#1049](https://github.com/bonfire-networks/bonfire-app/issues/1049) (thanks @mayel)
- 📝 nitpick: Remove duplicate 'application/x-bzip2' from mime types [PR #3](https://github.com/bonfire-networks/bonfire_files/pull/3) (thanks @bailey-coding)
- 💅 doc/DEPLOY.md: Guix guide: Adapt for latest release. [PR #1768](https://github.com/bonfire-networks/bonfire-app/pull/1768) (thanks @fishinthecalculator)
- 📝 COMPILE_ALL_LOCALES [`2c1cc66`](https://github.com/bonfire-networks/bonfire-app/commit/2c1cc66bfc66b22ab2c7ffc7937091749096cab9) (thanks @mayel)
- 🚧 One-to-one e2ee messaging [#1738](https://github.com/bonfire-networks/bonfire-app/issues/1738) [`be6e9af`](https://github.com/bonfire-networks/bonfire-app/commit/be6e9af07f67fbacb0e590868f242b94b5358423) (thanks @mayel)
- 🚧 Mastodon-compatible API [#916](https://github.com/bonfire-networks/bonfire-app/issues/916) [`f1c4a62`](https://github.com/bonfire-networks/bonfire-app/commit/f1c4a62ebea62316b11b3777ce1c3b8f1fb4e716) (thanks @ivanminutillo and @mayel)
- 📝 justfile [`2afc9de`](https://github.com/bonfire-networks/bonfire-app/commit/2afc9debd36dceaabcf488591bbe39f8e983744a) (thanks @ivanminutillo)

### Fixed
- 🐛 fix prep of migrations in bare metal prod [`92c018e`](https://github.com/bonfire-networks/bonfire-app/commit/92c018ea3d13f3ba4410852ce0df6f38471a365b) (thanks @mayel)

