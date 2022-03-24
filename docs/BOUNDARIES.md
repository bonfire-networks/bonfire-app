# Bonfire Boundaries

Boundaries is Bonfire's flexible framework for full
per-user/per-object/per-action access control. It makes it easy to
ensure that users may only see or do what they are supposed to.

## Users and Circles

Ignoring any future bot support, boundaries ultimately apply to users.

Circles are a way of categorising users. Each user has their own set
of circles that they can add to and categorise other users in as they
please.

Circles allow a user to categorise work colleagues differently from
friends. They can choose to allow different interactions from users in
the two circles or limit which content each sees on a per-item basis.

## Verbs

Verbs represent actions that the user could perform, such as reading a
post or replying to a message.

Each verb has a unique ID, like the table IDs from `pointers` which
must be known to the system through configuration.

## Permissions

Permissions can take one of three values:

* `true`
* `false`
* `nil` (or `null` to postgresql).

`true` and `false` are easy enough to understand as yes and no, but what is `nil`?

`nil` represents `no answer`. in isolation, it is the same as `false`.

Because a user could be in more than one circle and each circle may
have a different permission, we need a way of combining permissions to
produce a final result permission. `nil` is treated differently here:

left    | right   | result
:------ | :------ | :-----
`nil`   | `nil`   | `nil`
`nil`   | `true`  | `true`
`nil`   | `false` | `false`
`true`  | `nil`   | `true`
`true`  | `true`  | `true`
`true`  | `false` | `false`
`false` | `nil`   | `false`
`false` | `true`  | `false`
`false` | `false` | `false`

To be considered granted, the result of combining the permissions must
be `true` - `nil` is as good as `false` again here.

`nil` can thus be seen as a sort of `weak false`, being easily
overridden by a true, but also not by itself granting anything.

At first glance, this may seem a little odd, but it gives us a little
additional flexibility which is useful for implementing features such
as blocks (where `false` is really useful!). With a little practice,
it feels quite natural to use.

## ACLs and Grants

An ACL is "just" a collection of Grants.

Grants combine the ID of the ACL they exist in with a verb id, a user
or circle id and a permission, thus providing a decision about whether
a particular action is permitted for a particular user (or all users
in a particular circle).

Conceptually, an ACL contains a grant for every user-or-circle/verb
combination, but most of the permissions are `nil`. We do not record
grants with `nil` permissions in the database, saving substantially
on storage space and compute requirements.

## `Controlled` - Applying boundaries to an object

An object is linked to one or more `ACL`s by the `Controlled`
multimixin, which pairs an object ID with an ACL ID. Because it is a
multimixin, a given object can have multiple ACLs applied. In the case
of overlap, permissions are combined in the manner described earlier.
