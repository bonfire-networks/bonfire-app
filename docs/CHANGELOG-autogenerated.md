# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: Disallow users customising their own theme [#2039](https://github.com/bonfire-networks/bonfire-app/issues/2039) (thanks @ccamara and @mayel)
- ✨ Add filters + preset feeds for: local-instance-only activities, public activities, activities with custom boundaries [#1586](https://github.com/bonfire-networks/bonfire-app/issues/1586) (thanks @mayel)
- ✨ add shm_size to postgres in docker [`28631b4`](https://github.com/bonfire-networks/bonfire-app/commit/28631b45ec0b2022d62f8739aaebf6497655b700) (thanks @mayel)
- ✅ tests [`118a4b0`](https://github.com/bonfire-networks/bonfire-app/commit/118a4b0402605d07767107926af80afeb2d1f5ca), [`25beeda`](https://github.com/bonfire-networks/bonfire-app/commit/25beeda2a9d5ee491439512f38693c4aa989e464), [`87c7c7f`](https://github.com/bonfire-networks/bonfire-app/commit/87c7c7f0e7ecd3d2dfedf971be8a2683ceb033f9), [`6a4bcbf`](https://github.com/bonfire-networks/bonfire-app/commit/6a4bcbf0352dbb5e4ecd03d585e37922f38db33c) (thanks @mayel)

### Changed
- 📝 Make the `:local`/`:remote` feeds fast by recording activity locality at write time [#2168](https://github.com/bonfire-networks/bonfire-app/issues/2168) (thanks @mayel)
- 📝 fixes [`dff48ad`](https://github.com/bonfire-networks/bonfire-app/commit/dff48ad75582d5bdb63dc1297904edfa0e5b4960), [`749b238`](https://github.com/bonfire-networks/bonfire-app/commit/749b23839cc4562d7e7642a6a9ed03d4e4cf1b06), [`2ecd598`](https://github.com/bonfire-networks/bonfire-app/commit/2ecd5981fa868b9826f0e73e6c4444b80f687a6a) (thanks @mayel)
- 📝 locale [`3c345ed`](https://github.com/bonfire-networks/bonfire-app/commit/3c345ed48b22fc36fed27bab5a16c6cbabbe2733) (thanks @mayel)
- 📝 rel 12 [`84095c0`](https://github.com/bonfire-networks/bonfire-app/commit/84095c053b249b68a9d011aeedb16c48e74fb6ee) (thanks @ivanminutillo)
- 💅 show diff on pull [`35940bb`](https://github.com/bonfire-networks/bonfire-app/commit/35940bb9989225dfb164e1c51527fc4c45dfa831) (thanks @mayel)
- 📝 transfer profile to another account capabality for admins [`6b7f50f`](https://github.com/bonfire-networks/bonfire-app/commit/6b7f50fe4fa489a26cee3a917e52eeada40793cf) (thanks @mayel)
- 📝 versions [`b6b2604`](https://github.com/bonfire-networks/bonfire-app/commit/b6b2604f024ae3abb76df1f3b7b324b54f11ec92) (thanks @mayel)

### Fixed
- 🐛 Fix missing `bonfire_ui_reactions` dependency [PR #2](https://github.com/bonfire-networks/ember/pull/2) (thanks @ju1m)
- 🐛 fix @ mention search [`77425c1`](https://github.com/bonfire-networks/bonfire-app/commit/77425c1d2431c79254451442dab4a406a45141d4), [`5148b51`](https://github.com/bonfire-networks/bonfire-app/commit/5148b51e8962c3a093dba4d9e8c30768f970da29) (thanks @mayel)
- 🐛 fix indexable [`1a67238`](https://github.com/bonfire-networks/bonfire-app/commit/1a67238e5186dffc225d4c5c81b385939cefccb4) (thanks @mayel)

