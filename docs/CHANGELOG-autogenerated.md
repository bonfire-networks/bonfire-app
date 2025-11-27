# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: Draft status for posts [#1648](https://github.com/bonfire-networks/bonfire-app/issues/1648) (thanks @dogrileycom and @ivanminutillo)
- ✨ Feature Proposal: Disable showing local timeline to public internet [#1647](https://github.com/bonfire-networks/bonfire-app/issues/1647) (thanks @dogrileycom, @ivanminutillo, and @mayel)
- ✨ Feature Proposal: a way to see instances I've blocked (as an admin or a user) [#1630](https://github.com/bonfire-networks/bonfire-app/issues/1630) (thanks @jonpincus, @mayel, and @ivanminutillo)
- ✨ Feature Proposal: MFA Authentication [#1624](https://github.com/bonfire-networks/bonfire-app/issues/1624) (thanks @jeffsikes and @mayel)
- ✨ Support standard webpush [#1636](https://github.com/bonfire-networks/bonfire-app/issues/1636) (thanks @p1gp1g and @mayel)
- ✨ re-enable auto-mark-as-read for notifications and messages [#1418](https://github.com/bonfire-networks/bonfire-app/issues/1418) (thanks @mayel)
- ✨ Add a more comprehensive list of circles to pick when creating a boundary preset [#1297](https://github.com/bonfire-networks/bonfire-app/issues/1297) (thanks @ivanminutillo and @mayel)

### Changed
- ⚡ prioritise the processing (in seperate federation queue) of incoming @ mentions and DMs [#1658](https://github.com/bonfire-networks/bonfire-app/issues/1658) (thanks @mayel)
- 📝 Boost icon does not darken after boost. [#1642](https://github.com/bonfire-networks/bonfire-app/issues/1642) (thanks @mayel and @ivanminutillo)
- 📝 Replying to a comment within a thread includes all the thread participants by default, instead of just the ones included in the post i'm replying to [#1615](https://github.com/bonfire-networks/bonfire-app/issues/1615) (thanks @ivanminutillo and @mayel)
- 💅 instance permissions should show all verbs [#1611](https://github.com/bonfire-networks/bonfire-app/issues/1611) (thanks @mayel)
- 📝 when adding a moderator via instance settings, it should autocomplete only with local users [#1610](https://github.com/bonfire-networks/bonfire-app/issues/1610) (thanks @mayel)
- 💅 Article preview in feed shows all the links included in the article with previews, leading to a confusing UX [#1578](https://github.com/bonfire-networks/bonfire-app/issues/1578) (thanks @ivanminutillo and @mayel)
- 📝 Upgrade Hammer integration [#1522](https://github.com/bonfire-networks/bonfire-app/issues/1522) (thanks @mayel)
- ⚡ optimise / short circuit incoming Delete activities for unknown remote objects/actors [#850](https://github.com/bonfire-networks/bonfire-app/issues/850) (thanks @mayel)
- 📝 fix(app pages): useless closing div tag breaking layout [PR #7](https://github.com/bonfire-networks/website-blog/pull/7) (thanks @Spratch)
- 📝 1.0.1-alpha.1 [`be54eed`](https://github.com/bonfire-networks/bonfire-app/commit/be54eed379907a4944e78acb6725d1ae6599cdcd) (thanks @mayel)
- 📝 Bonfire Social 1.0 🔥 [`c5aff09`](https://github.com/bonfire-networks/bonfire-app/commit/c5aff0958dfe51a60ddaec455b71d62977372fbd) (thanks @mayel)
- 🚧 Implement web push notification [#1292](https://github.com/bonfire-networks/bonfire-app/issues/1292) [`8c41f51`](https://github.com/bonfire-networks/bonfire-app/commit/8c41f5140939aa8da06c506cb20f59199945ff10) (thanks @mayel and @ivanminutillo)
- 📝 tidewave [`ee40171`](https://github.com/bonfire-networks/bonfire-app/commit/ee40171f6062fb34ee318431b96be6a376a4ce8e) (thanks @ivanminutillo)
- 🚀 update docs [`536ccf2`](https://github.com/bonfire-networks/bonfire-app/commit/536ccf2330a3093e7a5c5ff2f0e1a6172bb92612) (thanks @mayel)

### Fixed
- 🐛 Feed Image Display of Photos [#1654](https://github.com/bonfire-networks/bonfire-app/issues/1654) (thanks @dogrileycom and @ivanminutillo)
- 🐛 module Bonfire.RuntimeConfig is not available [#1651](https://github.com/bonfire-networks/bonfire-app/issues/1651) - [PR #1652](https://github.com/bonfire-networks/bonfire-app/pull/1652), [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m and @mayel)
- 🐛 bonfire-app always loads appsignal's closed-source agent [#1637](https://github.com/bonfire-networks/bonfire-app/issues/1637) - [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m and @mayel)
- 🐛 Editing a post shows encoded HTML [#1635](https://github.com/bonfire-networks/bonfire-app/issues/1635) (thanks @jonpincus and @mayel)
- 🐛 A mention-only reply in mastodon has boost verb enabled on a bonfire instance [#1616](https://github.com/bonfire-networks/bonfire-app/issues/1616) (thanks @ivanminutillo and @mayel)
- 🐛 In some cases links in posts are not linkified [#1614](https://github.com/bonfire-networks/bonfire-app/issues/1614) (thanks @mayel and @ivanminutillo)
- 🐛 clicking 'refresh' when looking at *user* federation status as an admin shows instance federation status [#1601](https://github.com/bonfire-networks/bonfire-app/issues/1601) (thanks @mayel)
- 🐛 Slow response after liking an activity [#1589](https://github.com/bonfire-networks/bonfire-app/issues/1589) (thanks @ivanminutillo)
- 🐛 Wrong subject shown in composer when replying to a boosted post [#1572](https://github.com/bonfire-networks/bonfire-app/issues/1572) (thanks @ivanminutillo and @mayel)
- 🐛 when adding someone to a shared user profile, usernames should be recognise with or without including @ [#1296](https://github.com/bonfire-networks/bonfire-app/issues/1296) (thanks @mayel and @ivanminutillo)
- 🐛 locking a thread still allows replying to replies wihin it [#1084](https://github.com/bonfire-networks/bonfire-app/issues/1084) (thanks @mayel)

