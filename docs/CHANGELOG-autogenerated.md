# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Other
- 💬 Simplify the instance boundaries page [#587](https://github.com/bonfire-networks/bonfire-app/issues/587) (thanks @ivanminutillo and @mayel)
- 🔧 rotate/prune backups when using coop-cloud and backupbot2 [#1745](https://github.com/bonfire-networks/bonfire-app/issues/1745) (thanks @mayel)

### Added
- ✨ Allow-listed only (archipelago mode): Only federate domains/actors added to allow-lists by mods or individual user [#2015](https://github.com/bonfire-networks/bonfire-app/issues/2015) (thanks @mayel)
- 👷 integrate localhost tunneling library/service for testing [#1237](https://github.com/bonfire-networks/bonfire-app/issues/1237) (thanks @mayel)
- ✨ Enable allow-list federation [#1000](https://github.com/bonfire-networks/bonfire-app/issues/1000) (thanks @ivanminutillo)
- ✨ create a data migration so old Waffle uploads don't get broken and then deprecate it [#786](https://github.com/bonfire-networks/bonfire-app/issues/786) (thanks @mayel)
- ✨ Feature Proposal: automatically mirror every post on twitter [#465](https://github.com/bonfire-networks/bonfire-app/issues/465) (thanks @ahsf)
- ✨ Backlinks showing what posts quoted a post [#142](https://github.com/bonfire-networks/bonfire-app/issues/142) (thanks @ivanminutillo)

### Changed
- 📝 Prototype end-to-end encrypted messages [#1701](https://github.com/bonfire-networks/bonfire-app/issues/1701) (thanks @mayel)
- 🌏 look into implementing OAuth Client ID Metadata Document [#1511](https://github.com/bonfire-networks/bonfire-app/issues/1511) (thanks @mayel)
- 🚀 improve oauth/openid login + implement dance tests for them [#1201](https://github.com/bonfire-networks/bonfire-app/issues/1201) (thanks @mayel)
- 💅 Improve the "Most recent discussion" widget to include in the dashboard [#1164](https://github.com/bonfire-networks/bonfire-app/issues/1164) (thanks @ivanminutillo)
- 📝 stay in the same scroll position (centered around that comment) when the thread is loaded [#652](https://github.com/bonfire-networks/bonfire-app/issues/652) (thanks @ivanminutillo)
- 📝 localise [`4b191aa`](https://github.com/bonfire-networks/bonfire-app/commit/4b191aa8957ffd92b3dffa4be365e6892f5937bb) (thanks @mayel)
- 📝 rel alpha [`af6bde1`](https://github.com/bonfire-networks/bonfire-app/commit/af6bde1e595726c3453b5b0a80212c6100c19086), [`1748e31`](https://github.com/bonfire-networks/bonfire-app/commit/1748e31cba3e3b455c6fa418b9380a4e9ba89c9b) (thanks @mayel)

### Fixed
- 🐛 After following an account with "approve followers", button updates to say "following" (when it should show "requested") [#1633](https://github.com/bonfire-networks/bonfire-app/issues/1633) (thanks @jonpincus and @mayel)

