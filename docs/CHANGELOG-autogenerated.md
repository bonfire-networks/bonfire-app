# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ Add scroll to refresh on PWA [#2196](https://github.com/bonfire-networks/bonfire-app/issues/2196) (thanks @ivanminutillo)
- ✨ Feature Proposal: Disallow users customising their own theme [#2039](https://github.com/bonfire-networks/bonfire-app/issues/2039) (thanks @ccamara and @mayel)
- ✅ Bonfire Load Test Results [#1789](https://github.com/bonfire-networks/bonfire-app/issues/1789) (thanks @ivanminutillo and @mayel)
- ✨ Add filters + preset feeds for: local-instance-only activities, public activities, activities with custom boundaries [#1586](https://github.com/bonfire-networks/bonfire-app/issues/1586) (thanks @mayel)
- ✨ add shm_size to postgres in docker [`28631b4`](https://github.com/bonfire-networks/bonfire-app/commit/28631b45ec0b2022d62f8739aaebf6497655b700) (thanks @mayel)
- ✅ tests [`b805f78`](https://github.com/bonfire-networks/bonfire-app/commit/b805f785ea59fa7cf237a2079b7b1000e74d4b68), [`7256db9`](https://github.com/bonfire-networks/bonfire-app/commit/7256db9adc603363f8131b27b85f4ebc076a3042), [`118a4b0`](https://github.com/bonfire-networks/bonfire-app/commit/118a4b0402605d07767107926af80afeb2d1f5ca), [`25beeda`](https://github.com/bonfire-networks/bonfire-app/commit/25beeda2a9d5ee491439512f38693c4aa989e464), [`87c7c7f`](https://github.com/bonfire-networks/bonfire-app/commit/87c7c7f0e7ecd3d2dfedf971be8a2683ceb033f9), [`6a4bcbf`](https://github.com/bonfire-networks/bonfire-app/commit/6a4bcbf0352dbb5e4ecd03d585e37922f38db33c) (thanks @mayel)

### Changed
- 💅 when i like / boost a post, the OP preview shows the favicon, date of the boost/like [#2217](https://github.com/bonfire-networks/bonfire-app/issues/2217) (thanks @ivanminutillo)
- 📝 when i reply to a post the composer does not include auomatically the mentions [#2216](https://github.com/bonfire-networks/bonfire-app/issues/2216) (thanks @ivanminutillo)
- 📝 urls are not converted into links in DMs [#2195](https://github.com/bonfire-networks/bonfire-app/issues/2195) (thanks @ivanminutillo)
- 📝 Make the `:local`/`:remote` feeds fast by recording activity locality at write time [#2168](https://github.com/bonfire-networks/bonfire-app/issues/2168) (thanks @mayel)
- ⚡ calm empowerement: instance performance/resource usage tuning [#2100](https://github.com/bonfire-networks/bonfire-app/issues/2100) (thanks @mayel)
- 💅 When a profile is opened, below the bio there are 3 links: [number] posts (the profile opens showing these), [number] followers, [number] following. If you click on "[number] followers" or "[number] following", the "[number] posts" link disappears. [#1862](https://github.com/bonfire-networks/bonfire-app/issues/1862) (thanks @ivanminutillo)
- 📝 Theme color picker dropdown closes immediately in admin settings [#1829](https://github.com/bonfire-networks/bonfire-app/issues/1829) (thanks @creatinglake and @ivanminutillo)
- 📝 docs: fix typos in AGENTS, HACKING and topic docs [PR #2224](https://github.com/bonfire-networks/bonfire-app/pull/2224) (thanks @vaibhav8a)
- 📝 .26 [`36c777d`](https://github.com/bonfire-networks/bonfire-app/commit/36c777d8232072afcc7eafdd0cbf22d3858e62d3) (thanks @ivanminutillo)
- 📝 .27 [`c99023b`](https://github.com/bonfire-networks/bonfire-app/commit/c99023b1e910bd0e1daedefc7192acb324f5d184) (thanks @ivanminutillo)
- 📝 .30 [`bcf958d`](https://github.com/bonfire-networks/bonfire-app/commit/bcf958d9960c0a3cc1791278b50ca1e671861014) (thanks @ivanminutillo)
- 📝 alpha.24 [`9d40af9`](https://github.com/bonfire-networks/bonfire-app/commit/9d40af95255412479ad15d56c1f2253ce6a994d5) (thanks @ivanminutillo)
- 📝 c2s [`fbafcd6`](https://github.com/bonfire-networks/bonfire-app/commit/fbafcd63d61520d10ff2fe37e12310f921290b17) (thanks @mayel)
- 📝 docs: fix typos in AGENTS, HACKING and topic docs [`0936d84`](https://github.com/bonfire-networks/bonfire-app/commit/0936d8457b2dd03a5b6eaa0faeb7460e0ef6cb6c) (thanks @vaibhav8a)
- 📝 fixes [`dff48ad`](https://github.com/bonfire-networks/bonfire-app/commit/dff48ad75582d5bdb63dc1297904edfa0e5b4960), [`749b238`](https://github.com/bonfire-networks/bonfire-app/commit/749b23839cc4562d7e7642a6a9ed03d4e4cf1b06), [`2ecd598`](https://github.com/bonfire-networks/bonfire-app/commit/2ecd5981fa868b9826f0e73e6c4444b80f687a6a) (thanks @mayel)
- 📝 groups / characters federation boundaries [`0f549b5`](https://github.com/bonfire-networks/bonfire-app/commit/0f549b575232323c6ece3ee2768f0c568fa70a74) (thanks @mayel)
- 🚧 Switch Profile shows I have many notifications on each account, when I don't. [#2220](https://github.com/bonfire-networks/bonfire-app/issues/2220) [`5ccedc2`](https://github.com/bonfire-networks/bonfire-app/commit/5ccedc22d3632bba9a44e414be95b0a9d4bd5498) (thanks @mayel and @btfreeorg)
- 📝 js paths [`94cc67b`](https://github.com/bonfire-networks/bonfire-app/commit/94cc67b35644ad010c02074ab84aad801a85d7d7) (thanks @mayel)
- 📝 locale [`3c345ed`](https://github.com/bonfire-networks/bonfire-app/commit/3c345ed48b22fc36fed27bab5a16c6cbabbe2733) (thanks @mayel)
- 📝 optimise ci [`4196e38`](https://github.com/bonfire-networks/bonfire-app/commit/4196e3848cb6fa2ca212fcad5b465827310f004a) (thanks @mayel)
- 📝 private post boundaries interop [`8f2dba9`](https://github.com/bonfire-networks/bonfire-app/commit/8f2dba9d508c7f02415b3ce2c60f931738d862bf) (thanks @mayel)
- 📝 rel 12 [`84095c0`](https://github.com/bonfire-networks/bonfire-app/commit/84095c053b249b68a9d011aeedb16c48e74fb6ee) (thanks @ivanminutillo)
- 📝 rel alpha [`2d6f46f`](https://github.com/bonfire-networks/bonfire-app/commit/2d6f46ff4043c5b23b25f8729906d8317c5c7da6) (thanks @ivanminutillo)
- 💅 show diff on pull [`35940bb`](https://github.com/bonfire-networks/bonfire-app/commit/35940bb9989225dfb164e1c51527fc4c45dfa831) (thanks @mayel)
- 📝 smtp config [`237aa80`](https://github.com/bonfire-networks/bonfire-app/commit/237aa80038447c8d9eccfadf763feab5f365dc6f) (thanks @ivanminutillo)
- 📝 telemetry [`2e9ef1b`](https://github.com/bonfire-networks/bonfire-app/commit/2e9ef1b4bacdf25b3880e852af9cfdd8b589e41e) (thanks @mayel)
- 📝 transfer profile to another account capabality for admins [`6b7f50f`](https://github.com/bonfire-networks/bonfire-app/commit/6b7f50fe4fa489a26cee3a917e52eeada40793cf) (thanks @mayel)
- 📝 versions [`b6b2604`](https://github.com/bonfire-networks/bonfire-app/commit/b6b2604f024ae3abb76df1f3b7b324b54f11ec92) (thanks @mayel)

### Fixed
- 🐛 creating new profile blocked [#2199](https://github.com/bonfire-networks/bonfire-app/issues/2199) (thanks @ruzko and @mayel)
- 🐛 "Copy link" does not copy a post's url [#2198](https://github.com/bonfire-networks/bonfire-app/issues/2198) (thanks @ccamara and @ivanminutillo)
- 🐛 "Direct Messages" Button is Dead [#2188](https://github.com/bonfire-networks/bonfire-app/issues/2188) (thanks @btfreeorg, @mayel, and @ivanminutillo)
- 🐛 A "Welcome Back" button is hidding the "Create" button for accounts [#2178](https://github.com/bonfire-networks/bonfire-app/issues/2178) - [PR #550073](https://github.com/bonfire-networks/bonfire-app/pull/550073) (thanks @ju1m, @mayel, and @ivanminutillo)
- 🐛 can't open the poll preview from the widget in dashboard [#2125](https://github.com/bonfire-networks/bonfire-app/issues/2125) (thanks @ivanminutillo)
- 🐛 Spotlight not following theme's colours [#2061](https://github.com/bonfire-networks/bonfire-app/issues/2061) (thanks @ccamara and @ivanminutillo)
- 🐛 Toggling any buttons causing and error and dysfunction of Dashboard [#1869](https://github.com/bonfire-networks/bonfire-app/issues/1869) (thanks @1m2lab and @ivanminutillo)
- 🐛 Landing Page should reflect the Default User's Theme [#1749](https://github.com/bonfire-networks/bonfire-app/issues/1749) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Customize Theme - Clicking Color buttons changes wrong ones [#1747](https://github.com/bonfire-networks/bonfire-app/issues/1747) (thanks @btfreeorg, @ccamara, and @ivanminutillo)
- 🐛 video player doesn't recognise some formats [#1713](https://github.com/bonfire-networks/bonfire-app/issues/1713) (thanks @mayel and @ivanminutillo)
- 🐛 Fix missing `bonfire_ui_reactions` dependency [PR #2](https://github.com/bonfire-networks/ember/pull/2) (thanks @ju1m)
- 🐛 fix @ mention search [`77425c1`](https://github.com/bonfire-networks/bonfire-app/commit/77425c1d2431c79254451442dab4a406a45141d4), [`5148b51`](https://github.com/bonfire-networks/bonfire-app/commit/5148b51e8962c3a093dba4d9e8c30768f970da29) (thanks @mayel)
- 🐛 fix indexable [`1a67238`](https://github.com/bonfire-networks/bonfire-app/commit/1a67238e5186dffc225d4c5c81b385939cefccb4) (thanks @mayel)
- 🐛 fix js build [`c93f3b5`](https://github.com/bonfire-networks/bonfire-app/commit/c93f3b5ae06e4875d2f6d1c80ce210b8b24cd573) (thanks @mayel)

### Security
- 🚨 c2s auth with http signature [`3444837`](https://github.com/bonfire-networks/bonfire-app/commit/3444837343bf53c76a9e732c6cb83c1e4596913f) (thanks @mayel)

