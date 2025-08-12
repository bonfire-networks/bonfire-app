# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ support bridging using BridgyFed [#1476](https://github.com/bonfire-networks/bonfire-app/issues/1476) (thanks @mayel)
- ✨ sign in with Zenodo [#1471](https://github.com/bonfire-networks/bonfire-app/issues/1471) (thanks @mayel)
- ✨ activities in all feeds dont follow the chronological order anymore (even when it is set in the config) [#1463](https://github.com/bonfire-networks/bonfire-app/issues/1463) (thanks @ivanminutillo and @mayel)
- ✨ Feature Proposal: merge multiple reactions (likes/boosts) to the same post in notifications feed [#1454](https://github.com/bonfire-networks/bonfire-app/issues/1454) (thanks @mayel)
- ✨ Open Science: Hide OpenAlex quantitative metrics widget by default [#1453](https://github.com/bonfire-networks/bonfire-app/issues/1453) (thanks @ivanminutillo)
- ✨ Open Science: better OpenAlex integration [#1452](https://github.com/bonfire-networks/bonfire-app/issues/1452) (thanks @ivanminutillo)
- ✨ add loading indicator that handles both local/federated search results [#1443](https://github.com/bonfire-networks/bonfire-app/issues/1443) (thanks @ivanminutillo)
- ✨ Properly render GIFs in media preview [#1426](https://github.com/bonfire-networks/bonfire-app/issues/1426) (thanks @ivanminutillo)
- ✨ Events feed preset [#1301](https://github.com/bonfire-networks/bonfire-app/issues/1301) (thanks @ivanminutillo)
- ✨ Create SETTINGS_SYSTEM.md [`9e93774`](https://github.com/bonfire-networks/bonfire-app/commit/9e9377418bd86a91aed7be5b344fda010a880aef) (thanks @ivanminutillo)
- ✨ add ENABLE_STATIC_CACHING env config [`d6e8235`](https://github.com/bonfire-networks/bonfire-app/commit/d6e82357fdc8ae82ff4f096932e3ab841547288c) (thanks @mayel)
- ✨ tests and new version [`421cd41`](https://github.com/bonfire-networks/bonfire-app/commit/421cd41edc4e6dff9976324bc9e4cca19f77c9ff) (thanks @ivanminutillo)

### Changed
- 📝 As a user I want to edit a post from the composer [#1456](https://github.com/bonfire-networks/bonfire-app/issues/1456) (thanks @ivanminutillo)
- 🚀 improve feed filters UX [#1431](https://github.com/bonfire-networks/bonfire-app/issues/1431) (thanks @ivanminutillo)
- 🚀 handle activities addresses to a as:public collection [#1430](https://github.com/bonfire-networks/bonfire-app/issues/1430) (thanks @mayel)
- 📝 It would be nice if the media gallery had swipe-between on photos and right-left keypad on desktop [#1424](https://github.com/bonfire-networks/bonfire-app/issues/1424) (thanks @ivanminutillo and @mayel)
- 🚀 improve display of multiple audio attachments [#1422](https://github.com/bonfire-networks/bonfire-app/issues/1422) (thanks @mayel and @ivanminutillo)
- 🚧 support sign up with openid/oauth providers who don't provide the user's email address [#1017](https://github.com/bonfire-networks/bonfire-app/issues/1017) (thanks @mayel)
- 📝 hide instances from the admin's list of instance-wide circles? [#884](https://github.com/bonfire-networks/bonfire-app/issues/884) (thanks @mayel and @ivanminutillo)
- 📝 added usage-rules and subagents in the .claude folder wip [`89f5e1c`](https://github.com/bonfire-networks/bonfire-app/commit/89f5e1c0b4a29f02881f145dc6d002ec877d6fd3) (thanks @ivanminutillo)
- 🚀 better `just secrets` command [`02de529`](https://github.com/bonfire-networks/bonfire-app/commit/02de529d1d2c8b3cc1f5e634445ba207dd61d6e8) (thanks @mayel)
- 📝 ci [`d2e30f6`](https://github.com/bonfire-networks/bonfire-app/commit/d2e30f63fcb2a522f38f8ee8a9023c7970a4159a), [`b8ea137`](https://github.com/bonfire-networks/bonfire-app/commit/b8ea1373743140fa1f48c1950a2e960b4c4ecba4), [`a8fdfc8`](https://github.com/bonfire-networks/bonfire-app/commit/a8fdfc8d19f50bc218483d1769218b4049b0fc46), [`ba65d9b`](https://github.com/bonfire-networks/bonfire-app/commit/ba65d9bba3b5d8bad8b080208c29261bd05374a9), [`45b2916`](https://github.com/bonfire-networks/bonfire-app/commit/45b291640670d4eb6404739688d3d6c50dcac5f3), [`71dad6c`](https://github.com/bonfire-networks/bonfire-app/commit/71dad6c11029b36d2773c56742b00d80ce11d79a), [`3efcf55`](https://github.com/bonfire-networks/bonfire-app/commit/3efcf555df3c13920bc03d3eadcb60595d10edde), [`ce3c315`](https://github.com/bonfire-networks/bonfire-app/commit/ce3c315dce3c76e8b629c2dce2ea7dabd8e902fe), [`7751d99`](https://github.com/bonfire-networks/bonfire-app/commit/7751d9960e1822d88a9bf8c03cfe61c9b26457de), [`b431c37`](https://github.com/bonfire-networks/bonfire-app/commit/b431c374e7d9aee1b5e7148c4a25ab11a17ee8b3), [`623ea89`](https://github.com/bonfire-networks/bonfire-app/commit/623ea8971c46463de38ab5cdc34938114f735b7c), [`be71e0f`](https://github.com/bonfire-networks/bonfire-app/commit/be71e0fb13bf600c225d9c10b3589051bf813684) (thanks @mayel)
- 📝 upgrade phoenix and liveview [`a8355b5`](https://github.com/bonfire-networks/bonfire-app/commit/a8355b52b6bc6ef77dd6e61f6c8e0e1e954cfc62) (thanks @mayel)

### Fixed
- 🐛 Bonfire Social 1.0 RC2 blog post issues [#1469](https://github.com/bonfire-networks/bonfire-app/issues/1469) (thanks @ElectricTea and @mayel)
- 🐛 Notifications never stop Notificationing (after being checked) [#1466](https://github.com/bonfire-networks/bonfire-app/issues/1466) (thanks @ZELFs and @mayel)
- 🐛 Get Latest Replies not working [#1451](https://github.com/bonfire-networks/bonfire-app/issues/1451) (thanks @jeffsikes and @mayel)
- 🐛 Possibility to have duplicate feed names messes with interface (non-critical) [#1450](https://github.com/bonfire-networks/bonfire-app/issues/1450) (thanks @gillesdutilh and @ivanminutillo)
- 🐛 Remote & only filter is not applied in feed [#1432](https://github.com/bonfire-networks/bonfire-app/issues/1432) (thanks @ivanminutillo)
- 🐛 "Read more" button is always shown on activities when viewign the feed as guest [#1423](https://github.com/bonfire-networks/bonfire-app/issues/1423) (thanks @ivanminutillo)
- 🐛 Following/followers are showing only local users ? [#1374](https://github.com/bonfire-networks/bonfire-app/issues/1374) (thanks @ivanminutillo and @mayel)
- 🐛 The character username of a boosted activity has wrong link attached [#1370](https://github.com/bonfire-networks/bonfire-app/issues/1370) (thanks @ivanminutillo and @mayel)
- 🐛 "Load more" to expand a log post is not working anymore in feeds [#1302](https://github.com/bonfire-networks/bonfire-app/issues/1302) (thanks @ivanminutillo and @mayel)

