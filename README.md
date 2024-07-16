<!-- <p align="center"> <img src="https://user-images.githubusercontent.com/1852065/220077189-33cd03af-2775-4298-9dcb-83a9932541e9.png" width="200" height="250" alt="bonfire logo" /></p> -->


# Bonfire Networks 

[Bonfire](https://bonfirenetworks.org/) is an open-source framework for building federated digital spaces where people can gather, interact, and form communities online.

![Bonfire wallpaper](https://i.imgur.com/dbRT0Z1.png)

> #### Info {: .info}
>
> This project is in the beta stage - you're welcome to try out it out (specifically the social features in the classic flavour), but APIs may still change and no guarantees are given about stability. You can keep track of progress [in our milestones](https://github.com/bonfire-networks/bonfire-app/milestones?direction=asc&sort=due_date&state=open)

## Main features

1. **Modular architecture**: Bonfire consists of extensions that shape the functionality and user experience of each digital space. Communities can enable or disable these extensions to customize their space according to their needs and vision.
2. **Extensibility**: Developers can create new extensions to expand the capabilities of digital spaces, such as adding new activities or introducing innovative user experiences for existing functions.
3. **Federation**: Bonfire allows digital spaces to connect and communicate with each other, enabling users to interact across different communities while maintaining their unique identities and preferences.
4. **Flexibility**: Whether you're an individual developer or part of a larger team, Bonfire provides a flexible framework for building and customizing digital spaces that cater to a wide range of communities and purposes.

Bonfire empowers developers and communities to create engaging, customizable, and interconnected digital spaces that foster collaboration, creativity, and social interaction online.


### 🔥 Flavours

This repo includes configurations to run a few main [flavours of Bonfire](https://bonfirenetworks.org/apps/) you can choose from:
* [Classic](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/classic) for basic social networking (beta)
* [Community](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/community) with groups and topics functionality (alpha)
* [Open Science](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/open-science) building the next generation of open science platforms (pre-alpha)
* [Coordination](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/coordination) for organising work and collaborating around projects and tasks (pre-alpha)
* [Cooperation](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/cooperation) for cooperative production, distribution, and exchange of economic resources (pre-alpha)

<!-- As well as app flavours being built by others, including: 
* [Haha Academy](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/haha) by haha.academy 
* [Upcycle](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/upcycle) by MSOE 
* [Reflow](https://github.com/bonfire-networks/bonfire-app/tree/main/flavours/reflow) by reflowproject.eu and dyne.org -->

## How to get the most out of the documentation

There are different types of persona who can be interested in reading these docs:

- **Developers**: You'll probably be interested in understanding how to build on Bonfire. The [Installation](/docs/DEPLOY.md) will guide you through the installation of bonfire on your local machine. In the [Just commands](/docs/just-commands.md) page you will gain familiarities with the basic Bonfire Cli commands and the project structure. From there you may want to continue [developing a new extension](/docs/building/create-a-new-extension.md), or learning more about the internalities and the [bonfire architecture](/docs/topics/ARCHITECTURE.md).
- **Users**: Wheter you are a user who is looking for an existing digital place to join, or want to understand more about how Bonfire works and how to get the most out of it, the [Community Manual](https://bonfirenetworks.org) is a good place to start. There you will learn about how to customize your experience, what boundaries are and how to experience a new and safer way to interact with federated social networks.
- **Sysadmin & Community moderator**: Ready to launch your digital space? We got you covered on our [Hosting guide](/docs/DEPLOY.md). If you want to dig deeper into how bonfire roles and boundaries work you can read [Bonfire Boundaries](/docs/topics/ARCHITECTURE.md).

## Prerequisite knowledge

Bonfire aims to be beginner-friendly, but to keep the documentation focused on the framework's functionalities, we assume a basic understanding of the following technologies:

- **Elixir**: If you're new to Elixir or need a refresher, start with the [Elixir Getting Started guide](https://elixir-lang.org/).
- **Phoenix/LiveView**: Bonfire's official client is built with Phoenix LiveView. If you're unfamiliar with LiveView, check out the [Phoenix LiveView Getting Started guide](https://hexdocs.pm/phoenix_live_view/Phoenix) or the [Phoenix LiveView - Getting Started video course](https://pragmaticstudio.com/phoenix-liveview) by Pragmatic Studio.
- **PostgreSQL**: Bonfire uses PostgreSQL as its primary database. Basic knowledge of SQL and PostgreSQL is helpful.

Bonfire also provides a [GraphQL API](/docs/topics/GRAPHQL.md) for developers who want to build custom frontends.

Throughout the documentation, we'll make sure to provide links to relevant resources when introducing new concepts to help you along the way. We have a strong affinity for Elixir and believe it's a powerful language for building scalable and maintainable social networks.

## Join our community

If you have questions about anything related to Bonfire, you're always welcome to ask our community on [Matrix](https://matrix.to/#/#bonfire-networks:matrix.org), [Slack](https://join.slack.com/t/elixir-lang/shared_invite/zt-2ko4792lz-28XosraCTaYZKOyuZ80hrg), [Elixir Forum](https://elixirforum.com) and the [Fediverse](https://indieweb.social/@bonfire) or send us an email at team@bonfire.cafe.


## Copyright and License

Copyright (c) 2020-2024 Bonfire Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with this program.  If not, see <https://www.gnu.org/licenses/>.
