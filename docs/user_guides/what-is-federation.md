# What is Federation and the Fediverse?

**Federation** is a way of connecting many independent servers so they can communicate and share content, without relying on a single company or central authority. In Bonfire, this means every community or individual can run their own instance, but still interact with people on other Bonfire instances—or even on other compatible platforms.

## The Fediverse

The **fediverse** ("federated universe") is the network of all platforms that use open standards like ActivityPub to communicate. This includes Bonfire, Mastodon, PeerTube, Pixelfed, and many more. Each platform can have its own features and rules, but users can follow, reply, and interact across the whole network.

## How does it work?

- Each Bonfire instance is its own website, with its own users, rules, and features.
- When you post, your content can be shared with users on your instance or across the fediverse, depending on your privacy settings.
- You can follow and interact with people on other Bonfire instances, or on other ActivityPub-compatible platforms.
- Your username includes your instance's domain, like `@alice@mycommunity.social`.

## Why does this matter?

- **Choice:** You can pick an instance that matches your values, or run your own.
- **Resilience:** No single company controls the network, so it's harder to censor or shut down.
- **Interoperability:** You can interact with people using different software, as long as they speak the same protocol.

Bonfire is designed to make federation easy and flexible, so you can connect with the wider world while keeping control over your own space.

## What is ActivityPub?

**ActivityPub** is an open, standardized protocol for decentralized social networking. It allows different platforms—like Bonfire, Mastodon, PeerTube, and others—to communicate and share content, even if they run different software or are hosted by different people.

### Why does ActivityPub matter?

- **Interoperability:** You can follow, reply to, and interact with people across the entire fediverse, not just on your own instance or platform.
- **Decentralization:** No single company or server controls the network. Anyone can run their own instance and still be part of the wider conversation.
- **Extensibility:** ActivityPub supports many types of activities, from posting and liking to sharing files, events, and more.

### How does Bonfire use ActivityPub?

Bonfire uses ActivityPub to:
- Share posts, comments, and other activities with users on other Bonfire instances and compatible platforms.
- Receive content and interactions from the wider fediverse.
- Enable rich, extensible interactions beyond just microblogging (thanks to Bonfire's modular design).

**In short:** ActivityPub is the language that lets Bonfire talk to the rest of the fediverse.

Learn more: [ActivityPub specification](https://www.w3.org/TR/activitypub/)
