# Running a Group

This guide is for people who create or moderate a group. For taking part in one, see [Groups](./groups.md).

## Creating a group

Open **Groups** and press **Create group**. Give it a name and a description, then pick a starting point:

| Preset | Who finds it | Who joins | Who posts | Reaches other instances |
|---|---|---|---|---|
| **Open network** | Anyone, anywhere | Anyone | Anyone | Yes |
| **Local community** | Anyone | Users of this instance | Users of this instance | No |
| **Announcement channel** | Anyone, anywhere | Invite only | Moderators | Yes |
| **Private club** | Users of this instance | On request | Members | No |

A preset is a starting point. Change any toggle and the group becomes **Custom**. You can change these later in the group's settings.

An instance is the server your community's accounts are on. "Users of this instance" means people with an account there.

Who can find a group and who can read its posts are separate settings. In a Private club, people can see that the group exists and ask to join, but only members read its posts.

If joining needs a request or an invitation, only members see who else is in the group; others see a count.

You become the group's first moderator.

## Group settings

Moderators see a **Manage** button and a **Moderator** label in the group's header. **Manage** opens **Group settings**:

- **Members**: everyone in the group, with actions for each person. **Add member** adds someone on this instance directly, which is how people get into an invite-only group. People on other instances can't currently be added, so they can't join an invite-only group yet.
- **Access & participation**: who finds, joins, posts in and reads the group.
- **Manage moderators**: add or remove moderators.
- **Community rules**: guidelines for members.
- **Moderation**: reports and join requests for the group.
- **Instance settings**: for instance admins only, see [below](#for-instance-admins).
- **Archive group**: close it. You can restore it later.

Changing who can join or post applies from then on.

## Join requests

When someone asks to join, the request appears in your notifications and in **Moderation**.

- **Approve**: they become a member and see the group. They aren't sent a notification about it.
- **Decline**: . Moderators see the request as declined, with **Approve instead** in case you change your mind. The person is not notified. On this instance, their button goes back to **Request to join**; someone on another instance is sent nothing, so their instance may keep showing the request as pending. They can ask again later, and a new request replaces the old one. Each new request notifies you again.

## Members

Open **Members**, find the person and press the shield (**Moderate** and their name) next to them.

- **Remove from the group**: their membership ends. They can join or ask again under the group's normal rules.
- **Ban**, in the group only:
  - **Silence**: the group stops seeing what they post.
  - **Ghost**: they can no longer see or interact with the group.
  - **Block**: both.

  A ban doesn't remove someone from the group: use **Remove from the group** as well if you want them gone. If you removed them, lifting the ban lets them join or ask again.

See [Blocking & Moderation Tools](./moderation.md) for what each kind of block does.

## Moderators

In **Manage moderators**, search for a member and add them. Someone from another instance must already be a member before you can make them a moderator.

Every moderator can do everything on this page, including add and remove other moderators. A group always keeps at least one moderator: the last one can't be removed.

## Posts

Open a post's menu:

- **Remove from group**: takes the post out of the group. The author's original stays. Use this when a post is in the wrong place or breaks the rules. There is no way to put a removed post back yet.
- **Delete**: deletes the post for everyone. For a post from another instance, it deletes the copy on yours.
- **Lock**: stops new replies. **Unlock this discussion**, on the post's own page, opens it again. The author can't reopen a discussion a moderator locked.
- **Hide** a post: it stays in the group but out of view (on your instance only), and **Unhide** brings it back.

### Pinning posts

Pin the posts people shouldn't miss: a welcome post, the rules, a meeting date, an announcement.

Open the post and choose **Pin this activity** from its menu. You get one option for each place the post can be pinned:

- **Pin to top of group**: it shows at the top of the group, for everyone who can read it.
- **Pin to top of topic**: it shows at the top of that topic only. A post in a topic can be pinned to the topic, to the group, or both.

Pinned posts show in a carousel above the feed, and they stay in the feed too. Each page shows only its own pins: the group's pins on the group page, a topic's pins on that topic.

To unpin, choose **Unpin from top of group** (or topic) from the same menu, or use the pin icon on the pinned card.

Only moderators can pin in a group, and that holds for people on other instances too. In a group that reaches other instances, pins reach them as well: other apps, such as Lemmy, show them at the top too.

## Flags

When someone flags a post in the group, the report goes to the group's moderators and arrives in **Moderation**. Your instance's moderators can see it too, in their own list of reports. Reports from people on other instances reach you as well, and when the group is on another instance, whoever reports can choose to send it there too. Review the post and the reason, then take action from the post's menu, or dismiss the report. Dismissing it applies on your instance only. A report on the group itself goes to your instance's moderators, not to you.

For instance-wide moderation, see [Moderator Tools](./moderator-tools.md).

## Topics

Moderators create topics with **New topic** at the end of the topic chips, and can rename, archive or delete a topic from its settings. A topic follows its group's access rules: a topic in a private group is private too.

## Archiving

**Archive group** closes the group. People can still read it, but nobody can post. Archived groups show under **Archived** on the groups page. Open the group and press restore to bring it back.

Archiving is how to close a group: its conversations stay readable, and you can bring it back. A group can't be handed over or moved to another instance just yet.

## Groups on other instances

With **Open network** or **Announcement channel**, your group is part of the fediverse, the network of independent servers that talk to each other: people on other instances can follow, join, post and reply, and your moderation reaches them too.

If you moderate a group that lives on another instance, your actions take effect here once that instance confirms them. If you enable the **Apply it here now** option, it will take effect here straight away instead. If the group's instance refuses, the action is undone. From here you can't yet lift a ban, reopen a thread, or change that group's moderators or name: do those on the group's own instance. Who moderates it is up to that instance, which can add or remove you.

## For instance admins

Instance admins can bring groups to everyone on the instance. You don't need to moderate a group to do this.

### Add new users to a group automatically

Open the group's **Group settings → Instance settings** and turn on **Auto-join new users**. Everyone who signs up from then on becomes a member of the group and follows it. People who already have an account are not added.

Use it for a welcome group, or the space where your community talks about the instance itself. You can turn it on for several groups.

### Pin a group to everyone's sidebar

On the group's page, open **⋯** and choose **Pin to everyone's sidebar**. The group then shows in every user's sidebar, and they can't remove it. To undo, choose **Unpin from everyone's sidebar** from the same menu.


### Order the pinned groups

Go to the instance settings, under groups, and open **Sidebar order**. Drag the groups into the order you want everyone to see. The pin icon next to a group unpins it from everyone's sidebar.

---

See also: [Circles & Boundaries](./boundaries.md), [Moderator Tools](./moderator-tools.md), [Admin Tools](./admin-tools.md).
