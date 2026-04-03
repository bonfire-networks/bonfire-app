# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✅ Fetch the latest version using coopcloud/abra [#1875](https://github.com/bonfire-networks/bonfire-app/issues/1875) (thanks @jeppebundsgaard and @mayel)
- ✨ Feature Proposal: Translation extensions [#1649](https://github.com/bonfire-networks/bonfire-app/issues/1649) (thanks @dogrileycom, @mayel, and @ivanminutillo)
- ✨ [Bonfire Pandora] :: As a user i want to add metadata to a movie if I have proper rights [#8](https://github.com/bonfire-networks/federated_archives/issues/8) (thanks @ivanminutillo)
- ✨ enable marker only on certain feeds [`cbca6c5`](https://github.com/bonfire-networks/bonfire-app/commit/cbca6c53a8b209643363089129676a784e7a0c12) (thanks @mayel)
- ✨ feat(css): add federated_archives_plyr re-export for bonfire_pandora Plyr styles [`6729852`](https://github.com/bonfire-networks/federated_archives/commit/6729852329e58a05298e001fc15d41fcf9800489)
- ✅ test [`68bb86b`](https://github.com/bonfire-networks/bonfire-app/commit/68bb86b695075db87d74b539a2466c5258905768) (thanks @mayel)

### Changed
- 💅 Long title of a media break the UI in movie page [#57](https://github.com/bonfire-networks/federated_archives/issues/57) (thanks @cranioisthinking)
- 📝 Values as search terms in movieinfo [#56](https://github.com/bonfire-networks/federated_archives/issues/56) (thanks @cranioisthinking)
- 📝 Removing a person from a group chat [#1861](https://github.com/bonfire-networks/bonfire-app/issues/1861) (thanks @mayel)
- 📝 Leaving a group chat [#1860](https://github.com/bonfire-networks/bonfire-app/issues/1860) (thanks @mayel)
- 📝 Adding a person to an existing group chat [#1859](https://github.com/bonfire-networks/bonfire-app/issues/1859) (thanks @mayel)
- 📝 Reactions for e2ee content, including Like, Read, Listen, View [#1742](https://github.com/bonfire-networks/bonfire-app/issues/1742) (thanks @mayel)
- 📝 Updating and deleting e2ee messages [#1741](https://github.com/bonfire-networks/bonfire-app/issues/1741) (thanks @mayel)
- 📝 File attachments (images, video, audio) on e2ee messages [#1740](https://github.com/bonfire-networks/bonfire-app/issues/1740) (thanks @mayel)
- 📝 Group messaging (e2ee) [#1739](https://github.com/bonfire-networks/bonfire-app/issues/1739) (thanks @mayel)
- 📝 Dashboard Widgets Proposal [#1734](https://github.com/bonfire-networks/bonfire-app/issues/1734) (thanks @ivanminutillo and @mayel)
- 📝 Edit movie in Movie info tab [#53](https://github.com/bonfire-networks/federated_archives/issues/53) (thanks @cranioisthinking)
- 📝 Annotation title [#51](https://github.com/bonfire-networks/federated_archives/issues/51) (thanks @cranioisthinking)
- 📝 Clear Filters [#50](https://github.com/bonfire-networks/federated_archives/issues/50) (thanks @cranioisthinking)
- 📝 code of conduct 0.5 draft [PR #8](https://github.com/bonfire-networks/website-blog/pull/8) (thanks @mayel)
- 📝 DesignSystem [`5a2c586`](https://github.com/bonfire-networks/bonfire-app/commit/5a2c5866e301e9cb81ae1764ee4bd7750a033581) (thanks @mayel)
- 💅 align PreviewContentLive hook with Pandora video preview clicks [`dffb273`](https://github.com/bonfire-networks/federated_archives/commit/dffb2735a6da50304b51040c9513c4338ee9feff)
- 📝 circles [`a3f3dcd`](https://github.com/bonfire-networks/bonfire-app/commit/a3f3dcd70b0d334ac2dd1f19d806d3ceac4dde4c) (thanks @mayel)
- 📝 comments iframe [`baf08a1`](https://github.com/bonfire-networks/bonfire-app/commit/baf08a1382dd1ee7ab475db3281c9c99d5d616f4) (thanks @mayel)
- 📝 css on extension [`78ee2d7`](https://github.com/bonfire-networks/federated_archives/commit/78ee2d7a503f425f27a912d74b785624c6d99598)
- 📝 embed media [`6fc7788`](https://github.com/bonfire-networks/bonfire-app/commit/6fc7788f1f74044c97c215b7d4c08c7b2fb04f13) (thanks @mayel)
- 💅 feat: Pandora video preview, LazyImage fix, config cleanup [`23d4703`](https://github.com/bonfire-networks/federated_archives/commit/23d470384470c9990c37a94eaa8f40be51256089)
- 📝 fix(dashboard): use ArchiveSearchLive with ConnectPandora; assign csrf_token in ArchiveSearchLive mount [`6b3d649`](https://github.com/bonfire-networks/federated_archives/commit/6b3d6495922be4e0fbe1d30e7a653c013620b7c9)
- 💅 fix(feed): apply PanDoRa Plyr click exclusions in flavour PreviewActivity hooks and stop propagation from PlyrInit [`66e1c92`](https://github.com/bonfire-networks/federated_archives/commit/66e1c9289d1f286a4a974b1f6b30a2086074b2ed)
- 📝 fix(flavour): drop DashboardLive templates; use upstream default /dashboard [`806a8e6`](https://github.com/bonfire-networks/federated_archives/commit/806a8e630dcbd25f362d5febac4a75c48448353b)
- 📝 flavour [`3ffce84`](https://github.com/bonfire-networks/bonfire-app/commit/3ffce844810e99df8020324f5dbf2193809b532d) (thanks @ivanminutillo)
- 📝 group membership [`11fcfcd`](https://github.com/bonfire-networks/bonfire-app/commit/11fcfcdd0087c18561e6eabf37c637c4d66b4f51) (thanks @mayel)
- 📝 groups [`a01ca6f`](https://github.com/bonfire-networks/bonfire-app/commit/a01ca6f94b57c34f6d69703118aadc4fd12ade1a), [`95e0dd4`](https://github.com/bonfire-networks/bonfire-app/commit/95e0dd4f1e1a67e0f830f98a992d60e174739d64) (thanks @mayel)
- 🚧 Prototype end-to-end encrypted messages [#1701](https://github.com/bonfire-networks/bonfire-app/issues/1701) [`454b64b`](https://github.com/bonfire-networks/bonfire-app/commit/454b64b57142a096be1e1e2f72d43488b88caba5), [`b538549`](https://github.com/bonfire-networks/bonfire-app/commit/b53854944d0a4cfe5583c59b346d774eb508a744) (thanks @mayel)
- 🚧 Adding a new client [#1817](https://github.com/bonfire-networks/bonfire-app/issues/1817) [`d92515e`](https://github.com/bonfire-networks/bonfire-app/commit/d92515e5def169cd812c891e2611700c93357325) (thanks @mayel)
- 📝 iframe [`ba01d55`](https://github.com/bonfire-networks/bonfire-app/commit/ba01d556f9476a33a0f5a5389277340804799ede) (thanks @mayel)
- 📝 lock [`95f374a`](https://github.com/bonfire-networks/bonfire-app/commit/95f374a43720a53d191a58290f4483a562573e10), [`74d94d6`](https://github.com/bonfire-networks/bonfire-app/commit/74d94d644e40e46b8b2a2a4686bcc2787bbc4a36), [`6f31036`](https://github.com/bonfire-networks/bonfire-app/commit/6f31036ad758245affc3b12e168fe5d2e9e77d01), [`072e82e`](https://github.com/bonfire-networks/bonfire-app/commit/072e82eb494b9cbe178bcdb24fc0cc60ba105c7e) (thanks @ivanminutillo)
- 📝 notifications [`4f66aaa`](https://github.com/bonfire-networks/bonfire-app/commit/4f66aaae6b3145297ec26847b69eaba2238991d1) (thanks @mayel)
- 📝 plyr css and function [`0d09d68`](https://github.com/bonfire-networks/federated_archives/commit/0d09d6871ba5d7ce43a8d8d63f0b4c009622deea)
- 📝 session [`2360e75`](https://github.com/bonfire-networks/bonfire-app/commit/2360e757e0403e14993bcae0f0da92f376f73ee0) (thanks @mayel)
- 📝 working on dashboard [`29a1df3`](https://github.com/bonfire-networks/federated_archives/commit/29a1df3ca478c80074d1705a52f3e794b45fceaf)
- 📝 working on filters widget [`871a845`](https://github.com/bonfire-networks/federated_archives/commit/871a845d25a20a5546377c09192f640e6f68dc21)
- 📝 working on plyr [`bfa26a0`](https://github.com/bonfire-networks/federated_archives/commit/bfa26a0780f0926a90e2b6a76bafeea13afb7f80)

### Fixed
- 🐛 Annotation Problem [#54](https://github.com/bonfire-networks/federated_archives/issues/54) (thanks @cranioisthinking)
- 🐛 [Bug]: after a keyword search, additional filters return an error [#36](https://github.com/bonfire-networks/federated_archives/issues/36) (thanks @ivanminutillo)

