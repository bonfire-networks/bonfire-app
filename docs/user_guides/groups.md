# Groups

A group is a shared space: people join it, post in it, and talk in its topics. When you follow a person, you see what *they* post. When you join a group, you see what its *members* post there, and you can post there too.

Each group decides who can find it, who can join, who can post and who can read its posts. The group's page tells you what applies.

> This guide is for the basics of using a group. For info about moderator tools, see [Running a Group](./group-moderation.md).

## Finding groups

Open **Groups** in the sidebar, or go to `/groups`.

- **All groups** lists the groups you can see. Search by name, and filter by where the group lives and how people join.
- **Joined** lists the groups you are a member of.
- **Archived** lists groups their moderators have closed. You can still read them, but nobody can post.

Each card shows the number of members and how to get in.

## Getting in

The button on a group's page depends on the group:

- **Join**: you become a member right away.
- **Request to join**: a moderator has to approve you. The button then reads **Pending**. To take your request back, press **Pending** and choose **Withdraw request**. **Keep request** leaves it as it is.
- No button: the group is invite-only, and only its moderators add new members.

If a moderator approves your request, you become a member and the group opens to you. 

In a group whose posts are for members only, you can still see its name, description and rules before you join. A topic in such a group shows the same: a way to ask to join, and a way to sign in if you aren't.

### Following is not joining

You can follow a group without joining it. Following puts the group's public posts in your home feed. Joining makes you a member, so you can post and, in private groups, read members-only posts. You can be a member without following, and follow without being a member.

To stop seeing a group's posts in your home feed without leaving it, unfollow it: you stay a member, and can still read and post on its page. For a group on another instance, though, its new posts reach your instance only while someone here follows it, so after you unfollow, its page here may not show its latest posts. To be notified of each new post in a group, press the bell on its page.

## Inside a group

- **The header** shows the group's name, description, address and how many members it has. Your status shows there too: **Joined** or **Moderator**.
- **Topics** appear as chips under the header. **All** shows everything in the group; a topic shows only its own discussions. A topic has the same access rules as its group.
- **About, Rules and Moderators** are in the panel on the right. On a phone, open the widgets drawer from the page header.
- **Pinned posts** sit at the top of the group or topic: moderators pin what they want everyone to see, such as a welcome post or the rules.
- **Members** lists everyone in the group, with filters for moderators and members. If joining needs a request or an invitation, only members see the names; others see a count.

The **⋯** menu has the rest: follow, copy the link, RSS, pin the group to your sidebar, flag the group to your instance's moderators (and, if you choose, to its home instance's), and leave.

## Posting in a group

On the group's page, press **Start a discussion…**. The composer opens with the group already chosen.

Two choices decide where your post goes:

- **Post in**: the group or a topic if it has any.
- **Visible to**: who can read it. The group's usual audience is selected for you.

Some limits always apply, whatever you choose:

- A group that doesn't federate keeps its posts on this instance (the server your account is on), even if you choose **Public**. In a **Private club**, for example, **Public** still means anyone can read it on the web, even without an account; it just isn't sent to other instances. Choose the group's members to keep a post to them.

> These limits apply to what you post in the group. A public post somewhere else that mentions the group, for example from Mastodon, stays public: the group can't make someone else's post private.

A reply takes the audience of the post you reply to, unless you choose another.

In an **Announcement channel**, only moderators post. Everyone else can read, follow and react.

See [Posting, Sharing, and Interacting](./posting-and-interacting.md) and [Circles & Boundaries](./boundaries.md) for audiences in general.

## Your groups in the sidebar

Groups you pin appear in your sidebar, with their topics underneath. Drag them to reorder. To take a group off your sidebar without leaving it, use **⋯ → Remove from sidebar** on its row.

Your instance's admins can pin groups to everyone's sidebar, in an order they choose. You can't remove those from your sidebar. Some instances also add new users to a welcome group when they sign up: you can leave it like any other group.

## Leaving a group

Open **⋯** on the group's page and choose **Leave group**, then confirm. You stop being a member at once. In a private group, the members-only posts disappear from your view.

Leaving doesn't unfollow the group. Unfollow it separately if you no longer want its posts in your feed.

### When a moderator acts

- **A post taken out of the group** no longer shows in the group, but it isn't deleted from your profile.
- **Removed from the group**: you stop being a member, and can join or ask again under the group's usual rules.
- **Banned**: depending on the ban, the group stops seeing your posts, you can no longer see or take part in the group, or both, until the ban is lifted.

## Groups from other instances

Groups made with the **Open network** or **Announcement channel** setting are part of the fediverse, the network of independent servers that talk to each other. People on Mastodon, Lemmy, NodeBB and other software can follow them, post in them and reply. You can also join groups that live on other instances, such as Lemmy communities, from Bonfire: [search for the group by its address](./remote-interactions.md#interacting-with-remote-users) and join from its page. Note that joining sometimes takes a while to be confirmed by the other instance.

See [Remote Interactions](./remote-interactions.md) for following and joining from another instance.

## FAQ

<!-- AI-drafted 2026-11-03 from the FAQs in website-blog/posts/groups.md (Dec 2025) and website-blog/posts/bonfire-for-communities.md (Jul 2026), updated to what the code does today. Rewrite before publishing. -->

### What's the difference between a group and a topic?

A group is the space: it has members, moderators, rules and its own settings for who can find, join, read and post. Topics live inside a group and keep its conversations apart, so a reading circle and a planning thread don't end up in one stream. A topic follows its group's access rules.

You can follow a whole group or a single topic, so new posts reach your feed without you checking every group page.

### Doesn't the fediverse already have groups?

It has one kind. Lemmy, PieFed and Mbin run Reddit-style communities: public forums around a subject, where strangers gather to discuss it.

Bonfire groups can take that shape, and others too:

- a public forum around a subject
- a private room for a set of people who know each other
- an announcement channel, where a few people post and everyone else follows along
- anything in between

They're closer to the Facebook, Discord or WhatsApp groups many communities want to leave: you know who's in the room, and the group holds its conversations, decisions and events together. The difference is who's in charge: a Bonfire group writes its own rules and picks its own moderators, instead of living under a platform's policies and algorithms.

Bonfire groups aim to work with the threadiverse, not to replace it. You can already join Lemmy communities from Bonfire, and Lemmy users can join Bonfire groups that federate. We have started discussions to interoperate with ATProto groups, in particular with BlackSky's Acorn effort.

### How is this different from a forum?

Forums are good at structured, long-running discussion, and many are run by their own communities. But each forum is its own island: a new account for every one, and when you leave you lose your network and history.

A Bonfire group keeps what forums do well: clear topics, community rules and moderation. And you take part with the identity you already have. Long discussions can branch into nested threads, so a side conversation doesn't derail the main one.

[Discourse](https://www.discourse.org) and [NodeBB](https://nodebb.org) are bringing federation to forums too, and we want to connect with them.

### Do groups federate?

It depends on how the group was set up:

| Preset | Federates |
|---|---|
| **Open network** | Yes: anyone on the fediverse can find, follow, join and post |
| **Announcement channel** | Yes: anyone can follow and interact; only moderators post |
| **Local community** | No: stays on this instance |
| **Private club** | No: stays on this instance |

Private groups don't federate yet. Sharing members-only posts safely between instances needs agreement on how it works, which we're working on with the [W3C groups task force](https://github.com/swicg/groups/issues).

### Can people on Mastodon take part?

Yes, in groups that federate. From Mastodon you can follow a group, mention it to post in it, and reply to its discussions. The group passes posts on to its followers, so they show up in Mastodon timelines like any other post.

Some things look different on Mastodon: a post with a title shows as its title and a link back to the group.

### Can I join a group on another instance?

Yes, with Lemmy communities and groups on other Bonfire instances. See [Groups from other instances](#groups-from-other-instances).

### Are private groups end-to-end encrypted?

No. A private group decides who can read its posts, but the posts are stored on the instance like everything else, and the instance's admins have access to the server. Choose an instance run by people you trust with what you share there or use an app like Signal to share sensitive data.

### Can a group move to another instance?

Not yet. You can move your own account between instances (see [Moving away from your Bonfire instance](./instance-emigration.md)), but a group can't move yet. We want groups to be portable, so a community can change hosts and keep its members and history.

### How does moderation work across instances?

Each group has its own moderators, who can remove posts, lock discussions, and ban people from the group. In a group that federates, their actions reach the other instances too, so moderators elsewhere don't have to repeat the work. Each instance also keeps its own moderation and can block people, groups or whole instances.

To report a post in a group, use **Flag** from the post's menu: it goes to the group's moderators. Flagging a group itself, from its **⋯** menu, goes to your instance's moderators, and if you tick it, to the moderators of the group's home instance too.

### Who runs a group?

Its moderators. Whoever creates a group becomes its first moderator and can make others moderators. Instance admins can also add new users to a group automatically and pin groups to everyone's sidebar. See [Running a Group](./group-moderation.md).

### Can people see which groups I'm in?

In a group anyone can join, yes. In a group you join by request or invitation, only its members. Your profile doesn't list your groups.

### What standards do groups use?

[ActivityPub](https://www.w3.org/TR/activitypub/), like the rest of the fediverse. For group behaviour we follow [FEP-1b12](https://codeberg.org/fediverse/fep/src/branch/main/fep/1b12/fep-1b12.md), the convention Lemmy and others use, and contribute to the [W3C groups task force](https://github.com/swicg/groups) so that groups work the same way across apps.

---

For running a group, see [Running a Group](./group-moderation.md).
