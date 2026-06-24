# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Feature Proposal: string showing on listing and results if federation is not set to auto [#2058](https://github.com/bonfire-networks/bonfire-app/issues/2058) (thanks @ccamara and @mayel)
- ✨ Investigate when app token expires when using native apps [#1806](https://github.com/bonfire-networks/bonfire-app/issues/1806) (thanks @ivanminutillo and @mayel)
- ✨ Incoming Delete activities return error [#1784](https://github.com/bonfire-networks/bonfire-app/issues/1784) (thanks @ivanminutillo and @mayel)
- ✨ add fallback for missing mediatype on attachments for incoming federation [#1728](https://github.com/bonfire-networks/bonfire-app/issues/1728) (thanks @mayel)
- ✨ Add a setting to toggle desktop notification [#1354](https://github.com/bonfire-networks/bonfire-app/issues/1354) (thanks @ivanminutillo and @mayel)
- ✨ Make it more obvious that certain things aren't possible when federation is disabled (or set to manual), eg following or mentioning a remote user [#647](https://github.com/bonfire-networks/bonfire-app/issues/647) (thanks @mayel)
- ✅ tests [`72d4925`](https://github.com/bonfire-networks/bonfire-app/commit/72d4925793174dc758870f53b623f9d728eb0ce5), [`2c14f1e`](https://github.com/bonfire-networks/bonfire-app/commit/2c14f1eba5d181b2952f21425a11df013f12ce2c), [`7e3fcfb`](https://github.com/bonfire-networks/bonfire-app/commit/7e3fcfb351a23618e8dbc6d2334a77d3f21f7dd7) (thanks @mayel)

### Changed
- 💅 Show only top 5 participants in the thread widget [#1988](https://github.com/bonfire-networks/bonfire-app/issues/1988) (thanks @ivanminutillo and @mayel)
- 📝 move API keys and such from abra's .env into docker secrets [#1886](https://github.com/bonfire-networks/bonfire-app/issues/1886) (thanks @mayel)
- 🚀 Feature Proposal: Improve text for linking other fediverse handles [#1607](https://github.com/bonfire-networks/bonfire-app/issues/1607) (thanks @ccamara and @mayel)
- 📝 Normalize hashtags to be case-insensitive [PR #5](https://github.com/bonfire-networks/bonfire_tag/pull/5) (thanks @mvanhorn)
- 📝 changelog + locales [`9c896b7`](https://github.com/bonfire-networks/bonfire-app/commit/9c896b7bad00283737f839004fb237002a9ebb5f) (thanks @mayel)
- 📝 close [`f5b5c7a`](https://github.com/bonfire-networks/bonfire-app/commit/f5b5c7a6eef2327cd162fb629743fc825d7ade26) (thanks @mayel)
- 📝 move long-form articles to dedicated extension [`197a8e9`](https://github.com/bonfire-networks/bonfire-app/commit/197a8e9528504fba134990d73e08923f806401c3) (thanks @mayel)

### Fixed
- 🐛 Recommended profiles widget doesn't show profiles [#2069](https://github.com/bonfire-networks/bonfire-app/issues/2069) (thanks @ccamara and @mayel)
- 🐛 Spotlight not following theme's colours [#2060](https://github.com/bonfire-networks/bonfire-app/issues/2060) (thanks @ccamara)
- 🐛 Archipelago settings not reflected in UI after saved [#2056](https://github.com/bonfire-networks/bonfire-app/issues/2056) (thanks @ccamara and @mayel)
- 🐛 Verified check in profile identities is confusing [#2042](https://github.com/bonfire-networks/bonfire-app/issues/2042) (thanks @ccamara and @mayel)
- 🐛 Case sensitive hashtags [#2023](https://github.com/bonfire-networks/bonfire-app/issues/2023) - [PR #5](https://github.com/bonfire-networks/bonfire-app/pull/5) (thanks @ccamara, @mvanhorn, and @mayel)
- 🐛 [user,account,instance] switcher absent under safety/blocks [#2018](https://github.com/bonfire-networks/bonfire-app/issues/2018) (thanks @gillesdutilh and @mayel)
- 🐛 Redundant sensitive content reveals [#2006](https://github.com/bonfire-networks/bonfire-app/issues/2006) (thanks @LiquidParasyte and @mayel)
- 🐛 Redundant alt text in full screen image viewer [#2005](https://github.com/bonfire-networks/bonfire-app/issues/2005) (thanks @LiquidParasyte and @mayel)
- 🐛 Client to server Update activity breaks the replies field [#1930](https://github.com/bonfire-networks/bonfire-app/issues/1930) (thanks @mavnn and @mayel)
- 🐛 follow activities (that appear after accepting a follow request) in notifications show the wrong actor [#1907](https://github.com/bonfire-networks/bonfire-app/issues/1907) (thanks @mayel)
- 🐛 Removing a profile picture or banner seems to be impossible [#1842](https://github.com/bonfire-networks/bonfire-app/issues/1842) (thanks @LiquidParasyte and @mayel)
- 🐛 OAuth2 error (ActivityPub C2S, but doesn't seem specific to that). [#1836](https://github.com/bonfire-networks/bonfire-app/issues/1836) (thanks @steve-bate and @mayel)
- 🐛 issue fetching peertube objects [#1802](https://github.com/bonfire-networks/bonfire-app/issues/1802) (thanks @mayel and @btfreeorg)
- 🐛 Fix the preview (or hide entirely) for atproto quote [#1759](https://github.com/bonfire-networks/bonfire-app/issues/1759) (thanks @ivanminutillo and @mayel)
- 🐛 security/confidentiality: secrets are stored in environment variables [#1663](https://github.com/bonfire-networks/bonfire-app/issues/1663) - [PR #1871](https://github.com/bonfire-networks/bonfire-app/pull/1871), [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m, @mayel, and @eljamm)
- 🐛 accepting a follow requests results in an invalid activity appearing in notifications until you refresh [#1659](https://github.com/bonfire-networks/bonfire-app/issues/1659) (thanks @mayel)
- 🐛 Make Oban queue sizes configurable + make sure they don't overwhelm Ecto pool [#1638](https://github.com/bonfire-networks/bonfire-app/issues/1638) (thanks @mayel)
- 🐛 Incorrect aria-labeledby information on landing page on campground.bonfire.cafe [#1449](https://github.com/bonfire-networks/bonfire-app/issues/1449) (thanks @jonpincus and @mayel)

