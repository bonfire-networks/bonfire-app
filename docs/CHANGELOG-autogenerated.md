# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]
### Removed
- ⚰️ Delete caret_icons_browser_test.exs [`334cfb4`](https://github.com/bonfire-networks/bonfire_ui_common/commit/334cfb4d3e291c3af9651e1fd526ec6a59a973bc) (thanks @ivanminutillo)

### Added
- ✅ test [`4005603`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/40056030a4a71153345132f48476d26776b0cbee) (thanks @mayel)
- ✅ Pure Mastodon status mapper: it reads only its GraphQL input; streaming goes through feedActivity; BatchLoaders and the direct feed loader removed. Adds the shared Mastodon test seed and seven client app profiles [`cf97d38`](https://github.com/bonfire-networks/bonfire_api_graphql/commit/cf97d38896be4d83ea105ee7a96c0f8ac8688aa8) (thanks @ivanminutillo)
- ✨ Mastodon create reads the new status back through GraphQL [`fed9301`](https://github.com/bonfire-networks/bonfire_posts/commit/fed93016784a25d21018ad9ab3521aff72b0b8b2) (thanks @ivanminutillo)
- ✅ Replay test: each Mastodon client’s registration, OAuth login and startup calls (tag masto_clients, off by default) [`cab9d4a`](https://github.com/bonfire-networks/bonfire_open_id/commit/cab9d4a8bf016e63c1d45ee02ff53cc66ef136e3) (thanks @ivanminutillo)
- ✅ Skip the masto_clients replay test by default [`671fae0`](https://github.com/bonfire-networks/bonfire_common/commit/671fae0774c943d36b5081d50f12d6e9c1257748) (thanks @ivanminutillo)
- ✅ mastodon fallback test [`36c2c59`](https://github.com/bonfire-networks/bonfire_social/commit/36c2c59ae7c5160ad5e27799bc8874a2ec4ed807) (thanks @ivanminutillo)

### Changed
- 📝 composer [`53ebeb3`](https://github.com/bonfire-networks/bonfire_gatherings/commit/53ebeb3394001c64c830aca29b02e2a7588e27b8), [`5512748`](https://github.com/bonfire-networks/bonfire_poll/commit/5512748948d3623576c44b39ef964ad100f512d9), [`9a1a16c`](https://github.com/bonfire-networks/bonfire_ui_social/commit/9a1a16c89c97be0af3deaea1e368078e6ee7b919) (thanks @ivanminutillo)
- 📝 composer sync [`fcada5b`](https://github.com/bonfire-networks/bonfire_ui_common/commit/fcada5b14e1c556649aa8cfe0c9d0a8095def153) (thanks @ivanminutillo)
- 📝 fix [`0c652fd`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/0c652fd5928ddadbd06bab87baf183dafd40648c), [`57f7c3e`](https://github.com/bonfire-networks/activity_pub/commit/57f7c3e19c96d7dcaaf971f0010a47bb772ae2b5), [`a4dd8ab`](https://github.com/bonfire-networks/bonfire_social/commit/a4dd8abef1a36e09a349092652f16d7de0ac667a), [`eb6262c`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/eb6262c70b7301443a3619f756479a6f5a383b52), [`2de4959`](https://github.com/bonfire-networks/activity_pub/commit/2de49597965cf9a95a230a971aa4fa43faad7baf), [`3b7a840`](https://github.com/bonfire-networks/bonfire_ui_boundaries/commit/3b7a840019d853215d0f0aac6f4a7c4646772f1a), [`8ad0837`](https://github.com/bonfire-networks/bonfire_federate_activitypub/commit/8ad083717db4566d881c4a5c27c3fb6159d1bb79), [`e537d09`](https://github.com/bonfire-networks/activity_pub/commit/e537d094f8bbe8e8d1196a626b314ee879ffa79a) (thanks @mayel)
- 📝 more menu optimisation [`824fb11`](https://github.com/bonfire-networks/bonfire_ui_moderation/commit/824fb114e7c82b8d3bfe27bb2f3e945f0294fc3a), [`bf48a96`](https://github.com/bonfire-networks/bonfire_ui_social/commit/bf48a96c2794c7ec5b375ce56cd48e05279a87f3) (thanks @ivanminutillo)
- 📝 optimisise selected theme and icons weight to fetch only once [`752d9d2`](https://github.com/bonfire-networks/bonfire_ui_common/commit/752d9d20cd7f0a4dae7565aceadd5e6d76dd70f3) (thanks @ivanminutillo)
- 📝 Mastodon visibility rule in Controlleds, batched through a VisibilityDataloader source [`bf53dfe`](https://github.com/bonfire-networks/bonfire_boundaries/commit/bf53dfe041801e55bf903c9370a08f2ec7374051) (thanks @ivanminutillo)
- 📝 Batch poll vote state through a Dataloader source; polls expose the reader’s like, boost and bookmark [`8ff0ac8`](https://github.com/bonfire-networks/bonfire_poll/commit/8ff0ac86ecadba81d1c24d2ebbb81cc328a9ac20) (thanks @ivanminutillo)
- 📝 Read Mastodon statuses, notifications and favourites fully through GraphQL: statuses(ids:), notification(id:), mentions, hashtags and visibility fields, tags loaded on status reads [`4202d29`](https://github.com/bonfire-networks/social/commit/4202d29a0c6bf7207dd10e2f88a5771a535ce2fa), [`7fc833e`](https://github.com/bonfire-networks/bonfire_social/commit/7fc833e27fa0515b1476ffb1d77975c6382ce5cd) (thanks @ivanminutillo)
- 📝 Mastodon event statuses take mentions, hashtags and visibility from the GraphQL node [`06b81c8`](https://github.com/bonfire-networks/bonfire_gatherings/commit/06b81c85b3332b85b99804ce23669e521e60ea97) (thanks @ivanminutillo)
- 📝 Mastodon streaming formats statuses and notifications through GraphQL [`0d441bd`](https://github.com/bonfire-networks/bonfire_notify/commit/0d441bdd9615a4f440fec7398f351a4edb313f8d) (thanks @ivanminutillo)
- 📝 mastodon api : fallback on creation [`1400807`](https://github.com/bonfire-networks/bonfire_posts/commit/14008077ab514aeff6bdf36aead2947aa4aee41f) (thanks @ivanminutillo)
- 📝 events [`fc3af10`](https://github.com/bonfire-networks/bonfire_gatherings/commit/fc3af108b40115c4540b881c565499e5a13d74a2), [`af28cf3`](https://github.com/bonfire-networks/bonfire_gatherings/commit/af28cf3dd98a75cb6a92330d274547f6a49ac737), [`70f97f6`](https://github.com/bonfire-networks/bonfire_geolocate/commit/70f97f6a5ee9f79f1d49c6509bd4e8b67f1e31ec), [`12de24c`](https://github.com/bonfire-networks/social/commit/12de24cceaa5cc3bbb2f6a8d3bfa008c461f3d5e), [`3a115a4`](https://github.com/bonfire-networks/ember/commit/3a115a49e7d931c25a53da1a10b9c4572a2df890), [`842cfdf`](https://github.com/bonfire-networks/community/commit/842cfdfff828fdb54c256dcd86b50e4240723ed0), [`bfe46a9`](https://github.com/bonfire-networks/bonfire-app/commit/bfe46a9b6600f6bf8a0175f9f48f876b52dc77d4) (thanks @mayel)

