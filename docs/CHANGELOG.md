<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Changelog: releases

## Bonfire Social [1.0-rc.3 (unreleased)]

### ✨ What’s new and improved?

- **Consent-based quoting (FEP-044f):** You can now quote posts with user consent, following the new ActivityPub standard extension [FEP-044f](https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md). Bonfire is among the first platforms (alongside Mastodon) to offer this feature in a way that respects user agency and can work across the fediverse.
- **Post import & migration:** You can now bring your posts (and their replies) with you when moving to Bonfire from another instance. Imported posts keep their original dates and links, and are added to your timeline in the right order, so your history looks complete. Replies and threads are preserved, and like/boost counts are kept. This works by automatically "boosting" your old posts (but without flooding people's feeds or notifications with old activities).
- **Federation status dashboard:** Easily track your outgoing and incoming federated activities with a new dashboard, making it simpler to monitor federation health and troubleshoot issues.
- **Migration & data portability:** Instance migration is now more robust. In addition to follows, blocks, and posts, you can now export and import circles/lists, bookmarks, likes, and boosts.
- **Import & migration dashboard:** A dedicated dashboard helps you follow the progress of data imports and migrations, so you always know what's happening with your data.
- **Access your data beyond the fediverse:** Subscribe to RSS/Atom feeds or download posts as markdown.
- **UI & usability improvements:** Setting or editing boundaries (like who can see or interact with a post) is now more intuitive. The media gallery supports swipe and keyboard navigation, and uploads show clearer progress indicators.
- **Links in posts:** Remote posts now get the same rich URL previews as local ones.
- **User guides:** New guides and documentation make it easier for everyone to get started and explore Bonfire's features.

For a full list of changes, see the changelog below.

### Added
- ✨ Consent-based quoting of posts (showing a preview in feeds/threads) [#1535](https://github.com/bonfire-networks/bonfire-app/issues/1535) (thanks @mayel and @ivanminutillo)
- 🌏 Federate info about interaction policies based on the boundaries of an object [#979](https://github.com/bonfire-networks/bonfire-app/issues/979) (thanks @mayel)
- ✨ add migration of user's activities (such as posts) when moving instance [#1528](https://github.com/bonfire-networks/bonfire-app/issues/1528) (thanks @mayel)
- ✨ fetch replies when importing posts during instance migration [#1534](https://github.com/bonfire-networks/bonfire-app/issues/1534) (thanks @mayel)
- ✨ add export/import for circles/lists [#1508](https://github.com/bonfire-networks/bonfire-app/issues/1508) (thanks @mayel)
- ✨ add export/import for bookmarks [#1507](https://github.com/bonfire-networks/bonfire-app/issues/1507) (thanks @mayel)
- ✨ export/import likes & boosts [#1532](https://github.com/bonfire-networks/bonfire-app/issues/1532) (thanks @mayel)
- ✨ UI to view the federation processing queue [#1037](https://github.com/bonfire-networks/bonfire-app/issues/1037) (thanks @mayel)
- 📝 status page to view outgoing and incoming federated activities [#1548](https://github.com/bonfire-networks/bonfire-app/issues/1548) (thanks @mayel)
- ✨ buttons & modal to subscribe to RSS/Atom feeds [#1501](https://github.com/bonfire-networks/bonfire-app/issues/1501) (thanks @mayel)
- ✨ buttons & modal to download markdown for posts [#1502](https://github.com/bonfire-networks/bonfire-app/issues/1502) (thanks @mayel)
- ✨ support bridging using BridgyFed [#1476](https://github.com/bonfire-networks/bonfire-app/issues/1476) (thanks @mayel)
- ✨ add loading indicator that handles both local/federated search results [#1443](https://github.com/bonfire-networks/bonfire-app/issues/1443) (thanks @ivanminutillo)
- ✨ generate URL previews for remote (federated) posts, like we do for local posts [#1291](https://github.com/bonfire-networks/bonfire-app/issues/1291) (thanks @ivanminutillo and @mayel)
- ✨ Add a view to see the status of profile migrations [#1366](https://github.com/bonfire-networks/bonfire-app/issues/1366) (thanks @mayel and @ivanminutillo)
- ✨ Add a visual indicator during large uploads [#1433](https://github.com/bonfire-networks/bonfire-app/issues/1433) (thanks @GreenMan-Network and @mayel)
- 🚧 add user guides & docs [#1530](https://github.com/bonfire-networks/bonfire-app/issues/1530) [`31b01b3`](https://github.com/bonfire-networks/bonfire-app/commit/31b01b3baa4b10c718d66a9bb323c32b4bcf873f) (thanks @mayel)
- ✨ It would be nice if the media gallery had swipe-between on photos and right-left keypad on desktop [#1424](https://github.com/bonfire-networks/bonfire-app/issues/1424) (thanks @ivanminutillo and @mayel)
- ✨ add a setting to change units (eg for wheather) [#1518](https://github.com/bonfire-networks/bonfire-app/issues/1518) (thanks @mayel)

### Changed
- 🚀 improve UX for customising permissions when posting, editing, or defining a boundary (toggling verbs rather than roles) [#1553](https://github.com/bonfire-networks/bonfire-app/issues/1553) (thanks @mayel)
- 💅 UX enhancement: Show the full handle w/ domain plus a “Copy” button in profile [#1537](https://github.com/bonfire-networks/bonfire-app/issues/1537) (thanks @ivanminutillo)
- ✨ merge multiple reactions (likes/boosts) to the same post in notifications feed [#1454](https://github.com/bonfire-networks/bonfire-app/issues/1454) (thanks @mayel)
- 🚀 Default Custom feeds enhancement [#1529](https://github.com/bonfire-networks/bonfire-app/issues/1529) (thanks @ivanminutillo and @mayel)
- 🚀 create integration tests for OpenID and OAuth [#1487](https://github.com/bonfire-networks/bonfire-app/issues/1487) (thanks @mayel)
- ✨ support sign up with openid/oauth providers who don't provide the user's email address [#1017](https://github.com/bonfire-networks/bonfire-app/issues/1017) (thanks @mayel)
- 🚀 improve feed filters UX [#1431](https://github.com/bonfire-networks/bonfire-app/issues/1431) (thanks @ivanminutillo)
- 🚀 handle activities addressed to a as:public collection [#1430](https://github.com/bonfire-networks/bonfire-app/issues/1430) (thanks @mayel)
- 🚀 improve display of multiple audio attachments [#1422](https://github.com/bonfire-networks/bonfire-app/issues/1422) (thanks @mayel and @ivanminutillo)
- ✨ add tests for profile migrations [#1503](https://github.com/bonfire-networks/bonfire-app/issues/1503) (thanks @mayel)
- 🚀 add tests for data import and export [#1322](https://github.com/bonfire-networks/bonfire-app/issues/1322) (thanks @mayel)
- 📝 hide instances from the admin's list of instance-wide circles? [#884](https://github.com/bonfire-networks/bonfire-app/issues/884) (thanks @mayel and @ivanminutillo)
- 📝 optimise text/html processing [`55b8995`](https://github.com/bonfire-networks/bonfire-app/commit/55b89959c4f4f3e577db97ae19a924ce66911ecd), [`0ee1f86`](https://github.com/bonfire-networks/activity_pub/commit/0ee1f8644a03f41ee2dfcd813f9c8334c731874c) (thanks @mayel)
- 🚧 add tests to verify custom emoji interop [#1472](https://github.com/bonfire-networks/bonfire-app/issues/1472) [`d3b4db1`](https://github.com/bonfire-networks/activity_pub/commit/d3b4db1f33e899e40efbfe196e6a4c4615c2d14e) (thanks @mayel)
- 🚀 better `just secrets` command [`02de529`](https://github.com/bonfire-networks/bonfire-app/commit/02de529d1d2c8b3cc1f5e634445ba207dd61d6e8) (thanks @mayel)
- 📝 quote the argument to echo [PR #1543](https://github.com/bonfire-networks/bonfire-app/pull/1543) (thanks @uhoreg)
- ✨ Allow reading meilisearch master key secret from file. [PR #1](https://github.com/bonfire-networks/bonfire_search/pull/1) (thanks @fishinthecalculator)
- 🚧 Write some guides and tutorials [#779](https://github.com/bonfire-networks/bonfire-app/issues/779) [`97cde01`](https://github.com/bonfire-networks/bonfire-app/commit/97cde01de6927d8294ae34aaa322775219a0345b) (thanks @mayel)
- 🚧 publish more exhausive docs for install with coopcloud [#1512](https://github.com/bonfire-networks/bonfire-app/issues/1512) [`1bbc44d`](https://github.com/bonfire-networks/bonfire-app/commit/1bbc44d498bf463da8f7e77c2be314250b04a06e) (thanks @mayel)
- 📝 upgrade phoenix and liveview [`a8355b5`](https://github.com/bonfire-networks/bonfire-app/commit/a8355b52b6bc6ef77dd6e61f6c8e0e1e954cfc62) (thanks @mayel)

### Fixed
- 🐛 fix instance icon/banner uploaded to s3 [#1536](https://github.com/bonfire-networks/bonfire-app/issues/1536) (thanks @mayel)
- 🐛 Hashtag search is not working with Meilisearch backend [#1497](https://github.com/bonfire-networks/bonfire-app/issues/1497) (thanks @GreenMan-Network and @mayel)
- 🐛 Article feed is not loading, looping behavior appears [#1496](https://github.com/bonfire-networks/bonfire-app/issues/1496) (thanks @jeffsikes and @mayel)
- 🐛 Bonfire Social 1.0 RC2 blog post issues [#1469](https://github.com/bonfire-networks/bonfire-app/issues/1469) (thanks @ElectricTea and @mayel)
- 🐛 Notifications never stop Notificationing (after being checked) [#1466](https://github.com/bonfire-networks/bonfire-app/issues/1466) (thanks @ZELFs and @mayel)
- 🐛 activities in all feeds dont follow the chronological order anymore (even when it is set in the config) [#1463](https://github.com/bonfire-networks/bonfire-app/issues/1463) (thanks @ivanminutillo and @mayel)
- 🐛 Investigate why mentions sometimes are converted in mailto link [#1457](https://github.com/bonfire-networks/bonfire-app/issues/1457) (thanks @ivanminutillo and @mayel)
- 🐛 Get Latest Replies not working [#1451](https://github.com/bonfire-networks/bonfire-app/issues/1451) (thanks @jeffsikes and @mayel)
- 🐛 Possibility to have duplicate feed names messes with interface (non-critical) [#1450](https://github.com/bonfire-networks/bonfire-app/issues/1450) (thanks @gillesdutilh and @ivanminutillo)
- 🐛 Remote & only filter is not applied in feed [#1432](https://github.com/bonfire-networks/bonfire-app/issues/1432) (thanks @ivanminutillo)
- 🐛 make sure pubsub works on notifications feed [#1427](https://github.com/bonfire-networks/bonfire-app/issues/1427) (thanks @mayel and @ivanminutillo)
- 🐛 Properly render GIFs in media preview [#1426](https://github.com/bonfire-networks/bonfire-app/issues/1426) (thanks @ivanminutillo)
- 🐛 "Read more" button is always shown on activities when viewign the feed as guest [#1423](https://github.com/bonfire-networks/bonfire-app/issues/1423) (thanks @ivanminutillo)
- 🐛 When a user boosts its own post, the subject is not shown (the subject minimal is shown correctly instead) [#1397](https://github.com/bonfire-networks/bonfire-app/issues/1397) (thanks @ivanminutillo and @mayel)
- 🐛 Following/followers are showing only local users ? [#1374](https://github.com/bonfire-networks/bonfire-app/issues/1374) (thanks @ivanminutillo and @mayel)
- 🐛 The character username of a boosted activity has wrong link attached [#1370](https://github.com/bonfire-networks/bonfire-app/issues/1370) (thanks @ivanminutillo, @mayel, and @WildPowerHammer)
- 🐛 avatar images not showing up in search [#1362](https://github.com/bonfire-networks/bonfire-app/issues/1362) (thanks @ivanminutillo and @mayel)
- 🐛 "Load more" to expand a log post is not working anymore in feeds [#1302](https://github.com/bonfire-networks/bonfire-app/issues/1302) (thanks @ivanminutillo and @mayel)
- 🐛 Fix markdown on release canidate notice in readme [PR #1494](https://github.com/bonfire-networks/bonfire-app/pull/1494) (thanks @ElectricTea)
- 🐛 fix for Caddy v2 [`861b1ca`](https://github.com/bonfire-networks/bonfire-app/commit/861b1ca6f5b2db54abfc2d989c25e576a6c9067b) (thanks @mayel)


## Bonfire Social [1.0-rc.2 (2025-07-08)]

### ✨ What’s new and improved?

- **Long-form publishing:** Going beyond beyond short posts to [read and write in-depth articles](https://bonfire.cafe/post/01JYRX7HCGME693BGCZF6AGGK1), ideal for essays, announcements, or detailed content. Article feeds are now available for RSS readers.
- **Smarter feeds:** New feed options for **events**, **books**, and **articles** help you discover what matters to you most. You can now also filter out your own activities from your feeds when desired.
- **Multi-profiles overview**: A new navigation menu can display all your profiles with notification indicators, allowing quick profile switching.
- **Private by default:** New Bonfire instances start as invite-only, giving admins control over membership from day one.
- **Interface improvements:** We've refined the user experience, enhanced notifications and ensured posts display properly across mobile devices.
- **More reliable:** Tons of fixes for authentication, media uploads, mentions, moderation, and other core features.

Additional improvements include:

- Better translation and localization workflow
- Smoother OAuth/OpenID login and SSO support
- Updated documentation and guides for admins and contributors
- Enhanced S3 integration for uploads
- Lots of small bug fixes on comment threads, messaging, settings, and more

For a comprehensive list of changes, here's the full changelog:

### Added
- ✨ Sanitize text included in the summary [#1421](https://github.com/bonfire-networks/bonfire-app/issues/1421) (thanks @ivanminutillo and @mayel)
- ✨ Add first 200 (configurable) chars in the summary rather than full article [#1420](https://github.com/bonfire-networks/bonfire-app/issues/1420) (thanks @ivanminutillo and @mayel)
- ✨ tell s3 the content type of uploads [#1416](https://github.com/bonfire-networks/bonfire-app/issues/1416) (thanks @mayel)
- ✨ add feed filter to hide my own activities [#1400](https://github.com/bonfire-networks/bonfire-app/issues/1400) (thanks @mayel)
- ✨ document S3 configuration [#1399](https://github.com/bonfire-networks/bonfire-app/issues/1399) (thanks @mayel)
- ✨ better handling for admin signup upon setting up an instance [#1396](https://github.com/bonfire-networks/bonfire-app/issues/1396) (thanks @mayel)
- ✨ make articles available in RSS feeds [#1380](https://github.com/bonfire-networks/bonfire-app/issues/1380) (thanks @mayel)
- ✨ make articles availabe as markdown files [#1379](https://github.com/bonfire-networks/bonfire-app/issues/1379) (thanks @mayel)
- ✨ add an indication for translators of where (in the web app, not just the code) a string is used [#1373](https://github.com/bonfire-networks/bonfire-app/issues/1373) (thanks @mayel)
- ✨ if an article has an image attached display it as the article cover and do not display the media in the article activity preview [#1372](https://github.com/bonfire-networks/bonfire-app/issues/1372) (thanks @ivanminutillo and @mayel)
- ✨ Make sure peered is recorded for unsupported ActivityPub types (APActivity) [#1368](https://github.com/bonfire-networks/bonfire-app/issues/1368) (thanks @mayel)
- ✨ implement custom asset url for url generation by `Entrepot.Storages.S3` [#1360](https://github.com/bonfire-networks/bonfire-app/issues/1360) (thanks @mayel and @jeffsikes)
- ✨ Enable invite-only by default when setting up an instance [#1348](https://github.com/bonfire-networks/bonfire-app/issues/1348) (thanks @mayel)
- ✨ Add new feed presets for Events, Books, Articles [#1335](https://github.com/bonfire-networks/bonfire-app/issues/1335) (thanks @ivanminutillo and @mayel)
- ✨ Let users create Article (instead of a note) from the Composer [#1327](https://github.com/bonfire-networks/bonfire-app/issues/1327) (thanks @ivanminutillo)
- ✨ Create "Article" activity type to properly federate Long-form Text [#1326](https://github.com/bonfire-networks/bonfire-app/issues/1326) (thanks @ivanminutillo and @mayel)
- ✨ Add Articles feed presets [#1325](https://github.com/bonfire-networks/bonfire-app/issues/1325) (thanks @ivanminutillo and @mayel)
- ✨ Create custom article previews [#1324](https://github.com/bonfire-networks/bonfire-app/issues/1324) (thanks @ivanminutillo and @mayel)
- ✨ migration & importing follows should be disabled when federation is disabled [#1321](https://github.com/bonfire-networks/bonfire-app/issues/1321) (thanks @mayel)
- ✨ Add tests for the new custom feed control tabs [#1306](https://github.com/bonfire-networks/bonfire-app/issues/1306) (thanks @ivanminutillo)
- ✨ Improve long form / article preview [#1305](https://github.com/bonfire-networks/bonfire-app/issues/1305) (thanks @ivanminutillo)
- ✨ Show number of new notifications & messages for each user on switch profile page [#878](https://github.com/bonfire-networks/bonfire-app/issues/878) (thanks @mayel)
- ✨ Local timeline sometime includes remote activities [#545](https://github.com/bonfire-networks/bonfire-app/issues/545) (thanks @mayel)
- ✨ add phoenix_gon dep [`aa1d50c`](https://github.com/bonfire-networks/bonfire-app/commit/aa1d50cf6480b519a530f5c1369d104ef83bbe14) (thanks @mayel)
- ✨ Create HOWTO_add_feed_preset.md [`b3c8969`](https://github.com/bonfire-networks/bonfire-app/commit/b3c89696286c465c5639de4a742446d95b98e709) (thanks @ivanminutillo)

### Changed
- 💅 If an article does not have an image, remove the current preview [#1371](https://github.com/bonfire-networks/bonfire-app/issues/1371) (thanks @ivanminutillo)
- 💅 disable @ mention autocomplete in DMs [#1351](https://github.com/bonfire-networks/bonfire-app/issues/1351) (thanks @ivanminutillo and @mayel)
- 💅 longer posts gets truncated but "read more" button is not showing up [#1344](https://github.com/bonfire-networks/bonfire-app/issues/1344) (thanks @ivanminutillo and @mayel)
- 💅 show media attachments on comments within a thread [#1341](https://github.com/bonfire-networks/bonfire-app/issues/1341) (thanks @mayel)
- 💅 link preview should be included also in reply_to [#1339](https://github.com/bonfire-networks/bonfire-app/issues/1339) (thanks @ivanminutillo)
- 📝 Sometime text after a mention becomes part of the link [#1334](https://github.com/bonfire-networks/bonfire-app/issues/1334) (thanks @ivanminutillo and @mayel)
- 🚀 During profile creation, if a user enters a username/handle first before the name field, the handle field is overwritten by the name field [#1332](https://github.com/bonfire-networks/bonfire-app/issues/1332) (thanks @ivanminutillo)
- 💅 In the Notification view, the "clear notifications" button misses an explanation tooltip [#1318](https://github.com/bonfire-networks/bonfire-app/issues/1318) (thanks @ivanminutillo)
- 🚀 make sure SSO signup works on invite-only instances [#1315](https://github.com/bonfire-networks/bonfire-app/issues/1315) (thanks @mayel)
- 🚀 get localisation in place again [#1274](https://github.com/bonfire-networks/bonfire-app/issues/1274) (thanks @mayel and @ivanminutillo)
- 🚀 Documentation: Build on Bonfire section [#939](https://github.com/bonfire-networks/bonfire-app/issues/939) (thanks @ivanminutillo and @mayel)
- 💅 display activitystreams objects correctly in reply_to [#838](https://github.com/bonfire-networks/bonfire-app/issues/838) (thanks @mayel)
- 🚀 Document data patterns [#170](https://github.com/bonfire-networks/bonfire-app/issues/170) (thanks @mayel)
- 📝 attempt fix for image uploads [`f8e7052`](https://github.com/bonfire-networks/bonfire-app/commit/f8e70527df0c20ea718821bf27a5c8a91318af16) (thanks @mayel)
- 📝 docker compose fix [`dd852eb`](https://github.com/bonfire-networks/bonfire-app/commit/dd852eb2dcf90cf404b1902c23554c070841822d) (thanks @mayel)
- 📝 version number needs to be compatible with docker tag formatting [`02ee766`](https://github.com/bonfire-networks/bonfire-app/commit/02ee766804a6602035fb793d539caa69ca474614) (thanks @mayel)
- 🚀 better `just secrets` command [`02de529`](https://github.com/bonfire-networks/bonfire-app/commit/02de529d1d2c8b3cc1f5e634445ba207dd61d6e8) (thanks @mayel)
- 🚀 update files extension [`4378cde`](https://github.com/bonfire-networks/bonfire-app/commit/4378cde33e5345e58adcb4cc2bc82aba55c52dbd) (thanks @mayel)
- 🚧 improve oauth/openid login + implement dance tests for them [#1201](https://github.com/bonfire-networks/bonfire-app/issues/1201) [`8c580e6`](https://github.com/bonfire-networks/bonfire-app/commit/8c580e6f411b620b2ee2cc7026af7956911fae0d), [`9ac4782`](https://github.com/bonfire-networks/bonfire-app/commit/9ac4782fd36825ed8497f98aaaf7d1b3c167d638) (thanks @mayel)
- 📝 attempt fix s3 uploads [`5280ec2`](https://github.com/bonfire-networks/bonfire-app/commit/5280ec22ae1e677f95f4728a0f0feb08c1c37434) (thanks @mayel)
- 🚧 avatar images not showing up in search [#1362](https://github.com/bonfire-networks/bonfire-app/issues/1362) [`55c5d72`](https://github.com/bonfire-networks/bonfire-app/commit/55c5d720a19b7b11731bbbbffcd7d6481aaf0da7) (thanks @mayel and @ivanminutillo)

### Fixed
- 🐛 incoming CW on remote posts not being recognised [#1411](https://github.com/bonfire-networks/bonfire-app/issues/1411) (thanks @mayel)
- 🐛 some image attachments of remote posts not being shown [#1410](https://github.com/bonfire-networks/bonfire-app/issues/1410) (thanks @mayel)
- 🐛 boosting a post shows the wrong subject when shown via pubsub [#1409](https://github.com/bonfire-networks/bonfire-app/issues/1409) (thanks @mayel)
- 🐛 Instance and User Settings - Extra Settings page errors out [#1408](https://github.com/bonfire-networks/bonfire-app/issues/1408) (thanks @jeffsikes and @mayel)
- 🐛 Custom Emoji are not appearing [#1407](https://github.com/bonfire-networks/bonfire-app/issues/1407) (thanks @jeffsikes and @mayel)
- 🐛 Invite link from Admin UI and Email for docker builds are malformed [#1406](https://github.com/bonfire-networks/bonfire-app/issues/1406) (thanks @jeffsikes)
- 🐛 fix cross-instance flagging test [#1402](https://github.com/bonfire-networks/bonfire-app/issues/1402) (thanks @mayel)
- 🐛 Bug: Image Alt Text is cleared out when you start typing in the post body. [#1398](https://github.com/bonfire-networks/bonfire-app/issues/1398) (thanks @jeffsikes and @ivanminutillo)
- 🐛 Bug: writing a post with empty lines results in double the space between paragraphs [#1395](https://github.com/bonfire-networks/bonfire-app/issues/1395) (thanks @mayel and @ivanminutillo)
- 🐛 open deeply nested comment branch for the comment being loaded [#1394](https://github.com/bonfire-networks/bonfire-app/issues/1394) (thanks @mayel)
- 🐛 Bug: should not send desktop notifications for pubsub other than notifications [#1386](https://github.com/bonfire-networks/bonfire-app/issues/1386) (thanks @mayel)
- 🐛 youtube link appears broken [#1382](https://github.com/bonfire-networks/bonfire-app/issues/1382) (thanks @ivanminutillo and @mayel)
- 🐛 Bug: when typing on the search page, the input box looses focus [#1369](https://github.com/bonfire-networks/bonfire-app/issues/1369) (thanks @mayel)
- 🐛 Avatar icon not showing up in circle list members [#1365](https://github.com/bonfire-networks/bonfire-app/issues/1365) (thanks @ivanminutillo and @mayel)
- 🐛 Avatar icon not showing up in followers/following list [#1364](https://github.com/bonfire-networks/bonfire-app/issues/1364) (thanks @ivanminutillo and @mayel)
- 🐛 Subject is not shown in DM main post when it's current user [#1350](https://github.com/bonfire-networks/bonfire-app/issues/1350) (thanks @ivanminutillo and @mayel)
- 🐛 sometimes get an error when trying to post rich context copy/pasted into the composer [#1349](https://github.com/bonfire-networks/bonfire-app/issues/1349) (thanks @mayel)
- 🐛 cw not being taken into account in reply_to [#1347](https://github.com/bonfire-networks/bonfire-app/issues/1347) (thanks @mayel)
- 🐛 link preview doesn't appear correctly when post/comment is shown via pubsub [#1346](https://github.com/bonfire-networks/bonfire-app/issues/1346) (thanks @mayel)
- 🐛 @ mention not being taken into account when replying to a post [#1345](https://github.com/bonfire-networks/bonfire-app/issues/1345) (thanks @mayel and @ivanminutillo)
- 🐛 CW "Show more" doesn't seem to work when logged out [#1343](https://github.com/bonfire-networks/bonfire-app/issues/1343) (thanks @mayel)
- 🐛 A mention followed by an emoji is not rendered as a mention [#1342](https://github.com/bonfire-networks/bonfire-app/issues/1342) (thanks @ivanminutillo and @mayel)
- 🐛 fix UI tests [#1340](https://github.com/bonfire-networks/bonfire-app/issues/1340) (thanks @mayel and @ivanminutillo)
- 🐛 In the profile settings page, it's not clear if the avatar and cover are being uploaded or processed. [#1333](https://github.com/bonfire-networks/bonfire-app/issues/1333) (thanks @ivanminutillo)
- 🐛 Better handle links in activity preview to avoid overflow [#1331](https://github.com/bonfire-networks/bonfire-app/issues/1331) (thanks @ivanminutillo)
- 🐛 Clicking on a link always seems to redirect to /feed/local and then to the expected url [#1330](https://github.com/bonfire-networks/bonfire-app/issues/1330) (thanks @ivanminutillo)
- 🐛 unknown AP types don't appear correctly in search results the first time they're searched [#1329](https://github.com/bonfire-networks/bonfire-app/issues/1329) (thanks @mayel)
- 🐛 Bug: APActivity objects not being shown correctly in feed [#1323](https://github.com/bonfire-networks/bonfire-app/issues/1323) (thanks @mayel)
- 🐛 Settings Profile: Error message after adding some aliases to my Pixelfed / Mastodon accounts [#1317](https://github.com/bonfire-networks/bonfire-app/issues/1317) (thanks @ivanminutillo and @mayel)
- 🐛 Missing tooltips when mouse-over some actions button in activities. [#1316](https://github.com/bonfire-networks/bonfire-app/issues/1316) (thanks @ivanminutillo)
- 🐛 If I set the feed time limit default to 1 month, it defaults to "day" in the feed control ui [#1309](https://github.com/bonfire-networks/bonfire-app/issues/1309) (thanks @ivanminutillo)
- 🐛 Reply_to subject in smart input is not showing [#1308](https://github.com/bonfire-networks/bonfire-app/issues/1308) (thanks @ivanminutillo)
- 🐛 Ensure feeds doesn't overflow on mobile [#1307](https://github.com/bonfire-networks/bonfire-app/issues/1307) (thanks @ivanminutillo)
- 🐛 Bug: Mentions sometimes are parsed as URLs or mailto: links [#1303](https://github.com/bonfire-networks/bonfire-app/issues/1303) (thanks @xplosionmind, @mayel, and @ivanminutillo)
- 🐛 Bug: default flavour is non-existent (docs) [#1243](https://github.com/bonfire-networks/bonfire-app/issues/1243) (thanks @Lechindianer and @mayel)
- 🐛 aliases not appearing on user profile [#1233](https://github.com/bonfire-networks/bonfire-app/issues/1233) (thanks @mayel)
- 🐛 Make sure pubsub works for new activities on user profile [#1214](https://github.com/bonfire-networks/bonfire-app/issues/1214) (thanks @mayel)
- 🐛 Access denied when trying to view an uploaded document (in Scaleway's S3) [#947](https://github.com/bonfire-networks/bonfire-app/issues/947) (thanks @mayel and @ivanminutillo)
- 🐛 fix aliases on profile [`79ebb16`](https://github.com/bonfire-networks/bonfire-app/commit/79ebb16e742804f20619edada16291315625db8f) (thanks @mayel)
- 🐛 fix for openid [`ebb0a47`](https://github.com/bonfire-networks/bonfire-app/commit/ebb0a47d3771c963533b1da081bb4365cea9a619) (thanks @mayel)
- 🐛 fix video upload in feed [`3d2091b`](https://github.com/bonfire-networks/bonfire-app/commit/3d2091be756934869bd17b351cbd2b7993bab1b5) (thanks @mayel)

### Security
- 🚨 auth extra logging [`06842f2`](https://github.com/bonfire-networks/bonfire-app/commit/06842f21461c75cb7cdfc61afa7774d7248d79ca) (thanks @mayel)

