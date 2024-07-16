# What is Bonfire?

Bonfire is an open-source framework for building federated digital spaces where people can gather, interact, and form communities online.

![Bonfire wallpaper](https://i.imgur.com/dbRT0Z1.png)

## Main features

1. **Modular architecture**: Bonfire consists of extensions that shape the functionality and user experience of each digital space. Communities can enable or disable these extensions to customize their space according to their needs and vision.
2. **Extensibility**: Developers can create new extensions to expand the capabilities of digital spaces, such as adding new activities or introducing innovative user experiences for existing functions.
3. **Federation**: Bonfire allows digital spaces to connect and communicate with each other, enabling users to interact across different communities while maintaining their unique identities and preferences.
4. **Flexibility**: Whether you're an individual developer or part of a larger team, Bonfire provides a flexible framework for building and customizing digital spaces that cater to a wide range of communities and purposes.

Bonfire empowers developers and communities to create engaging, customizable, and interconnected digital spaces that foster collaboration, creativity, and social interaction online.

## How to use these docs

There are different types of persona who can be interested in reading these docs:

- **Developers**: You'll probably be interested in understanding how to build on Bonfire. The [Installation](/docs/DEPLOY.md) will guide you through the installation of bonfire on your local machine. In the [Just commands](/docs/just-commands.md) page you will gain familiarities with the basic Bonfire Cli commands and the project structure. From there you may want to continue [developing a new extension](/docs/building/create-a-new-extension.md), or learning more about the internalities and the [bonfire architecture](/docs/topics/ARCHITECTURE.md).
- **Users**: Wheter you are a user who is looking for an existing digital place to join, or want to understand more about how Bonfire works and how to get the most out of it, the [Community Manual](https://bonfirenetworks.org) is a good place to start. There you will learn about how to customize your experience, what boundaries are and how to experience a new and safer way to interact with federated social networks.
- **Sysadmin & Community moderator**: Ready to launch your digital space? We got you covered on our [Hosting guide](/docs/DEPLOY.md). If you want to dig deeper into how bonfire roles and boundaries work you can read [Bonfire Boundaries](/docs/topics/ARCHITECTURE.md).

## Prerequisite knowledge

Bonfire aims to be beginner-friendly, but to keep the documentation focused on the framework's functionalities, we assume a basic understanding of the following technologies:

- **Elixir**: If you're new to Elixir or need a refresher, start with the [Elixir Getting Started guide](https://elixir-lang.org/getting-started.html).
- **Phoenix/LiveView**: Bonfire's official client is built with Phoenix LiveView. If you're unfamiliar with LiveView, check out the [Phoenix LiveView Getting Started guide](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.AsyncResult.html) or the [Phoenix LiveView - Getting Started video course](https://pragmaticstudio.com/phoenix-liveview) by Pragmatic Studio.
- **PostgreSQL**: Bonfire uses PostgreSQL as its primary database. Basic knowledge of SQL and PostgreSQL is helpful.

Bonfire also provides a [GraphQL API](/docs/topics/GRAPHQL.md) for developers who want to build custom frontends.

Throughout the documentation, we'll make sure to provide links to relevant resources when introducing new concepts to help you along the way. We have a strong affinity for Elixir and believe it's a powerful language for building scalable and maintainable social networks.

## Join our community

If you have questions about anything related to Bonfire, you're always welcome to ask our community on [Matrix](https://matrix.to/#/#bonfire-networks:matrix.org), [Slack](https://join.slack.com/t/elixir-lang/shared_invite/zt-2ko4792lz-28XosraCTaYZKOyuZ80hrg), [Elixir Forum](https://elixirforum.com) and the [Fediverse](https://indieweb.social/@bonfire) or send us an email at team@bonfire.cafe.