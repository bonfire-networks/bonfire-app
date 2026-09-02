# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Added
- ✨ add SQL paging + counting for follows (page_follower_ids, count_followers, followed mirrors) [`3fa614a`](https://github.com/bonfire-networks/bonfire_social_graph/commit/3fa614a25bcae5f420063f7687c5382d2695c677) (thanks @ivanminutillo)
- ✅ group interop tests [`b896407`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/b89640779edbeb7d7270d93a2c632e404fabfbb0) (thanks @mayel)
- ✅ test [`cb16b1b`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/cb16b1b864a37574e7f06d603345ff5c485eb3d8) (thanks @mayel)

### Changed
- 📝 alt texts are not federating [#2241](https://github.com/bonfire-networks/bonfire-app/issues/2241) (thanks @ivanminutillo and @mayel)
- 🚀 Update DEPLOY.md [PR #2267](https://github.com/bonfire-networks/bonfire-app/pull/2267) (thanks @jeppebundsgaard)
- 🚀 Update DEPLOY.md [PR #2266](https://github.com/bonfire-networks/bonfire-app/pull/2266) (thanks @jeppebundsgaard)
- 📝 AP collections: page before resolving, emit only ap_ids, fix phantom `next` link [`f4e6937`](https://github.com/bonfire-networks/activity_pub/commit/f4e693728a3fa188b402d7cd09bbe9a9b680dda4) (thanks @ivanminutillo)
- 📝 Correctly fix DEPLOY.md [`64ae4c9`](https://github.com/bonfire-networks/bonfire-app/commit/64ae4c9dc62722bbb09063798a0f5c4164aa0c79)
- 📝 avoid dependency on bonfire_api_graphql [`c965df4`](https://github.com/bonfire-networks/bonfire_social/commit/c965df4357443821078c5d61830fb56cb0993c5c) (thanks @mayel)
- 📝 fix [`87ede4f`](https://github.com/bonfire-networks/bonfire_social/commit/87ede4fffac5e27865a62f122c8e647c71f06163) (thanks @mayel)
- 📝 fixtures [`1c5ecfd`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/1c5ecfd36d23feb2619c08b5e114e8cb5be84a79) (thanks @mayel)
- 📝 flag threadiverse interop [`9b9cfa9`](https://github.com/bonfire-networks/activity_pub/commit/9b9cfa9658e244c2b64546264b97b8d8a5892acf) (thanks @mayel)
- 🚧 interop with kbin/lemmy groups [#673](https://github.com/bonfire-networks/bonfire-app/issues/673) [`3a50a26`](https://github.com/bonfire-networks/activity_pub/commit/3a50a2627bf1b6ffd6d4de9eb95a303da139c012), [`d431598`](https://github.com/bonfire-networks/activity_pub/commit/d43159873cd9c24df9c6374371e7ca72e1c3bac4), [`6e3cbd1`](https://github.com/bonfire-networks/activity_pub/commit/6e3cbd1348f3d2d4113553788026f35e7ca7b221), [`475f9e7`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/475f9e7342e5afe586258d0b2f3adfbd55203d37), [`fecef72`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/fecef721840fb186c89ce55ba59d50a33181c156), [`f426427`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/f4264273e141c08b07d26ddaaca53891530f6a5c), [`a114075`](https://github.com/bonfire-networks/bonfire_files/commit/a114075bf102ccaf66a02d2e9869bcb7680a3d51), [`1dc9f9f`](https://github.com/bonfire-networks/bonfire_social/commit/1dc9f9f3c7c9415e3674bfd144f142fc4925d04c), [`3eb52db`](https://github.com/bonfire-networks/bonfire_social/commit/3eb52db9c33d875ec91e16554a4c4af0df104645), [`78e2ba8`](https://github.com/bonfire-networks/bonfire_ghost/commit/78e2ba8f7c9d2570978d1fd324b04a143ef33d85), [`eb0aaf8`](https://github.com/bonfire-networks/bonfire_tag/commit/eb0aaf876e00126e6f33ad2a12a4d8c3f42d269f), [`313e479`](https://github.com/bonfire-networks/bonfire_classify/commit/313e47919f829d554d12e49a508705559730fb4c), [`8d0d457`](https://github.com/bonfire-networks/bonfire_classify/commit/8d0d4571179cc59261bfab31fdd7dc1f4ed54b7a), [`3964e37`](https://github.com/bonfire-networks/bonfire_data_shared_user/commit/3964e377ca53fc1dec8e08e73688b21dfc1ef3f5), [`c112bc0`](https://github.com/bonfire-networks/bonfire_boundaries/commit/c112bc09e599f5cd0fdf7cd5a5925fb16ff83117), [`9a6ea42`](https://github.com/bonfire-networks/bonfire-app/commit/9a6ea423bca6858454b333e29e42844b033253fa), [`d31229a`](https://github.com/bonfire-networks/bonfire-app/commit/d31229ac35e0c3e1e4df377ab6614c955a06e519) (thanks @mayel and @ivanminutillo)
- 🚀 improve changelog generator [`9c17b87`](https://github.com/bonfire-networks/bonfire_common/commit/9c17b8791df4ea5ba95eef1948ab5cd63801b0c6) (thanks @mayel)
- 📝 media optimise [`e33b0ad`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/e33b0ad6204dc969f11ae8cbb76e4accabc97e18), [`f074702`](https://github.com/bonfire-networks/bonfire_files/commit/f074702d46e3494b7f239d952966ffd3aeca6d7f), [`84085bc`](https://github.com/bonfire-networks/bonfire_social/commit/84085bca21160a214b1e50efca4c4ec1793e0760), [`0df0262`](https://github.com/bonfire-networks/bonfire_common/commit/0df0262112610e89798f356011523ff53653e783), [`0277fbd`](https://github.com/bonfire-networks/bonfire_me/commit/0277fbddf284b4a174d2cbddb942a27030a9681e) (thanks @mayel)
- 📝 serve AP follower collections from ids: paged adapter callbacks + URI-only actor resolution [`727161d`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/727161d049b4d07b9274ad79196e48aa0322d7c4) (thanks @ivanminutillo)
- 💅 ui [`84582d2`](https://github.com/bonfire-networks/bonfire_ui_me/commit/84582d2ec4d2842fa6af63b85014226d4f041c7e) (thanks @ivanminutillo)
- 🚀 update docs [`0400c01`](https://github.com/bonfire-networks/bonfire_ghost/commit/0400c01ec5a5d35a1915c898577dfc9cf89e07a8) (thanks @mayel)
- 🚀 update generator [`97e0b23`](https://github.com/bonfire-networks/bonfire-app/commit/97e0b231a73c9c78085811184a787e8bcfd69e48) (thanks @mayel)

### Fixed
- 🐛 Fix DEPLOY doc [`6e8740f`](https://github.com/bonfire-networks/bonfire-app/commit/6e8740fe97d31015e609561a565f476ad5432320)

