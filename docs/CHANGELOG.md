<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Bonfire Changelog

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
- 📝 Usage with `tap` [#1](https://github.com/bonfire-networks/arrows/issues/1) (thanks @jamauro and @mayel)
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
- 🚀 update locales + release [`05803fb`](https://github.com/bonfire-networks/bonfire-app/commit/05803fbee6df3f0b45c3dd1ebbf4f0c8f7a7886f) (thanks @mayel)
- 📝 downgrade otp [`ac5edde`](https://github.com/bonfire-networks/bonfire-app/commit/ac5eddeb993af2999a6fa5944b2db4c7299cd894) (thanks @mayel)
- 📝 media [`626d606`](https://github.com/bonfire-networks/bonfire-app/commit/626d606fb37fd44409a948e5bcac270cf1fc372d) (thanks @mayel)
- 📝 attempt fix for image uploads [`f8e7052`](https://github.com/bonfire-networks/bonfire-app/commit/f8e70527df0c20ea718821bf27a5c8a91318af16) (thanks @mayel)
- 📝 templates [`ca21dc4`](https://github.com/bonfire-networks/bonfire-app/commit/ca21dc4e8c1ec46e5113c16cba4c59784977afcc) (thanks @mayel)
- 📝 docker compose fix [`dd852eb`](https://github.com/bonfire-networks/bonfire-app/commit/dd852eb2dcf90cf404b1902c23554c070841822d) (thanks @mayel)
- 📝 themes [`00e3d4e`](https://github.com/bonfire-networks/bonfire-app/commit/00e3d4e4b19d1aa111c94f390ee7850167cf2f49) (thanks @ivanminutillo)
- 📝 version number needs to be compatible with docker tag formatting [`02ee766`](https://github.com/bonfire-networks/bonfire-app/commit/02ee766804a6602035fb793d539caa69ca474614) (thanks @mayel)
- 🚀 better `just secrets` command [`02de529`](https://github.com/bonfire-networks/bonfire-app/commit/02de529d1d2c8b3cc1f5e634445ba207dd61d6e8) (thanks @mayel)
- 🚀 update files extension [`4378cde`](https://github.com/bonfire-networks/bonfire-app/commit/4378cde33e5345e58adcb4cc2bc82aba55c52dbd) (thanks @mayel)
- 🚧 improve oauth/openid login + implement dance tests for them [#1201](https://github.com/bonfire-networks/bonfire-app/issues/1201) [`8c580e6`](https://github.com/bonfire-networks/bonfire-app/commit/8c580e6f411b620b2ee2cc7026af7956911fae0d), [`9ac4782`](https://github.com/bonfire-networks/bonfire-app/commit/9ac4782fd36825ed8497f98aaaf7d1b3c167d638) (thanks @mayel)
- 📝 attempt fix s3 uploads [`5280ec2`](https://github.com/bonfire-networks/bonfire-app/commit/5280ec22ae1e677f95f4728a0f0feb08c1c37434) (thanks @mayel)
- 📝 rel 24 [`55af1e3`](https://github.com/bonfire-networks/bonfire-app/commit/55af1e34356bffc861bb19696759a96949c564b5) (thanks @mayel)
- 🚧 avatar images not showing up in search [#1362](https://github.com/bonfire-networks/bonfire-app/issues/1362) [`55c5d72`](https://github.com/bonfire-networks/bonfire-app/commit/55c5d720a19b7b11731bbbbffcd7d6481aaf0da7) (thanks @mayel and @ivanminutillo)
- 📝 tunnel [`674bd75`](https://github.com/bonfire-networks/bonfire-app/commit/674bd754729e3c08f7bc87e1ddc0c0b54d4a5c6a) (thanks @mayel)
- 📝 more locales [`e5a0ce1`](https://github.com/bonfire-networks/bonfire-app/commit/e5a0ce1d69e68cb6615f5af377199f4a01992900) (thanks @mayel)
- 🚀 misc updates [`fa24f2a`](https://github.com/bonfire-networks/bonfire-app/commit/fa24f2a59f36cda240f839b449bfe1604854c1fa) (thanks @mayel)
- 📝 misc [`c4b27e4`](https://github.com/bonfire-networks/bonfire-app/commit/c4b27e42cc1abe4b199deb8e46e07d8987f6b25b), [`3718c98`](https://github.com/bonfire-networks/bonfire-app/commit/3718c98d5a8a6a4f629b2056148cefff4bc36a33), [`c3720ce`](https://github.com/bonfire-networks/bonfire-app/commit/c3720ce8199f1248964196bead88b4d3f5fabe7c), [`5052e47`](https://github.com/bonfire-networks/bonfire-app/commit/5052e47cd0898940be9a1ff1f05760226cb05775), [`467208a`](https://github.com/bonfire-networks/bonfire-app/commit/467208a7f3860d059fd66af9700416c9db1467e5), [`9bb1134`](https://github.com/bonfire-networks/bonfire-app/commit/9bb1134581d04f824a508fda13ae8cb8d4375665), [`c25aec9`](https://github.com/bonfire-networks/bonfire-app/commit/c25aec9cb80256480974fb6cceef479bf4944199) (thanks @mayel)
- 🚀 update status in readme [`ba8805d`](https://github.com/bonfire-networks/bonfire-app/commit/ba8805dca2af7330e64b400a18d1190874639c2d) (thanks @mayel)

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
- 🐛 fix rel [`30d4597`](https://github.com/bonfire-networks/bonfire-app/commit/30d4597c553c860571663e30d3bd878fb35e32a7) (thanks @mayel)
- 🐛 fix video upload in feed [`3d2091b`](https://github.com/bonfire-networks/bonfire-app/commit/3d2091be756934869bd17b351cbd2b7993bab1b5) (thanks @mayel)
- 🐛 fix docs [`a3f4cde`](https://github.com/bonfire-networks/bonfire-app/commit/a3f4cdebd6595bf0baa5554c7bce4092d3a1300c) (thanks @mayel)

### Security
- 🚨 auth extra logging [`06842f2`](https://github.com/bonfire-networks/bonfire-app/commit/06842f21461c75cb7cdfc61afa7774d7248d79ca) (thanks @mayel)

