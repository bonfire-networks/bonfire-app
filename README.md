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

- **Developers**: You'll probably be interested in understanding how to build on Bonfire. The [dev setup](/docs/DEPLOY.md) will guide you through the installation of bonfire on your local machine. In the [Just commands](/docs/topics/JUST.md) page you will gain familiarities with the basic Bonfire CLI commands. From there you may want to continue [developing a new extension](/docs/building/create-a-new-extension.md), or learning more about the internals and the [Bonfire architecture](/docs/topics/ARCHITECTURE.md).

- **Users**: Whether you are a user who is looking for an existing digital place to join, or want to understand more about how Bonfire works and how to get the most out of it, the [Community Manual](https://bonfirenetworks.org/#TODO) is a good place to start. There you can learn about how to customize your experience, what boundaries are and how to experience a new and safer way to interact with federated social networks.

- **Community organisers & sysadmins**: Ready to launch your digital space? We got you covered on our [hosting guide](/docs/DEPLOY.md). 

## Prerequisite knowledge

Bonfire aims to be beginner-friendly, but to keep the documentation focused on the framework's functionalities, we assume a basic understanding of the following technologies:

- **Elixir**: If you're new to Elixir or need a refresher, start with the [Elixir guide](https://hexdocs.pm/elixir/introduction.html).
- **Phoenix/LiveView** and **Surface**: Bonfire's official web UI is built with the Surface framework, which itself is based on Phoenix LiveView. If you're unfamiliar with them, check out the [Phoenix overview](https://hexdocs.pm/phoenix/overview.html), [Phoenix LiveView guide](https://hexdocs.pm/phoenix_live_view/welcome.html), and [Surface docs](https://surface-ui.org). You may also be interested in the [Phoenix LiveView video course by Pragmatic Studio](https://pragmaticstudio.com/phoenix-liveview).
- **PostgreSQL**: Bonfire uses PostgreSQL as its primary database. Basic knowledge of SQL and PostgreSQL is helpful.

Bonfire also provides a [GraphQL API](/docs/topics/GRAPHQL.md) for developers who want to build custom frontends.

Throughout the documentation, we'll make sure to provide links to relevant resources when introducing new concepts to help you along the way. We have a strong affinity for Elixir and believe it's a powerful language for building scalable and maintainable social networks.

## Join our community

If you have questions about anything related to Bonfire, you're always welcome to ask our community on [Matrix](https://matrix.to/#/#bonfire-networks:matrix.org), [Slack](https://join.slack.com/t/elixir-lang/shared_invite/zt-2ko4792lz-28XosraCTaYZKOyuZ80hrg), [Elixir Forum](https://elixirforum.com) and the [Fediverse](https://indieweb.social/@bonfire) or send us an email at team@bonfire.cafe.

## Funding

This project has received funded through [NGI0 Discovery](https://nlnet.nl/discovery) and [NGI0 Entrust](https://nlnet.nl/entrust), funds established by [NLnet](https://nlnet.nl) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu) program. Learn more at the [NLnet project page](https://nlnet.nl/project/Bonfire-Framework) (also for [previous](https://nlnet.nl/project/Bonfire-FederatedGroups) [projects](https://nlnet.nl/project/Bonfire) )

[<img src="https://nlnet.nl/logo/banner.png" alt="NLnet foundation logo" width="20%" />](https://nlnet.nl)
[<img src="https://nlnet.nl/image/logos/NGI0Entrust_tag.svg" alt="NGI Zero Logo" width="20%" />](https://nlnet.nl/entrust)
[<img src="https://nlnet.nl/image/logos/NGI0Discovery_tag.svg" alt="NGI Zero Logo" width="20%" />](https://nlnet.nl/discovery)

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
