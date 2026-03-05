<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Changelog: releases

## Bonfire Social [1.0.2 (2026-03-04)]

### What's new

**Keyword filtering**: You can now filter out posts containing specific words, phrases, or hashtags. Useful for tuning out topics you'd rather not see. Instance admins can set filters that apply across the whole instance, and per-user filtering is coming in a future release.

**Translate posts** with one click: A translate button now appears under posts, making it easy to read content written in other languages. Translation works locally in Chrome out of the box; instance admins or individual users can also set up LibreTranslate or DeepL APIs for broader support (in translation extension settings).

**Feed markers**: Your place in the feed is now saved when you navigate away, so you can pick up where you left off

**Translate posts**: Translate button on posts, so you can read content in other languages with one click (configure API keys for LibreTranslate or DeepL)

**New Dashboard widgets**: Weather, instance stats, and user summary now available for your customizable dashboard.


### Added
- ✨ New setting to control what appears above a reply in your feed: choose between showing the post being replied to, the original post that started the thread, or none [#1714](https://github.com/bonfire-networks/bonfire-app/issues/1714) [#1359](https://github.com/bonfire-networks/bonfire-app/issues/1359) (thanks @mayel and @ivanminutillo)
- 📝 Your place in the feed is now saved when you navigate away, so you can pick up where you left off [#1835](https://github.com/bonfire-networks/bonfire-app/issues/1835) (thanks @ivanminutillo)
- ✨ Press Cmd+Enter (or Ctrl+Enter on Windows/Linux) to publish a post without reaching for the button [#397](https://github.com/bonfire-networks/bonfire-app/issues/397) (thanks @ivanminutillo and @sefsh)
- ✨ keyboard shortcuts (n for opening the composer, - for minimizing, cmd/ctrl + enter for publishing a post) (thanks @ivanminutillo)
- ✨ New Dashboard Weather widget
- 🚀 New Safety settings section
You can now toggle widgets directly in dashboard page
- 🚀 Location data and other hidden metadata are now automatically removed from photos you upload [#1794](https://github.com/bonfire-networks/bonfire-app/issues/1794) (thanks @mayel)
- 🚧 Filter out posts containing specific keywords, configurable by instance admins and soon by individual users [#1001](https://github.com/bonfire-networks/bonfire-app/issues/1001) (thanks @mayel and @ivanminutillo)
- ✨ Translate button on posts, so you can read content in other languages with one click (configure API keys for LibreTranslate or DeepL) [#1809](https://github.com/bonfire-networks/bonfire-app/issues/1809) (thanks @ivanminutillo)
- ✨ Polls now show a preview before you vote, so you can see the options clearly [#1363](https://github.com/bonfire-networks/bonfire-app/issues/1363) (thanks @ivanminutillo)
- ✨ ActivityPub: support for a newer, more robust standard for verifying messages between instances (RFC 9421 HTTP Message Signatures) [#1823](https://github.com/bonfire-networks/bonfire-app/issues/1823) [#1826](https://github.com/bonfire-networks/bonfire-app/issues/1826) [PR #9](https://github.com/bonfire-networks/activity_pub/pull/9) (thanks @dahlia and @mayel)
- ✨ Federated events are now accessible via REST API, making them visible in supported mobile apps [#1772](https://github.com/bonfire-networks/bonfire-app/issues/1772) (thanks @mayel and @ivanminutillo)
- ✨ Account Data & Defaults: surfaces relevant account info and highlights your safety defaults at a glance, including discoverability and search indexing settings (thanks @ivanminutillo and @mayel)
- ✨ Instance Widget: overview of your instance's key defaults: federation behaviour, open vs invite-only registration, and known servers (thanks @ivanminutillo and @mayel)
- ✨ Beyond preferred language, users can now specify other languages they understand, these appear in the Composer language dropdown (thanks @mayel and @ivanminutillo)
- 🚧 Push notifications are now supported in the browser and in mobile apps [#1800](https://github.com/bonfire-networks/bonfire-app/issues/1800) (thanks @mayel)

### Changed
- 🚧 Improvements to ActivityPub Client to Server API (work in progress) [#917](https://github.com/bonfire-networks/bonfire-app/issues/917) (thanks @mayel)
- 🚧 Improvements to Mastodon-compatible API (work in progress) [#916](https://github.com/bonfire-networks/bonfire-app/issues/916) (thanks @ivanminutillo and @mayel)
- 🐛 When replying to a post with a content warning, the reply now inherits the content warning by default [#1805](https://github.com/bonfire-networks/bonfire-app/issues/1805) (thanks @btfreeorg and @ivanminutillo)
- ✨ Read/unread status for messages and notifications is now tied to your account, staying consistent across all your profiles [#1775](https://github.com/bonfire-networks/bonfire-app/issues/1775) (thanks @mayel)
- 🚀 Hashtags handling is improved [#1833](https://github.com/bonfire-networks/bonfire-app/issues/1833) (thanks @mayel and @LiquidParasyte)
- 📝 Traditional Chinese (Taiwan) interface translation added [PR #1837](https://github.com/bonfire-networks/bonfire-app/pull/1837) (thanks @peticipate888)
- 💅 doc/DEPLOY.md: Guix guide: Adapt for latest release. [PR #1768](https://github.com/bonfire-networks/bonfire-app/pull/1768) (thanks @fishinthecalculator)
- ✨ Add tests for when uploading blocklists [#1832](https://github.com/bonfire-networks/bonfire-app/issues/1832) (thanks @ivanminutillo)
- ✨ Add new CORS paths for openid and oauth token [PR #9](https://github.com/bonfire-networks/bonfire_ui_common/pull/9) (thanks @mediaformat)

### Fixed
- ✨ Loading all posts from a remote user's profile was broken [#1785](https://github.com/bonfire-networks/bonfire-app/issues/1785) (thanks @ivanminutillo and @mayel)
- ✨ fix toggling between linear and nested thread (thanks @ivanminutillo and @mayel)
- ✨ fix deeply nested thread UI (thanks @ivanminutillo and @mayel)
- ✨ Following someone incorrectly showed a notification saying you followed yourself [#1814](https://github.com/bonfire-networks/bonfire-app/issues/1814) (thanks @ivanminutillo)
- ✨ Grouped notifications dont allow to see all the users grouped [#1682](https://github.com/bonfire-networks/bonfire-app/issues/1682) (thanks @ivanminutillo and @mayel)
- 🚧 Quote posts accepted on Bonfire should now correctly appear as accepted in Mastodon [#1803](https://github.com/bonfire-networks/bonfire-app/issues/1803) (thanks @mayel and @btfreeorg)
- 🐛 Clicking a post found via direct link now opens the full post correctly [#1779](https://github.com/bonfire-networks/bonfire-app/issues/1779) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Following someone from a remote instance no longer shows a 404 error page [#1434](https://github.com/bonfire-networks/bonfire-app/issues/1434) (thanks @GreenMan-Network and @mayel)
- 📝 nitpick: Fix typo in DEPLOY.md for admin command [PR #1792](https://github.com/bonfire-networks/bonfire-app/pull/1792) (thanks @bailey-coding)
- 📝 nitpick: Remove duplicate 'application/x-bzip2' from mime types [PR #3](https://github.com/bonfire-networks/bonfire_files/pull/3) (thanks @bailey-coding)
- 💅 build/fix(vix): update vix-0.35.0 -> vix-0.38.0 [PR #1821](https://github.com/bonfire-networks/bonfire-app/pull/1821) (thanks @ju1m)
- 🚀 maint/update(assets): fix yarn.lock [PR #10](https://github.com/bonfire-networks/bonfire_ui_common/pull/10) (thanks @ju1m)
- 💅 Image alt text is now visible again in post previews [#1813](https://github.com/bonfire-networks/bonfire-app/issues/1813) (thanks @ivanminutillo)
- 💅 Search result mentions no longer add a blank quote preview to the activity [#1760](https://github.com/bonfire-networks/bonfire-app/issues/1760) (thanks @ivanminutillo)
- 📝 fix: use CLDR gettext_locale_name for correct Gettext locale mapping [PR #14](https://github.com/bonfire-networks/bonfire_common/pull/14) (thanks @peticipate888)
- 🐛 Visiting a non-existent hashtag page no longer causes a crash [#1843](https://github.com/bonfire-networks/bonfire-app/issues/1843) (thanks @ivanminutillo and @mayel)
- 🐛 Content warnings now correctly hide content inside link previews and quoted posts [#1840](https://github.com/bonfire-networks/bonfire-app/issues/1840) (thanks @LiquidParasyte and @mayel)
- 🐛 Language settings for Traditional Chinese, Brazilian Portuguese, and similar locales now work correctly [#1838](https://github.com/bonfire-networks/bonfire-app/issues/1838) - [PR #14](https://github.com/bonfire-networks/bonfire-app/pull/14) (thanks @peticipate888 and @mayel)
- 🐛 Sunrise and sunset times in the weather widget now display correctly [#1819](https://github.com/bonfire-networks/bonfire-app/issues/1819) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Content warnings no longer show raw HTML tags when viewed from Mastodon [#1804](https://github.com/bonfire-networks/bonfire-app/issues/1804) (thanks @wakest and @ivanminutillo)
- 🐛 Navigation arrows on the mobile dashboard no longer overlap article titles [#1798](https://github.com/bonfire-networks/bonfire-app/issues/1798) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Context menus occasionally appeared behind other content instead of on top [#1778](https://github.com/bonfire-networks/bonfire-app/issues/1778) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Search results previews now load correctly [#1797](https://github.com/bonfire-networks/bonfire-app/issues/1797) (thanks @ivanminutillo)
- 🐛 Opening a post no longer triggers a continuous page refresh loop [#1781](https://github.com/bonfire-networks/bonfire-app/issues/1781) (thanks @mayel and @ivanminutillo)
- 🐛 Avatars in flat/non-threaded reply view now show the correct user [#1608](https://github.com/bonfire-networks/bonfire-app/issues/1608) (thanks @ccamara, @mayel, and @ivanminutillo)
- 🐛 Default flavour config is no longer overridden by instance settings [#1604](https://github.com/bonfire-networks/bonfire-app/issues/1604) (thanks @mayel and @ivanminutillo)
- 🐛 Avatars in the feed now load promptly instead of appearing with a noticeable delay [#1577](https://github.com/bonfire-networks/bonfire-app/issues/1577) (thanks @ivanminutillo)
- 🐛 Polls from other instances no longer cause the original post to appear twice in the feed [#1440](https://github.com/bonfire-networks/bonfire-app/issues/1440) (thanks @GreenMan-Network, @mayel, and @ivanminutillo)
- 🐛 Some Mobilizon profiles in search results were showing incorrect names [#1337](https://github.com/bonfire-networks/bonfire-app/issues/1337) (thanks @ivanminutillo and @mayel)
- 📝 Forced dependency on OpenID [#2](https://github.com/bonfire-networks/bonfire_api_graphql/issues/2) - [PR #2155](https://github.com/bonfire-networks/bonfire_api_graphql/pull/2155) (thanks @ju1m and @mayel)


## Bonfire Social [1.0.1 (2026-01-17)]

### New features

- **Follow hashtags**: Discover and join conversations that matter to you, bringing relevant posts into your feed without needing to follow specific people. *(Note: You'll see tagged posts known to your instance, for example, if someone on your server follows the author or boosted the post.)*
- **Scheduled posts**: Plan ahead and have your posts published at just the right moment for your community.
- **Language & translation**: Choose your preferred language(s), set a language for your posts, and translate content from other languages. *(Translation currently works in some Chromium-based browsers, using a local translation engine. Support for other browsers, using LibreTranslate or DeepL, is coming soon.)*
- **Replies in feeds**: Choose what to display above a reply in your feeds: the direct parent post being replied to, the original post that started the thread, or just a label indicating that it is a reply. Set your preference in settings.
- **Polls** _(work in progress)_: Ask questions and gather input from your community. You can now view and vote on remote polls, creating them locally is coming soon. 
- **Mastodon-compatible API** _(work in progress)_: This will make it possible to interact with Bonfire through dozens of fediverse clients available on mobile and desktop. We're gradually adding support for more parts of the API and will be testing it with different third-party clients (please report any issues if you test it with your favourite app!).
- **ActivityPub client-to-server (C2S) API** _(work in progress)_: Opening new possibilities for how you can interact with fediverse through third-party apps.
- **Widgets**: Configure your homepage to display widgets highlighting what interests you most, rather than being dropped straight into a feed of activities. Head to "configure your dashboard" in settings to choose your widgets and switch between a composable widget layout or the standard "my following" feed. Reorder them by dragging and dropping directly on the dashboard (tip: you can also do that with navigation menu items on the left or widgets on the right of most screens).

### Widgets

<img src="https://bonfirenetworks.org/img/widgets.jpg" />

Currently available widgets include:

- **Trending links**: Discover the latest news and what's generating conversation across your instance.
- **Recent articles**: Discover long-form content and blog posts from across your network.
- **Suggested profiles**: Instance admins can curate recommendations to help newcomers find interesting people to follow.

We’d love your feedback on which widgets you’d find most useful. [Let us know](https://github.com/bonfire-networks/bonfire-app/issues/1758) what you’d like to see on your dashboard. What would make Bonfire feel even more like home?
 
### Performance

- **Prioritised federation queues**: We now prioritise the processing of mentions and DMs over regular posts, so direct conversations arrive without delay.
- **Database improvements**: Added more indexes and improved queries for snappier responses.
- **Server-to-server federation**: Various optimisations for smoother communication between instances.

### UI and UX enhancements

We've put work into smoothing out the interface and improving design patterns across the app: small touches that add up to a better experience.

### And more...

This release squashes bugs around federation behaviour, threading, user interface, composer states, and more. See the below for the complete list.

#### Added
- ✨ schedule a post [#1669](https://github.com/bonfire-networks/bonfire-app/issues/1669) (thanks @mayel)
- ✨ Curate a list of suggested profiles for an instance [#1668](https://github.com/bonfire-networks/bonfire-app/issues/1668) (thanks @mayel)
- ✨ Follow Hashtags [#1640](https://github.com/bonfire-networks/bonfire-app/issues/1640) (thanks @dogrileycom, @mayel, and @ivanminutillo)
- ✨ trending links widget [#1726](https://github.com/bonfire-networks/bonfire-app/issues/1726) (thanks @mayel and @ivanminutillo)
- 🚧 Polls: Ask questions with possible choices, gather votes [#914](https://github.com/bonfire-networks/bonfire-app/issues/914) (thanks @ivanminutillo and @mayel)
- ✨ configure my preferred language + set post language [#270](https://github.com/bonfire-networks/bonfire-app/issues/270) 
- ✨ translation options for content not in a language I speak [#1033](https://github.com/bonfire-networks/bonfire-app/issues/1033) (thanks @mayel)
- ✨ Choose which feed to display on homepage for guests [#1647](https://github.com/bonfire-networks/bonfire-app/issues/1647) (thanks @dogrileycom, @ivanminutillo, and @mayel)
- 🚧 ActivityPub Client-to-Server (C2S) API (work in progress) [#917](https://github.com/bonfire-networks/bonfire-app/issues/917) (thanks @ivanminutillo and @mayel)
- 🚧 Mastodon-compatible API (work in progress) [#916](https://github.com/bonfire-networks/bonfire-app/issues/916) (thanks @ivanminutillo and @mayel)

#### Changed
- ⚡ prioritise the processing (in seperate federation queue) of incoming @ mentions and DMs [#1658](https://github.com/bonfire-networks/bonfire-app/issues/1658) (thanks @mayel)
- ✨ add likes toggle to feed filters [#1722](https://github.com/bonfire-networks/bonfire-app/issues/1722) (thanks @mayel)
- 📝 improve list of circles/people to pick when creating a boundary preset [#1297](https://github.com/bonfire-networks/bonfire-app/issues/1297) (thanks @ivanminutillo and @mayel)
- 📝 easier way to see which instances I've blocked (as an admin or a user) [#1630](https://github.com/bonfire-networks/bonfire-app/issues/1630) (thanks @jonpincus, @mayel, and @ivanminutillo)
- 📝 Show loading indicator during search operations [#1212](https://github.com/bonfire-networks/bonfire-app/issues/1212) (thanks @ivanminutillo and @mayel)
- 📝 Replying to a comment within a thread should not include all the thread participants by default, instead of just the ones included in the post i'm replying to [#1615](https://github.com/bonfire-networks/bonfire-app/issues/1615) (thanks @ivanminutillo and @mayel)
- 💅 instance permissions should show all verbs [#1611](https://github.com/bonfire-networks/bonfire-app/issues/1611) (thanks @mayel)
- 📝 when adding a moderator via instance settings, it should autocomplete only with local users [#1610](https://github.com/bonfire-networks/bonfire-app/issues/1610) (thanks @mayel)
- 🚀 add missing ecto indexes [#1588](https://github.com/bonfire-networks/bonfire-app/issues/1588) (thanks @ivanminutillo and @mayel)
- 💅 Article preview in feed shows all the links included in the article with previews, leading to a confusing UX [#1578](https://github.com/bonfire-networks/bonfire-app/issues/1578) (thanks @ivanminutillo and @mayel)
- 📝 Upgrade Hammer integration [#1522](https://github.com/bonfire-networks/bonfire-app/issues/1522) (thanks @mayel)
- 🚀 remove phx-update="append" which is not longer supported in LV [#1492](https://github.com/bonfire-networks/bonfire-app/issues/1492) (thanks @mayel and @ivanminutillo)
- ⚡ optimise / short circuit incoming Delete activities for unknown remote objects/actors [#850](https://github.com/bonfire-networks/bonfire-app/issues/850) (thanks @mayel)
- 🚧 MacOS Dev Setup Incompatibility [#1670](https://github.com/bonfire-networks/bonfire-app/issues/1670) (thanks @mayel and @harveypitt)
- 🐛 Flags should not be automatically sent to remote instances as reports [#1626](https://github.com/bonfire-networks/bonfire-app/issues/1626) (thanks @jonpincus and @mayel)
- 🚀 updated [docs](https://docs.bonfirenetworks.org/readme.html)
- 🔧 Settings: order of widgets on dashboard [#935](https://github.com/bonfire-networks/bonfire-app/issues/935) (thanks @mayel and @ivanminutillo)
- 🚧 replace milisecond numbers or calculations with `to_timeout` [#1729](https://github.com/bonfire-networks/bonfire-app/issues/1729) (thanks @vishakha1411 and @mayel)

#### Fixed
- 📝 when i reply to a remote post, the boundary default to local [#1687](https://github.com/bonfire-networks/bonfire-app/issues/1687) (thanks @ivanminutillo)
- 📝 when i minimize the composer that contains a reply, the reply_to disappear [#1686](https://github.com/bonfire-networks/bonfire-app/issues/1686) (thanks @ivanminutillo)
- 📝 fix(app pages): useless closing div tag breaking layout [PR #7](https://github.com/bonfire-networks/website-blog/pull/7) (thanks @Spratch)
- 📝 Boost icon does not darken after boost. [#1642](https://github.com/bonfire-networks/bonfire-app/issues/1642) (thanks @mayel and @ivanminutillo)
- 📝 Accept Follow activities should not have cc: Public [#1712](https://github.com/bonfire-networks/bonfire-app/issues/1712) (thanks @ivanminutillo)
- 🚧 MacOS Dev Setup Incompatibility [#1670](https://github.com/bonfire-networks/bonfire-app/issues/1670) [PR #1672](https://github.com/bonfire-networks/bonfire-app/pull/1672) (thanks @mayel and @harveypitt)
- 📝 quote button doesn't open compose modal [#1609](https://github.com/bonfire-networks/bonfire-app/issues/1609) (thanks @mayel and @ivanminutillo)
- 📝 Remote follow remains stucked in requested even for auto-followable users [#1695](https://github.com/bonfire-networks/bonfire-app/issues/1695) (thanks @ivanminutillo and @mayel)
- 🐛 Creating a circle from Peertube followers has multiple issues. [#1716](https://github.com/bonfire-networks/bonfire-app/issues/1716) (thanks @ozonedGH)
- 🐛 When creating a client with openid, bonfire_open_id appears to be concatenating the instance name with the app name. The redirect_uri being passed seems malformed [#1692](https://github.com/bonfire-networks/bonfire-app/issues/1692) (thanks @ivanminutillo and @mayel)
- 🐛 typo: cdlr.ex => cldr.ex [#1676](https://github.com/bonfire-networks/bonfire-app/issues/1676) - [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m)
- 🐛 RuntimeError occurs during user signup when the undiscoverable flag is set to true [#1671](https://github.com/bonfire-networks/bonfire-app/issues/1671) (thanks @harveypitt and @mayel)
- 🐛 pinned ranch is too old to support Unix socket permissions [#1667](https://github.com/bonfire-networks/bonfire-app/issues/1667) - [PR #1871](https://github.com/bonfire-networks/bonfire-app/pull/1871), [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m and @mayel)
- 🐛 Feed Image Display of Photos [#1654](https://github.com/bonfire-networks/bonfire-app/issues/1654) (thanks @dogrileycom and @ivanminutillo)
- 🐛 module Bonfire.RuntimeConfig is not available [#1651](https://github.com/bonfire-networks/bonfire-app/issues/1651) - [PR #1652](https://github.com/bonfire-networks/bonfire-app/pull/1652), [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m and @mayel)
- 🐛 After posting sensitive the next post input has sensitive and title still turned on [#1646](https://github.com/bonfire-networks/bonfire-app/issues/1646) (thanks @mayel and @ivanminutillo)
- 🐛 UX/UX issues [#1641](https://github.com/bonfire-networks/bonfire-app/issues/1641) (thanks @dogrileycom and @mayel)
- 🐛 bonfire-app always loads appsignal's closed-source agent [#1637](https://github.com/bonfire-networks/bonfire-app/issues/1637) - [PR #1812](https://github.com/bonfire-networks/bonfire-app/pull/1812) (thanks @ju1m and @mayel)
- 🐛 Editing a post shows encoded HTML [#1635](https://github.com/bonfire-networks/bonfire-app/issues/1635) (thanks @jonpincus and @mayel)
- 🐛 Updated avatar image doesn't show up in the compose box until I hit refresh [#1634](https://github.com/bonfire-networks/bonfire-app/issues/1634) (thanks @jonpincus, @mayel, and @ivanminutillo)
- 🐛 Error when setting up first user [#1620](https://github.com/bonfire-networks/bonfire-app/issues/1620) (thanks @timorl and @mayel)
- 🐛 A mention-only reply in mastodon has boost verb enabled on a bonfire instance [#1616](https://github.com/bonfire-networks/bonfire-app/issues/1616) (thanks @ivanminutillo and @mayel)
- 🐛 In some cases links in posts are not linkified [#1614](https://github.com/bonfire-networks/bonfire-app/issues/1614) (thanks @mayel and @ivanminutillo)
- 🐛 load more wont show new items if there are also new activities incoming [#1603](https://github.com/bonfire-networks/bonfire-app/issues/1603) (thanks @ivanminutillo)
- 🐛 clicking 'refresh' when looking at *user* federation status as an admin shows instance federation status [#1601](https://github.com/bonfire-networks/bonfire-app/issues/1601) (thanks @mayel)
- 🐛 Slow response after liking an activity [#1589](https://github.com/bonfire-networks/bonfire-app/issues/1589) (thanks @ivanminutillo)
- 🐛 Wrong subject shown in composer when replying to a boosted post [#1572](https://github.com/bonfire-networks/bonfire-app/issues/1572) (thanks @ivanminutillo and @mayel)
- 🐛 minor: compose window emoji obstructed [#1570](https://github.com/bonfire-networks/bonfire-app/issues/1570) (thanks @gillesdutilh and @ivanminutillo)
- 🐛 Inconsistent behaviours when applying more than 1 filter in feed. [#1514](https://github.com/bonfire-networks/bonfire-app/issues/1514) (thanks @ivanminutillo and @mayel)
- 🐛 when adding someone to a shared user profile, usernames should be recognise with or without including @ [#1296](https://github.com/bonfire-networks/bonfire-app/issues/1296) (thanks @mayel and @ivanminutillo)
- 🐛 Pagination resets feed instead of loading older activities when removing time limit [#1285](https://github.com/bonfire-networks/bonfire-app/issues/1285) (thanks @ivanminutillo and @mayel)
- 🐛 locking a thread still allows replying to replies wihin it [#1084](https://github.com/bonfire-networks/bonfire-app/issues/1084) (thanks @mayel)
- 🐛 module Bonfire.RuntimeConfig is not available [PR #1652](https://github.com/bonfire-networks/bonfire-app/pull/1652) (thanks @ju1m)
- 🐛 Heroicons v1 deprecated - v2 support needed [#22](https://github.com/bonfire-networks/iconify_ex/issues/22) - [PR #21](https://github.com/bonfire-networks/iconify_ex/pull/21) (thanks @neilberkman and @mayel)
- 🐛 when i minimize the composer that includes a reply_to, the replied activities disappears [#1576](https://github.com/bonfire-networks/bonfire-app/issues/1576) (thanks @ivanminutillo)
- 💅 Tooltips close unexpectedly during LiveView updates [#1756](https://github.com/bonfire-networks/bonfire-app/issues/1756) (thanks @ivanminutillo)
- 💅 UX: Tooltip outside-click triggers unintended actions [#1755](https://github.com/bonfire-networks/bonfire-app/issues/1755) (thanks @ivanminutillo)
- 📝 mention a local user in the composer is not translated in an actual mention once the post is published [#1753](https://github.com/bonfire-networks/bonfire-app/issues/1753) (thanks @ivanminutillo and @mayel)
- 🐛 Preview Themes goes off Screen [#1746](https://github.com/bonfire-networks/bonfire-app/issues/1746) (thanks @btfreeorg and @ivanminutillo)
- 🐛 Remove erroneous error message when a flash message auto-closes [#1708](https://github.com/bonfire-networks/bonfire-app/issues/1708) (thanks @mayel and @ivanminutillo)



## Bonfire Social [1.0 (2025-11-7)]

### Added
- ✨ docs/DEPLOY.md: Add Guix hosting guide. [PR #1585](https://github.com/bonfire-networks/bonfire-app/pull/1585) (thanks @fishinthecalculator)
- ✨ add postgres autotune [`137ef37`](https://github.com/bonfire-networks/bonfire-app/commit/137ef37b1900f719cfc5cdf15f5f1a2595b9f4e4) (thanks @mayel)
- 💅 Consent-based quoting of posts (showing a preview in feeds/threads) [#1535](https://github.com/bonfire-networks/bonfire-app/issues/1535) (thanks @mayel)

### Changed
- 📝 reply activity in composer overflowed wrongly [#1580](https://github.com/bonfire-networks/bonfire-app/issues/1580) (thanks @ivanminutillo)
- 📝 on closing compose window: confusing button name "cancel" [#1571](https://github.com/bonfire-networks/bonfire-app/issues/1571) (thanks @gillesdutilh and @ivanminutillo)
- 📝 sometime remote threads and posts are orphans [#1232](https://github.com/bonfire-networks/bonfire-app/issues/1232) (thanks @ivanminutillo and @mayel)
- 🚀 make sure replies from Masto appear in the correct thread rather than as a detached reply [#1200](https://github.com/bonfire-networks/bonfire-app/issues/1200) (thanks @mayel)
- 📝 moved auto conf file outside postgres data folder [PR #1619](https://github.com/bonfire-networks/bonfire-app/pull/1619) (thanks @MarekBenjamin)
- 📝 .envrc: Update default Docker setting. [PR #1602](https://github.com/bonfire-networks/bonfire-app/pull/1602) (thanks @fishinthecalculator)
- 🚀 Update build scripts to be more broadly compatible [PR #1](https://github.com/bonfire-networks/ember/pull/1) (thanks @fishinthecalculator)
- 📝 .envrc: Update default Docker setting. [`3f34141`](https://github.com/bonfire-networks/bonfire-app/commit/3f34141127bc9837422e3d17c09a8a2d5cf69355) (thanks @fishinthecalculator)
- 🚧 investigate all n+1 warnings throughout the app [#1581](https://github.com/bonfire-networks/bonfire-app/issues/1581) [`4dd2e5e`](https://github.com/bonfire-networks/bonfire-app/commit/4dd2e5e68626d6ca5857005124489f9403d3cce8) (thanks @mayel)
- 🚧 Investigate missing ecto indexes [#1588](https://github.com/bonfire-networks/bonfire-app/issues/1588)  (thanks @mayel and @ivanminutillo)
- 📝 moved auto conf file outside postgres data folder [`40aafd9`](https://github.com/bonfire-networks/bonfire-app/commit/40aafd918d05d703822aeb52dd8df316d0099366) (thanks @MarekBenjamin)
- ✅ test deletion flows manually with mastodon [#780](https://github.com/bonfire-networks/bonfire-app/issues/780) (thanks @mayel)

### Fixed
- 🐛 Duplicate ID "Bonfire-UI-Social-Graph-FollowButtonLive_Bonfire-UI-Me-WidgetUsersLive_for_01K947MF9W3JAVW5NQ0P13C7QE" for component Bonfire.UI.Social.Graph.FollowButtonLive when rendering template [#1618](https://github.com/bonfire-networks/bonfire-app/issues/1618) (thanks @rzylber and @mayel)
- 🐛 Cannot register first user [#1617](https://github.com/bonfire-networks/bonfire-app/issues/1617) (thanks @timorl and @mayel)
- 🐛 Notifications are not marked as read [#1613](https://github.com/bonfire-networks/bonfire-app/issues/1613) (thanks @ccamara and @mayel)
- 🐛 Cannot approve follower requests [#1612](https://github.com/bonfire-networks/bonfire-app/issues/1612) (thanks @ccamara and @mayel)
- 🐛 Federation with Iceshrimp.NET (and likely all other JSON-LD processing remotes) are broken [#1597](https://github.com/bonfire-networks/bonfire-app/issues/1597) (thanks @wont-work and @mayel)
- 🐛 Crash: Switching themes leads to crash and stuck/default theme [#1595](https://github.com/bonfire-networks/bonfire-app/issues/1595) (thanks @ltning, @daehee, and @ivanminutillo)
- 🐛 Infinite loop on article feed [#1587](https://github.com/bonfire-networks/bonfire-app/issues/1587) (thanks @ivanminutillo)
- 🐛 When including mentions through a reply, need to add a space after last one [#1573](https://github.com/bonfire-networks/bonfire-app/issues/1573) (thanks @ivanminutillo)
- 🐛 Bug: dependency on elixir 1.17.3 doesn't work [#1352](https://github.com/bonfire-networks/bonfire-app/issues/1352) (thanks @vincib and @mayel)
- 🐛 group actors (such as from mobilizon) profile sometimes showing current user's activities [#1294](https://github.com/bonfire-networks/bonfire-app/issues/1294) (thanks @mayel)
- 🐛 seems some remote posts are being duplicated [#1219](https://github.com/bonfire-networks/bonfire-app/issues/1219) (thanks @mayel)
- 🐛 investigate send_update failed because component Bonfire.UI.Reactions.BoostActionLive [#1192](https://github.com/bonfire-networks/bonfire-app/issues/1192) (thanks @ivanminutillo)
- 🐛 error: "** (UndefinedFunctionError) function Phoenix.ConnTest.get/3 is undefined or private [#962](https://github.com/bonfire-networks/bonfire-app/issues/962) (thanks @ivanminutillo)
- 🐛 got ERROR REPORT several times before being able to startup the instance when --force deploying with abra [#953](https://github.com/bonfire-networks/bonfire-app/issues/953) (thanks @ivanminutillo)
- 🐛 evision_windows_fix:run_once/0 is undefined [#950](https://github.com/bonfire-networks/bonfire-app/issues/950) (thanks @ivanminutillo)
- 🐛 Fix open science link in readme [PR #1622](https://github.com/bonfire-networks/bonfire-app/pull/1622) (thanks @MegaKeegMan)
- 🐛 Fix link for Open Science repository in README [`b9d48ec`](https://github.com/bonfire-networks/bonfire-app/commit/b9d48ec32a597cad9f33b515c121bf9a34a604ed) (thanks @ivanminutillo)
- ✨ Convert break-all containers (in composer and in user hero profile) for better readability [#1574](https://github.com/bonfire-networks/bonfire-app/issues/1574) (thanks @ivanminutillo)
- ✨ Fix the workflow to add themes to a flavor [#1425](https://github.com/bonfire-networks/bonfire-app/issues/1425) (thanks @ivanminutillo)


## Bonfire Social [1.0-rc.3 (2025-10-2)]

### ✨ What’s new and improved?

- **Consent-based quoting (FEP-044f):** Bonfire now supports consent-based quoting, introduced through the new ActivityPub extension [FEP-044f](https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md). With this first iteration released alongside Mastodon’s, it marks an important step toward making quoting work smoothly — and respectfully — across the fediverse.

![quote](https://hackmd.io/_uploads/BJrbEX_hll.png)

With Bonfire, you can now:
- Use boundaries to define who can quote your post, who must request first, or who cannot request at all.
- Quote — or request consent to quote — someone else’s post.
- Give or withdraw consent at any time.

![quote2](https://hackmd.io/_uploads/BkVVEQuhgg.jpg)

- **Import your old posts when moving instances:** You can now bring your posts (and optionally their replies) with you when moving to Bonfire from another instance. Imported posts keep their original dates and links, and are added to your timeline in the right order, so your history looks complete. Replies and threads are preserved, as are like/boost counts. This works by automatically "boosting" your old posts (but without flooding people's feeds or notifications with old activities).

- **Other data portability improvements:** Instance migration is now more robust. In addition to follows, blocks, and posts, you can now export and import circles/lists, bookmarks, likes, and boosts. A dedicated dashboard helps you follow the progress of data imports and migrations, so you always know what's happening with your data.

- **Federation status dashboard:** Similarly, you can now easily track your outgoing and incoming federated activities with a new dashboard, making it simpler to monitor federation health and troubleshoot issues.

![fedstatus](https://hackmd.io/_uploads/B17TH7_nel.jpg)

- **RSS/Atom feeds:** Access your data beyond the fediverse: Subscribe to Bonfire feeds via your preferred RSS/Atom client. You can subscribe to specific users or to a feed of your choice, including bookmarks, likes, etc, all available as RSS.

- **Boundary UI & usability improvements:** Boundaries (who can see or interact with your posts) are now easier to use. For example, you can share a post publicly but limit who can reply or quote it. Bonfire’s boundaries now also connect with GoToSocial’s interaction controls and Mastodon's quote authorisations, making them more interoperable across the fediverse. We also drafted a guide about [how you can start using circles and boundaries](https://docs.bonfirenetworks.org/boundaries.html) (feedback welcome!)

![boundary](https://hackmd.io/_uploads/ByzTmMnhel.jpg)

- **Mobile web app improvements**: The progressive web app experience has been refined with UI and UX enhancements that make Bonfire feel more native on mobile devices. Whether you're installing Bonfire to your home screen or using it directly in your mobile browser, the interface now responds more smoothly and adapts better to different screen sizes.

![pwa](https://hackmd.io/_uploads/HyXfo29nll.jpg)

- **Links in posts:** Remote posts now get the same rich URL previews as local ones.

- **Single sign-on**: Bonfire supports OpenID Connect and OAuth2 authentication, allowing instance administrators to configure their preferred identity providers for login and signup. We've tested integration with GitHub, ORCID, Zenodo, and more, making it easier for communities to align authentication with their existing workflows and trust networks. Each instance can define which providers to enable and whether to allow new signups through SSO, giving administrators flexibility in how their communities access Bonfire. Bonfire can also act as an SSO provider itself, so other applications can authenticate users through your instance.  

- **Federation interoperability guide:** Published [interoperability docs](https://docs.bonfirenetworks.org/federation-interoperability.html) to ensure compatibility with other ActivityPub software.

- **User guides:** [New guides](https://docs.bonfirenetworks.org/user-guides.html) and documentation help you get started and make the most of Bonfire's features, whether you're new to the fediverse or exploring advanced capabilities like boundaries and circles. This is a work in progress, so feedback on how things would be better explained or what's missing would be very helpful! These guides are designed to help you understand, use, and configure Bonfire. 

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
- 🚧 add user guides & docs [#1530](https://github.com/bonfire-networks/bonfire-app/issues/1530) (thanks @mayel)
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
- 🚧 add tests to verify custom emoji interop [#1472](https://github.com/bonfire-networks/bonfire-app/issues/1472) (thanks @mayel)
- 🚀 better `just secrets` command [`02de529`](https://github.com/bonfire-networks/bonfire-app/commit/02de529d1d2c8b3cc1f5e634445ba207dd61d6e8) (thanks @mayel)
- 📝 quote the argument to echo [PR #1543](https://github.com/bonfire-networks/bonfire-app/pull/1543) (thanks @uhoreg)
- ✨ Allow reading meilisearch master key secret from file. [PR #1](https://github.com/bonfire-networks/bonfire_search/pull/1) (thanks @fishinthecalculator)
- 🚧 Write some guides and tutorials [#779](https://github.com/bonfire-networks/bonfire-app/issues/779) (thanks @mayel)
- 🚧 publish more exhausive docs for install with coopcloud [#1512](https://github.com/bonfire-networks/bonfire-app/issues/1512) (thanks @mayel)
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
- 🚧 improve oauth/openid login + implement dance tests for them [#1201](https://github.com/bonfire-networks/bonfire-app/issues/1201) (thanks @mayel)
- 📝 attempt fix s3 uploads [`5280ec2`](https://github.com/bonfire-networks/bonfire-app/commit/5280ec22ae1e677f95f4728a0f0feb08c1c37434) (thanks @mayel)
- 🚧 avatar images not showing up in search [#1362](https://github.com/bonfire-networks/bonfire-app/issues/1362) (thanks @mayel and @ivanminutillo)

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

