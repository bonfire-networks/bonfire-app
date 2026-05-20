# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: Move tool bar on mobile [#1867](https://github.com/bonfire-networks/bonfire-app/issues/1867) (thanks @btfreeorg, @ivanminutillo, @ruzko, and @mayel)
- ✨ pagination of users and instances lists when logged out [#1655](https://github.com/bonfire-networks/bonfire-app/issues/1655) (thanks @mayel and @ivanminutillo)
- ✨ re-enable auto-mark-as-read for notifications and messages [#1418](https://github.com/bonfire-networks/bonfire-app/issues/1418) (thanks @mayel and @ivanminutillo)
- ✅ tests [`edc0a75`](https://github.com/bonfire-networks/bonfire-app/commit/edc0a75f5bf81539834a476387c3913338c1fbbc), [`8449b02`](https://github.com/bonfire-networks/bonfire-app/commit/8449b028a5b01251f5672a8dbfee4e5b71625e40) (thanks @mayel)

### Changed
- 📝 visiting members page as a guest crashes on load more [#1752](https://github.com/bonfire-networks/bonfire-app/issues/1752) (thanks @ivanminutillo and @mayel)
- ⚡ Optimize guest local feed origin filter [PR #6](https://github.com/bonfire-networks/bonfire_social/pull/6) (thanks @sftwrstef)
- 📝 1.0.3 [`e500e79`](https://github.com/bonfire-networks/bonfire-app/commit/e500e795c6559b6be2a83630cb0b5fa14ab676b5) (thanks @ivanminutillo)
- 📝 api [`fdd7c64`](https://github.com/bonfire-networks/bonfire-app/commit/fdd7c6444675de1cc5398c2b2af485bd46290d89) (thanks @mayel)
- 📝 fix [`fc9f4b1`](https://github.com/bonfire-networks/bonfire-app/commit/fc9f4b1d24d2114815238b94d56966bde679e567), [`e5696d0`](https://github.com/bonfire-networks/bonfire-app/commit/e5696d03b9b940656691bd3fe77346bb95564c17) (thanks @mayel)
- 📝 languages [`931ea7e`](https://github.com/bonfire-networks/bonfire-app/commit/931ea7efcbe45635288e8c0bc9a7f370185b4a3b) (thanks @mayel)
- 📝 rate_limit [`dcaf203`](https://github.com/bonfire-networks/bonfire-app/commit/dcaf203476b3a681656c3a963651011c7e867339) (thanks @mayel)
- 📝 redhat attempt 1 [`2271730`](https://github.com/bonfire-networks/bonfire-app/commit/22717306d15d554bb07bd6c107c63ec8bee22607) (thanks @mayel)
- 📝 rh 10 [`48362de`](https://github.com/bonfire-networks/bonfire-app/commit/48362de36fffd57dd0efe49c6d3984d28ce8187d) (thanks @mayel)
- 📝 rh 2 [`4894087`](https://github.com/bonfire-networks/bonfire-app/commit/48940876c60e53fc3bc06d29335d337e850c7241) (thanks @mayel)
- 📝 rh 3 [`abe77c7`](https://github.com/bonfire-networks/bonfire-app/commit/abe77c7c87746fd3ea69236521bb179ee45eb34e) (thanks @mayel)
- 📝 rh 4 [`f692e1d`](https://github.com/bonfire-networks/bonfire-app/commit/f692e1deb6430652cedd8ee18e5ffb33420815d3) (thanks @mayel)
- 📝 rh 5 [`2565020`](https://github.com/bonfire-networks/bonfire-app/commit/25650203c13001b1c31e8ae418a98a6aea3e81e2) (thanks @mayel)
- 📝 rh 6 [`fdfd821`](https://github.com/bonfire-networks/bonfire-app/commit/fdfd821f054afa4748788cda425ff4f2618a3676) (thanks @mayel)
- 📝 rh 7 [`dfb15cc`](https://github.com/bonfire-networks/bonfire-app/commit/dfb15cc379e1345262bce27d6cd8170d304d4d34) (thanks @mayel)
- 📝 rh 8 [`fd9d9f3`](https://github.com/bonfire-networks/bonfire-app/commit/fd9d9f3d1665b2e91f37b4c6643cc71499b9122b) (thanks @mayel)
- 📝 rh 9 [`4045ba3`](https://github.com/bonfire-networks/bonfire-app/commit/4045ba35df5b3db6f2ad23cffe4a3784cc7f01f6) (thanks @mayel)
- 📝 search [`cf9758c`](https://github.com/bonfire-networks/bonfire-app/commit/cf9758c6c9074edc133b938d0493a750a535c76f) (thanks @mayel)
- 📝 seo [`4d82ed4`](https://github.com/bonfire-networks/bonfire-app/commit/4d82ed47ef23fe8df865f22fa7701d138d55ee99) (thanks @mayel)
- 📝 sonic [`5b22488`](https://github.com/bonfire-networks/bonfire-app/commit/5b22488aa13a28e96c8cee2f95d5109c64a40632) (thanks @mayel)
- 📝 sonic search WIP [`af34890`](https://github.com/bonfire-networks/bonfire-app/commit/af348905e856a7a29eaa20a89a0c7b96c90baabd) (thanks @mayel)
- 📝 translation [`19e21b8`](https://github.com/bonfire-networks/bonfire-app/commit/19e21b8d2503753180b4e341a0eee3898730ca65) (thanks @ivanminutillo)
- 📝 tx commands [`fc35a42`](https://github.com/bonfire-networks/bonfire-app/commit/fc35a422ec2c5abe64f7cd39fe0073061d34e718) (thanks @mayel)

### Fixed
- 🐛 Meaningful OpenGraph/Twitter meta tags when sharing profiles and posts [#1992](https://github.com/bonfire-networks/bonfire-app/issues/1992) (thanks @ivanminutillo)
- 🐛 DM loses user id intermittent? [#1780](https://github.com/bonfire-networks/bonfire-app/issues/1780) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Applying search rises an error [#1662](https://github.com/bonfire-networks/bonfire-app/issues/1662) (thanks @1m2lab and @ivanminutillo)
- 🐛 User preferences error messages only display the leftmost 25% of the red error box [#1644](https://github.com/bonfire-networks/bonfire-app/issues/1644) (thanks @mayel and @ivanminutillo)
- 🐛 Instance Settings periodically reloads while editing [#1593](https://github.com/bonfire-networks/bonfire-app/issues/1593) (thanks @ltning, @mayel, and @ivanminutillo)

