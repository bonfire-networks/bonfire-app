# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Other
- 💬 Simplify the instance boundaries page [#587](https://github.com/bonfire-networks/bonfire-app/issues/587) (thanks @ivanminutillo and @mayel)
- 🔧 rotate/prune backups when using coop-cloud and backupbot2 [#1745](https://github.com/bonfire-networks/bonfire-app/issues/1745) (thanks @mayel)

### Added
- ✨ When creating a new profile, choose between a personal and organisation/team profile, and invite others to manage the profile with you [#2112](https://github.com/bonfire-networks/bonfire-app/issues/2112) (thanks @mayel)
- ✨ Allow-listed only (archipelago mode): Only federate domains/actors added to allow-lists by mods or individual user [#2015](https://github.com/bonfire-networks/bonfire-app/issues/2015) (thanks @mayel)
- 👷 integrate localhost tunneling library/service for testing [#1237](https://github.com/bonfire-networks/bonfire-app/issues/1237) (thanks @mayel)
- ✨ Enable allow-list federation [#1000](https://github.com/bonfire-networks/bonfire-app/issues/1000) (thanks @ivanminutillo)
- ✨ create a data migration so old Waffle uploads don't get broken and then deprecate it [#786](https://github.com/bonfire-networks/bonfire-app/issues/786) (thanks @mayel)
- ✨ Feature Proposal: automatically mirror every post on twitter [#465](https://github.com/bonfire-networks/bonfire-app/issues/465) (thanks @ahsf)
- ✨ Backlinks showing what posts quoted a post [#142](https://github.com/bonfire-networks/bonfire-app/issues/142) (thanks @ivanminutillo)
- ✨ Allow stream_data 1.x [PR #2](https://github.com/bonfire-networks/formula2/pull/2) (thanks @howlettga)

### Changed
- 📝 Prototype end-to-end encrypted messages [#1701](https://github.com/bonfire-networks/bonfire-app/issues/1701) (thanks @mayel)
- 🌏 look into implementing OAuth Client ID Metadata Document [#1511](https://github.com/bonfire-networks/bonfire-app/issues/1511) (thanks @mayel)
- 🚀 improve oauth/openid login + implement dance tests for them [#1201](https://github.com/bonfire-networks/bonfire-app/issues/1201) (thanks @mayel)
- 💅 Improve the "Most recent discussion" widget to include in the dashboard [#1164](https://github.com/bonfire-networks/bonfire-app/issues/1164) (thanks @ivanminutillo)
- 📝 stay in the same scroll position (centered around that comment) when the thread is loaded [#652](https://github.com/bonfire-networks/bonfire-app/issues/652) (thanks @ivanminutillo)
- 📝 .21 [`12ae5ab`](https://github.com/bonfire-networks/bonfire-app/commit/12ae5abaee9c8ac7ea2be74cde9ffc8831dd6a2f) (thanks @ivanminutillo)
- 📝 .26 [`64ae618`](https://github.com/bonfire-networks/bonfire-app/commit/64ae6189d4bd92a0ffbf203bbfad268a0151a76f) (thanks @ivanminutillo)
- 📝 .27 [`6cab34b`](https://github.com/bonfire-networks/bonfire-app/commit/6cab34b5a7208237e3396bf955fb10f39c998f72) (thanks @ivanminutillo)
- 📝 .28 [`d4dc8f4`](https://github.com/bonfire-networks/bonfire-app/commit/d4dc8f4a81265e890d9e3363b04daaecee07d08e) (thanks @ivanminutillo)
- 📝 alpha.19 [`0e4efe2`](https://github.com/bonfire-networks/bonfire-app/commit/0e4efe26d4879e870a24c8a059ec5ba54c67b6f3) (thanks @ivanminutillo)
- 📝 alpha.22 [`50c3647`](https://github.com/bonfire-networks/bonfire-app/commit/50c3647534301b893439319a086ec44227e48aeb) (thanks @ivanminutillo)
- 📝 alpha.23 [`af6432c`](https://github.com/bonfire-networks/bonfire-app/commit/af6432c9afecf260c12eac1182c549bb9d461c6d) (thanks @ivanminutillo)
- 📝 alpha.24 [`cb28c35`](https://github.com/bonfire-networks/bonfire-app/commit/cb28c35c19d70700e1d116d1118f9200f823e9db) (thanks @ivanminutillo)
- 📝 alpha.25 [`bcc4189`](https://github.com/bonfire-networks/bonfire-app/commit/bcc4189b5d9c52d16f5ba1117cacbd86623be32e) (thanks @ivanminutillo)
- 📝 alpha.4 [`b6f955c`](https://github.com/bonfire-networks/bonfire-app/commit/b6f955caa0bd638445469ec37da86d0ea8816959) (thanks @ivanminutillo)
- 📝 alpha.5 [`b5626c5`](https://github.com/bonfire-networks/bonfire-app/commit/b5626c56ae9c9ef3501edd5ff34c12240e9f5524) (thanks @ivanminutillo)
- 📝 alpha.6 [`b197a08`](https://github.com/bonfire-networks/bonfire-app/commit/b197a08ca6ac5b801cfb1142bbdda4da2b4f4683) (thanks @ivanminutillo)
- 📝 alpha.7 [`b865a28`](https://github.com/bonfire-networks/bonfire-app/commit/b865a287c2cf41fbca2211bacf224bc3d52b385b) (thanks @ivanminutillo)
- 📝 config [`c954641`](https://github.com/bonfire-networks/bonfire-app/commit/c954641d542288598a2d7ddb2bbe3b56abcf00ef) (thanks @mayel)
- 📝 fix [`9f28626`](https://github.com/bonfire-networks/bonfire-app/commit/9f28626be8203dddebae765128e5339aeb125d4d), [`e0cf7d7`](https://github.com/bonfire-networks/bonfire-app/commit/e0cf7d7f67afa9e278f4942844b82c57938ced63) (thanks @mayel)
- 🚧 calm empowerement: instance performance/resource usage tuning [#2100](https://github.com/bonfire-networks/bonfire-app/issues/2100) [`8ad32c9`](https://github.com/bonfire-networks/bonfire-app/commit/8ad32c962a747963009b32776f88fc3008d4bc0e), [`f61c1ba`](https://github.com/bonfire-networks/bonfire-app/commit/f61c1ba809f01fd47ac5b0d9a713ba99b51a0ab5) (thanks @mayel)
- 📝 l [`2cced35`](https://github.com/bonfire-networks/bonfire-app/commit/2cced355ac901304945190d73a8ede40c130ff77) (thanks @mayel)
- 📝 localise [`c50c419`](https://github.com/bonfire-networks/bonfire-app/commit/c50c4191780059873e337e97fedb9a0e12ac197a), [`4b191aa`](https://github.com/bonfire-networks/bonfire-app/commit/4b191aa8957ffd92b3dffa4be365e6892f5937bb) (thanks @mayel)
- 📝 m [`9ad80f8`](https://github.com/bonfire-networks/bonfire-app/commit/9ad80f8e31455841c0aab6685e952b0945c8c221) (thanks @mayel)
- 📝 overload whale [`01c3986`](https://github.com/bonfire-networks/bonfire-app/commit/01c398632f9872a01fd68b925cd25a631efc093b) (thanks @mayel)
- 📝 perf optimisations [`4f10e35`](https://github.com/bonfire-networks/bonfire-app/commit/4f10e359a79ff9908d4e89417bec767799c611a6) (thanks @mayel)
- 📝 preload recovery [`78cc28c`](https://github.com/bonfire-networks/bonfire-app/commit/78cc28c05bc87ec6a375634c69c13fc57df81ce4) (thanks @mayel)
- 📝 rel alpha [`af6bde1`](https://github.com/bonfire-networks/bonfire-app/commit/af6bde1e595726c3453b5b0a80212c6100c19086), [`1748e31`](https://github.com/bonfire-networks/bonfire-app/commit/1748e31cba3e3b455c6fa418b9380a4e9ba89c9b) (thanks @mayel)
- 📝 rel.20 [`ad8a38c`](https://github.com/bonfire-networks/bonfire-app/commit/ad8a38c6ca8a702e547a39618fb0c0acb0943322) (thanks @ivanminutillo)
- 📝 tx [`4ccb3cc`](https://github.com/bonfire-networks/bonfire-app/commit/4ccb3cc4a485e5c40bb91710051b5077ee4321f3), [`a5942ce`](https://github.com/bonfire-networks/bonfire-app/commit/a5942cec2069820e92fdfd37beab477ea1e37581) (thanks @ivanminutillo)

### Fixed
- 🐛 Broken `text` dependency with Erlang/OTP 28 [#2110](https://github.com/bonfire-networks/bonfire-app/issues/2110) (thanks @ju1m and @mayel)
- 🐛 After following an account with "approve followers", button updates to say "following" (when it should show "requested") [#1633](https://github.com/bonfire-networks/bonfire-app/issues/1633) (thanks @jonpincus and @mayel)

