# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: Reset default values for custom theme [#2024](https://github.com/bonfire-networks/bonfire-app/issues/2024) (thanks @ccamara and @ivanminutillo)
- ✨ Feature Proposal: WYSIWYG editor with markdown support [#1887](https://github.com/bonfire-networks/bonfire-app/issues/1887) (thanks @jrossstocholm and @mayel)
- ✨ No visible indicator of a post being local or public in timeline feeds [#1645](https://github.com/bonfire-networks/bonfire-app/issues/1645) (thanks @mayel and @ivanminutillo)
- ✨ Feature Proposal: an easy way of blocking a remote intances (for admins and individual users) [#1631](https://github.com/bonfire-networks/bonfire-app/issues/1631) (thanks @jonpincus, @mayel, and @ivanminutillo)
- ✨ Add a way to specifically allow-list remote domains/users for federation [#1038](https://github.com/bonfire-networks/bonfire-app/issues/1038) (thanks @mayel)
- ✨ Add a "Open for local users only" boundary for groups [#611](https://github.com/bonfire-networks/bonfire-app/issues/611) (thanks @mayel and @edumerco)
- ✅ groups test coverage [#577](https://github.com/bonfire-networks/bonfire-app/issues/577) (thanks @ivanminutillo)
- ✨ add info about versions [`fd0383e`](https://github.com/bonfire-networks/bonfire-app/commit/fd0383ed4c20e7adad2893242a246bd0aca00362) (thanks @mayel)
- ✨ new translations [`06a4a2d`](https://github.com/bonfire-networks/bonfire-app/commit/06a4a2d7531649e2fb50f1ad55562e8c6db708ad) (thanks @mayel)
- ✅ tests [`893f483`](https://github.com/bonfire-networks/bonfire-app/commit/893f483fc80d2fd232a86bcd2cb30ba015484f17), [`476282f`](https://github.com/bonfire-networks/bonfire-app/commit/476282f090d098dfd81bf8bd215006dcfb9d0548), [`4d3ae52`](https://github.com/bonfire-networks/bonfire-app/commit/4d3ae520fb82f39d72a4c9418b72a0ba24b39a01), [`83fa87e`](https://github.com/bonfire-networks/bonfire-app/commit/83fa87ec22885764e7e7d299a7d3d5bb6c87bdbc), [`5d326c5`](https://github.com/bonfire-networks/bonfire-app/commit/5d326c53c6a92c6ec88742fc3394b553742cd3d2) (thanks @mayel)

### Changed
- 📝 embedable widget for certain pages [#2017](https://github.com/bonfire-networks/bonfire-app/issues/2017) (thanks @mayel)
- 🚀 init search indexes better [#1419](https://github.com/bonfire-networks/bonfire-app/issues/1419) (thanks @mayel)
- 📝 caretakers can see join requests and approve them [#573](https://github.com/bonfire-networks/bonfire-app/issues/573) (thanks @ivanminutillo)
- 📝 Groups boundary: if I create a private group, all the activities in that group should not be visible to users that aren't participant [#567](https://github.com/bonfire-networks/bonfire-app/issues/567) (thanks @ivanminutillo)
- 🚧 Meta: Group stretch goals [#490](https://github.com/bonfire-networks/bonfire-app/issues/490) (thanks @ivanminutillo and @mayel)
- 📝 Bonfire patches [PR #3](https://github.com/bonfire-networks/decent/pull/3) (thanks @mayel)
- 📝 Bonfire patches [PR #2](https://github.com/bonfire-networks/decent/pull/2) (thanks @mayel)
- 📝 Bonfire patches [PR #1](https://github.com/bonfire-networks/decent/pull/1) (thanks @mayel)
- 💅 fix: improve checks for null that prevent builds [PR #1](https://github.com/bonfire-networks/bonfire-nix/pull/1) (thanks @lmoratti)
- 📝 archipelago fix [`d5fbe5b`](https://github.com/bonfire-networks/bonfire-app/commit/d5fbe5bc71c16be7f5f7fa1fe20e413f67430046) (thanks @mayel)
- 📝 benchmark [`da6de1c`](https://github.com/bonfire-networks/bonfire-app/commit/da6de1c16ec848b35e5b91fe9b8455d42be33242) (thanks @ivanminutillo)
- 📝 broadcast announcement [`809d0af`](https://github.com/bonfire-networks/bonfire-app/commit/809d0afce4d5c93cfe44a7570424db9c605e4354), [`6a9dc01`](https://github.com/bonfire-networks/bonfire-app/commit/6a9dc017615eefb5992636b1349af4f193b7f389) (thanks @mayel)
- 📝 config [`f39c310`](https://github.com/bonfire-networks/bonfire-app/commit/f39c3103d5d5d546e48399787feb9058a17af309) (thanks @mayel)
- 📝 fix [`6e11e13`](https://github.com/bonfire-networks/bonfire-app/commit/6e11e13d4073574997768d8a9032d8c9bfc13d1b), [`28687c7`](https://github.com/bonfire-networks/bonfire-app/commit/28687c71c56507e952b5943d2148604e06c5b44f) (thanks @mayel)
- 🚧 Allow-listed only (archipelago mode): Only federate domains/actors added to allow-lists by mods or individual user [#2015](https://github.com/bonfire-networks/bonfire-app/issues/2015) [`7d2f29e`](https://github.com/bonfire-networks/bonfire-app/commit/7d2f29e0c3135389cf8bd30b27d63cfb34a229ee), [`f62c6cd`](https://github.com/bonfire-networks/bonfire-app/commit/f62c6cd3657e81f8947d45ac3acab1c69b542360), [`2e28fb9`](https://github.com/bonfire-networks/bonfire-app/commit/2e28fb9266ed0ffa38df7ca669250b72f5537732) (thanks @mayel)
- 🚧 send PGP encrypted emails to recipients that support it [#2019](https://github.com/bonfire-networks/bonfire-app/issues/2019) [`c8d54fd`](https://github.com/bonfire-networks/bonfire-app/commit/c8d54fd4e70ede7c13d1513fe6fb5309e670edf3) (thanks @mayel)
- 🚧 Can't federate with some instances [#2029](https://github.com/bonfire-networks/bonfire-app/issues/2029) [`c7d131c`](https://github.com/bonfire-networks/bonfire-app/commit/c7d131c09fe2204857975312111c12379601cc9e) (thanks @mayel and @ccamara)
- 🚧 APIs for groups [#2032](https://github.com/bonfire-networks/bonfire-app/issues/2032) [`e29c67f`](https://github.com/bonfire-networks/bonfire-app/commit/e29c67f109c504f7eba00599c0a4974c5b5408a4) (thanks @mayel)
- 🚧 User should be able to pin activities to the top of their outbox feed [#216](https://github.com/bonfire-networks/bonfire-app/issues/216) [`96cda18`](https://github.com/bonfire-networks/bonfire-app/commit/96cda1887baae1b2746db5e9e0b8220c4af99e06) (thanks @mayel)
- 📝 optimisations [`eaf16a7`](https://github.com/bonfire-networks/bonfire-app/commit/eaf16a78172c7c3b7d74cbfd2a6aa038858e44b0), [`ea8a1eb`](https://github.com/bonfire-networks/bonfire-app/commit/ea8a1ebc9f7f5c1b88bc97a1431b65c8c6f07529) (thanks @mayel)
- 📝 pins embed [`a5c7f2d`](https://github.com/bonfire-networks/bonfire-app/commit/a5c7f2de8d14c38d700931eceb3715db510e51db), [`8a4586b`](https://github.com/bonfire-networks/bonfire-app/commit/8a4586bdbf03888240e0413b4a7d9131864c5b06), [`4c16c61`](https://github.com/bonfire-networks/bonfire-app/commit/4c16c61613d9118a9c095e66b323b7bc70492116) (thanks @mayel)
- 📝 rek [`3802ae1`](https://github.com/bonfire-networks/bonfire-app/commit/3802ae1a48d6b97320b7146676bf3414baf5ac3c) (thanks @ivanminutillo)
- 📝 rel 1.0.4 [`ef51d51`](https://github.com/bonfire-networks/bonfire-app/commit/ef51d51f69a56a56b1c89cfeedc3e4c2bf3b27e0) (thanks @mayel)
- 📝 search [`1376118`](https://github.com/bonfire-networks/bonfire-app/commit/137611814742bf631318acc90ad31589ad606787) (thanks @mayel)
- 📝 search index backfill [`99f1f06`](https://github.com/bonfire-networks/bonfire-app/commit/99f1f06b427e7b66346500ae1bca0128c2850e0a) (thanks @mayel)
- 📝 tauri [`eaab185`](https://github.com/bonfire-networks/bonfire-app/commit/eaab185f1bb4e0793479a4496afcbf8a4506e3e6) (thanks @ivanminutillo)
- 📝 tauri ios [`7d85330`](https://github.com/bonfire-networks/bonfire-app/commit/7d85330e11d6d126f5041fe706459234b6940ed3) (thanks @ivanminutillo)
- 🚀 update translations [`e0e310c`](https://github.com/bonfire-networks/bonfire-app/commit/e0e310c4ae661401832865eefe57031240f98633) (thanks @mayel)

### Fixed
- 🐛 Sensitive content blocks can be scrolled away without confirming intent to view the content [#2007](https://github.com/bonfire-networks/bonfire-app/issues/2007) (thanks @LiquidParasyte and @ivanminutillo)

