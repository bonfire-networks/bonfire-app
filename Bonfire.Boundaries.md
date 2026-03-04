# Boundaries for Access Control

Bonfire's boundaries framework provides a flexible way to control user access to specific actions and data. It ensures that users can only see and do what they're authorized to.

You can create custom groups of contacts (circles) and grant them specific permissions to interact with you and your content. They can help you take control of your online presence and ensure that your data is shared only with the people you want.

> Boundaries are limits that you set for yourself or others to define what you're comfortable with.
> These limits can be physical, like curtains or doors; digital, like sharing settings on social media; in writing, like codes of conduct; emotional, like feeling comfortable to take time for self-care; or mental, like choosing what you pay attention to. In Bonfire, boundaries can help limit the type of interactions that others may have with you or things you post.
> Boundaries are important because they help you protect yourself, maintain your autonomy, and communicate your needs and expectations clearly.

## Glossary

| Term                                                  | Definition                                                                                           |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Subject** or **User**                               | An individual who interacts with the system.                                                         |
| **[Circle](Bonfire.Boundaries.Circles.html)**         | A categorization method for users, allowing users to group other users (e.g., colleagues, friends).  |
| **[Verb](Bonfire.Boundaries.Verbs.html)**             | An action that a user can perform (e.g., read, reply).                                               |
| **Permission**                                        | A value indicating whether an action is allowed (`true`), denied (`false`), or `nil`.                |
| **[Grant](Bonfire.Boundaries.Grants.html)**           | Links a user or circle with a verb and permission.                                                   |
| **[ACL](Bonfire.Boundaries.Acls.html)**               | Access Control List, a collection of grants. Also called "boundary" or "boundary preset" in the app. |
| **[Controlled](Bonfire.Boundaries.Controlleds.html)** | Links an object to one or more ACLs, to determine access based on the grants.                        |
| **[Role](Bonfire.Boundaries.Roles.html)**             | A group of verbs linked to a permission.                                                             |

## Users and Circles

Circles are a way of categorizing users. Each user can have their own set of circles to categorize other users. Circles allow a user to group work colleagues differently from friends for example, and to allow different interactions for users in each circle or limit content visibility on a per-item basis.

## Verbs

Verbs represent actions users can perform, such as reading a post or replying to a message. Each verb has a unique ID and are defined in configuration.

## Permissions

A permission is a decision about whether the action may be performed or not. There are 3 possible values:

- `true`: yes, the action is allowed
- `false`: no, the action is explicitly denied (i.e. never permit)
- `null`/`nil`: unknown, the action isn't explicitly allowed (defaults to not allowed)

### Grants

A `Grant` links a `subject` (user or circle) with a `Verb` and a permission. It defines the access rights for a specific user or circle in relation to a particular action.

## ACLs

An `Acl` is a list of `Grant`s used to define access permissions for objects.

Because a user could be in more than one circle and each circle may have a different permission, when a user attempts an action on an object, the system combines all relevant grants to determine the final permission. This combination prioritizes permissions as follows: `false > true > nil`, resulting in:

| input   | input   | result  |
| :------ | :------ | :------ |
| `nil`   | `nil`   | `nil`   |
| `nil`   | `true`  | `true`  |
| `nil`   | `false` | `false` |
| `true`  | `nil`   | `true`  |
| `true`  | `true`  | `true`  |
| `true`  | `false` | `false` |
| `false` | `nil`   | `false` |
| `false` | `true`  | `false` |
| `false` | `false` | `false` |

In simpler terms, a final permission is granted only if the combined result is `true`. Think of it as requiring an explicit "yes" for permission, while "no" always takes precedence. Notably, `nil` acts as a sort of "weak no," it can be overridden by a `true` but not granting access on its own. This approach provides flexibility for implementing features like user blocking (`false` is crucial here).

For efficiency, `nil` is the assumed default and not stored in the database.

## Controlled - Applying boundaries to an object

The `Controlled` multimixin link an object to one or more ACLs. This allows for applying multiple boundaries to the same object. In case of overlapping permissions, the system combines them following the logic described above.

### Roles

Roles are groups of verbs associated with permissions. While not stored in the database, they are defined at the configuration level to enhance readability and user experience.

## Practical example: Surprise birthday party

Let's illustrate how boundaries work with a real-world example: planning a surprise party without the birthday girl finding out.

### 1. Setting up users

```elixir
iex> import Bonfire.Me.Fake
iex> organizer = fake_user!()
iex> birthday_girl = fake_user!()
iex> friends = [fake_user!(), fake_user!()]
iex> family = [fake_user!(), fake_user!()]
```

### 2. Define your Circles

Organize users into relevant circles (friends and family).

```elixir
iex> alias Bonfire.Boundaries.Circles
iex> {:ok, friends_circle} = Circles.create(organizer, %{named: %{name: "friends"}})
iex> Circles.add_to_circles(friends, friends_circle)
iex> Circles.is_encircled_by?(List.first(friends), friends_circle)
true
iex> {:ok, family_circle} = Circles.create(organizer, %{named: %{name: "family"}})
iex> Circles.add_to_circles(family, family_circle)
```

### 3. Create the ACL (boundary preset)

This boundary will control access to the surprise party plans.

```elixir
iex> alias Bonfire.Boundaries.Acls
iex> {:ok, boundary} = Acls.simple_create(organizer, "Surprise party")
```

### 4. Grant permissions

Allow friends to discover, read, and respond to party plans, while family members can also edit details and send invitations.

```elixir
iex> alias Bonfire.Boundaries.Grants
iex> Grants.grant(friends_circle.id, boundary.id, [:see, :read, :reply], true, current_user: organizer)
iex> Grants.grant(family_circle.id, boundary.id, [:see, :read, :reply, :edit, :invite], true, current_user: organizer)
```

Prevent the birthday person from accessing any party information.

```elixir
iex> Grants.grant(birthday_girl.id, boundary.id, [:see, :read], false, current_user: organizer)
```

### 5. Post about the party

```elixir
iex> alias Bonfire.Posts
iex> {:ok, party_plan} = Posts.publish(
        current_user: organizer,
        boundary: boundary.id,
        post_attrs: %{post_content: %{name: "Surprise party!"}})
```

### 6. Double-check applied boundaries

```elixir
iex> Boundaries.can?(List.first(friends).id, :read, party_plan.id)
true
iex> Boundaries.can?(List.first(family).id, :invite, party_plan.id)
true
iex> Boundaries.can?(birthday_girl.id, :see, party_plan.id)
false
iex> Boundaries.load_pointer(party_plan.id, current_user: birthday_girl)
nil
```

By following these steps, the organizer can effectively manage access to ensure the birthday girl cannot see the party plans, while friends and family can.

## Copyright and License

Copyright (c) 2020 Bonfire Contributors

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
