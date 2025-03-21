<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Bonfire Changelog

## [0.3.5-beta (2022-09-23)]
### Added
- Coordination MVP [#445](https://github.com/bonfire-networks/bonfire-app/issues/445) by mayel & ivanminutillo
- UI to enable/disable extensions in settings [#448](https://github.com/bonfire-networks/bonfire-app/issues/448) 
- Static page generator [#444](https://github.com/bonfire-networks/bonfire-app/issues/444) 
- Publish creation of sub-topic in the topic's feed [#439](https://github.com/bonfire-networks/bonfire-app/issues/439) by mayel

### Changed
- Refactor navs/sidebars to use dynamic navigation & widgets provided by extensions [#447](https://github.com/bonfire-networks/bonfire-app/issues/447) 

### Other
- When I reply to a task, the activity in the feed does not show the parent activity [#449](https://github.com/bonfire-networks/bonfire-app/issues/449) 
- Use same composer for create post / topic / create a new list / create task

## [0.3.4-beta.8 (2022-08-26)]
### Added
- Remember position in timeline [#392](https://github.com/bonfire-networks/bonfire-app/issues/392) by mayel
- Should be able to click on a notification to see the related activity [#412](https://github.com/bonfire-networks/bonfire-app/issues/412) by mayel
- Actions when someone clicks on follow/boost/like/reply buttons on a profile or feed while logged out [#441](https://github.com/bonfire-networks/bonfire-app/issues/441) 
- Combine duplicate posts [#396](https://github.com/bonfire-networks/bonfire-app/issues/396) by mayel

### Changed
- User preferences missing a consistent UX structure [#430](https://github.com/bonfire-networks/bonfire-app/issues/430) 
- Bug: pop-ups from compose box are hidden if close to edge [#394](https://github.com/bonfire-networks/bonfire-app/issues/394) 
- reset the CW field after posting [#378](https://github.com/bonfire-networks/bonfire-app/issues/378) 
- On mobile, there should be an obvious way to reply to a single post when viewing it by itself [#371](https://github.com/bonfire-networks/bonfire-app/issues/371) 
- Alerts and feedback messages need to adopt a solid pattern [#305](https://github.com/bonfire-networks/bonfire-app/issues/305) 

### Fixed
- i can't see what i'm typing past a certain amount of text. Like rivht now i dont' see what i'm typing. Might be some typos then^^ [#425](https://github.com/bonfire-networks/bonfire-app/issues/425) 
- Bug: When you switch user it *sometimes* stays on the switch user page [#377](https://github.com/bonfire-networks/bonfire-app/issues/377) by mayel

### Other
- Make push notification system more solid [#180](https://github.com/bonfire-networks/bonfire-app/issues/180) 
- Test/fix/improve graceful degradation (usage without JS, or without a LiveView websocket, i.e. when logged out) [#365](https://github.com/bonfire-networks/bonfire-app/issues/365) by mayel
- use @prop in Surface views/components instead of e(assigns, :prop, default) and declare defaults in props or mount/1 [#414](https://github.com/bonfire-networks/bonfire-app/issues/414) 


## [0.3.4-beta.6 (2022-08-19)]
### Changed
- 3 options for smart input (sidebar, modal, floating) and improve responsive (modal on small screens) [#443](https://github.com/bonfire-networks/bonfire-app/issues/443) 
- Improve feeds async loading [#437](https://github.com/bonfire-networks/bonfire-app/issues/437) by mayel
- Improve media/link attachments [#440](https://github.com/bonfire-networks/bonfire-app/issues/440) 

### Fixed
- Show and count only local users in user directory [#438](https://github.com/bonfire-networks/bonfire-app/issues/438) by mayel

## [0.3.4 (2022-08-09)]
### Added
- Define & implement granular role & permission system for instance administration and moderation [#406](https://github.com/bonfire-networks/bonfire-app/issues/406) 

## [0.3.3 (2022-08-02)]
### Added
- Define & implement granular role & permission system for instance administration and moderation [#406](https://github.com/bonfire-networks/bonfire-app/issues/406) 

## [0.3.2 (2022-07-30)]
### Added
- Pagination topics list & feeds within topics [#431](https://github.com/bonfire-networks/bonfire-app/issues/431) 
- Check boundaries of a topic when tagging and if allowed auto-boost the tagged object in the topic's outbox [#428](https://github.com/bonfire-networks/bonfire-app/issues/428) 
- Show followed topics on a list [#424](https://github.com/bonfire-networks/bonfire-app/issues/424) 
- Topic settings [#423](https://github.com/bonfire-networks/bonfire-app/issues/423) 
- Topic activity preview [#422](https://github.com/bonfire-networks/bonfire-app/issues/422) 
- Browse topics [#421](https://github.com/bonfire-networks/bonfire-app/issues/421) 
- Tag something (eg. post/user) with a topic at any time (depending on boundaries) [#416](https://github.com/bonfire-networks/bonfire-app/issues/416) 
- Tag a post with a topic when writing a new post (or reply) [#415](https://github.com/bonfire-networks/bonfire-app/issues/415) 
- CRUD topics [#410](https://github.com/bonfire-networks/bonfire-app/issues/410) 
- Create a users directory [#159](https://github.com/bonfire-networks/bonfire-app/issues/159) 

### Changed
- Optimise LiveView rendering [#426](https://github.com/bonfire-networks/bonfire-app/issues/426) 
- Allow us to scroll from anywhere [#391](https://github.com/bonfire-networks/bonfire-app/issues/391) 

### Other
- Add unique key to encircle [#248](https://github.com/bonfire-networks/bonfire-app/issues/248) 
- Database Question [#3](https://github.com/bonfire-networks/activity_pub/issues/3) 
- Being able to change activity type from the composer [#429](https://github.com/bonfire-networks/bonfire-app/issues/429) 
- use created and extra_info mixins on Category [#433](https://github.com/bonfire-networks/bonfire-app/issues/433) 
- check boundaries for edit and archive topic [#434](https://github.com/bonfire-networks/bonfire-app/issues/434) 


## 0.3.1-beta.9 (2022-07-22)
### Fixed
- BUG:Responsive, navigation goes under the mobile bottom tab [#420](https://github.com/bonfire-networks/bonfire-app/issues/420) by ivanminutillo


## 0.3.1-beta (2022-07-19)
### Added
- Circles & flexible boundaries [#223](https://github.com/bonfire-networks/bonfire-app/issues/223) by mayel & ivanminutillo
- Compose box at the bottom of the screen as an alternative to the standard microblogging input box [#419](https://github.com/bonfire-networks/bonfire-app/issues/419) 
- "Compact layout" in user preferences [#418](https://github.com/bonfire-networks/bonfire-app/issues/418) 
- Fetch metadata of links included in a post and show previews (of images, videos, etc) in feeds [#314](https://github.com/bonfire-networks/bonfire-app/issues/314) 

### Changed
- Pasting images into the editor should upload them [#411](https://github.com/bonfire-networks/bonfire-app/issues/411) 
- Bug: When starting from the feed page, clicking back would exit the site [#400](https://github.com/bonfire-networks/bonfire-app/issues/400) 
- /write page was missing the boundary selector [#398](https://github.com/bonfire-networks/bonfire-app/issues/398) 
- Keep me logged in [#395](https://github.com/bonfire-networks/bonfire-app/issues/395) 
- Font size is too small in compose window [#388](https://github.com/bonfire-networks/bonfire-app/issues/388) 
- UI: moved topbar in the header to sidebar [#362](https://github.com/bonfire-networks/bonfire-app/issues/362) 
- Improved responsive UI for use on small screens

### Fixed
- Bug: some notifications / live feed updates were making all other activities in the feed disappear [#383](https://github.com/bonfire-networks/bonfire-app/issues/383) by mayel
- Bug: followed/followers pages remained empty despite having followed people [#373](https://github.com/bonfire-networks/bonfire-app/issues/373) by mayel
- Bug: followed activity missing the person (in main feeds) [#372](https://github.com/bonfire-networks/bonfire-app/issues/372) by mayel
- Bug: follow notification clears the home feed except for the "new follow" post [#366](https://github.com/bonfire-networks/bonfire-app/issues/366) by mayel
- Bug: images attached to a post should appear in the feed [#364](https://github.com/bonfire-networks/bonfire-app/issues/364) 

