# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ add loading indicator that handles both local/federated search results [#1443](https://github.com/bonfire-networks/bonfire-app/issues/1443) (thanks @ivanminutillo)
- ✨ Properly render GIFs in media preview [#1426](https://github.com/bonfire-networks/bonfire-app/issues/1426) (thanks @ivanminutillo)
- ✨ Events feed preset [#1301](https://github.com/bonfire-networks/bonfire-app/issues/1301) (thanks @ivanminutillo)
- ✨ add ENABLE_STATIC_CACHING env config [`d6e8235`](https://github.com/bonfire-networks/bonfire-app/commit/d6e82357fdc8ae82ff4f096932e3ab841547288c) (thanks @mayel)
- ✨ tests and new version [`421cd41`](https://github.com/bonfire-networks/bonfire-app/commit/421cd41edc4e6dff9976324bc9e4cca19f77c9ff) (thanks @ivanminutillo)

### Changed
- 🚀 improve feed filters UX [#1431](https://github.com/bonfire-networks/bonfire-app/issues/1431) (thanks @ivanminutillo)
- 🚀 handle activities addresses to a as:public collection [#1430](https://github.com/bonfire-networks/bonfire-app/issues/1430) (thanks @mayel)
- 📝 It would be nice if the media gallery had swipe-between on photos and right-left keypad on desktop [#1424](https://github.com/bonfire-networks/bonfire-app/issues/1424) (thanks @ivanminutillo and @mayel)
- 🚀 improve display of multiple audio attachments [#1422](https://github.com/bonfire-networks/bonfire-app/issues/1422) (thanks @mayel and @ivanminutillo)
- 📝 hide instances from the admin's list of instance-wide circles? [#884](https://github.com/bonfire-networks/bonfire-app/issues/884) (thanks @mayel and @ivanminutillo)
- 🚀 better `just secrets` command [`02de529`](https://github.com/bonfire-networks/bonfire-app/commit/02de529d1d2c8b3cc1f5e634445ba207dd61d6e8) (thanks @mayel)
- 📝 ci [`ba65d9b`](https://github.com/bonfire-networks/bonfire-app/commit/ba65d9bba3b5d8bad8b080208c29261bd05374a9), [`45b2916`](https://github.com/bonfire-networks/bonfire-app/commit/45b291640670d4eb6404739688d3d6c50dcac5f3), [`71dad6c`](https://github.com/bonfire-networks/bonfire-app/commit/71dad6c11029b36d2773c56742b00d80ce11d79a), [`3efcf55`](https://github.com/bonfire-networks/bonfire-app/commit/3efcf555df3c13920bc03d3eadcb60595d10edde), [`ce3c315`](https://github.com/bonfire-networks/bonfire-app/commit/ce3c315dce3c76e8b629c2dce2ea7dabd8e902fe), [`7751d99`](https://github.com/bonfire-networks/bonfire-app/commit/7751d9960e1822d88a9bf8c03cfe61c9b26457de), [`b431c37`](https://github.com/bonfire-networks/bonfire-app/commit/b431c374e7d9aee1b5e7148c4a25ab11a17ee8b3), [`623ea89`](https://github.com/bonfire-networks/bonfire-app/commit/623ea8971c46463de38ab5cdc34938114f735b7c), [`be71e0f`](https://github.com/bonfire-networks/bonfire-app/commit/be71e0fb13bf600c225d9c10b3589051bf813684) (thanks @mayel)

### Fixed
- 🐛 Get Latest Replies not working [#1451](https://github.com/bonfire-networks/bonfire-app/issues/1451) (thanks @jeffsikes and @mayel)
- 🐛 Remote & only filter is not applied in feed [#1432](https://github.com/bonfire-networks/bonfire-app/issues/1432) (thanks @ivanminutillo)
- 🐛 "Read more" button is always shown on activities when viewign the feed as guest [#1423](https://github.com/bonfire-networks/bonfire-app/issues/1423) (thanks @ivanminutillo)
- 🐛 Following/followers are showing only local users ? [#1374](https://github.com/bonfire-networks/bonfire-app/issues/1374) (thanks @ivanminutillo and @mayel)
- 🐛 The character username of a boosted activity has wrong link attached [#1370](https://github.com/bonfire-networks/bonfire-app/issues/1370) (thanks @ivanminutillo and @mayel)
- 🐛 "Load more" to expand a log post is not working anymore in feeds [#1302](https://github.com/bonfire-networks/bonfire-app/issues/1302) (thanks @ivanminutillo and @mayel)

