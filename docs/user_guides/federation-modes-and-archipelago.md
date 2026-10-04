# Federation modes and Archipelago

Bonfire lets each community choose how its instance connects to other communities. You can participate in open federation, limit federation to selected instances or people, use on-demand federation, or disable federation.

This guide is for instance administrators and people coordinating federation between communities.

## Choose a federation mode

Administrators can choose the instance's mode in **Instance settings → Configuration → Federation**, at `/settings/instance/configuration` on their own instance.

| Mode | Behaviour |
| --- | --- |
| **Open** | Automatically delivers activities to their remote recipients and accepts incoming activities, subject to blocks and content permissions. |
| **Archipelago** | Allows federation with explicitly allowlisted instances or individual actors. Incoming activities and outgoing delivery are filtered by the allowlist, and blocks still apply. |
| **Manual** | Does not push activities automatically. Individual profiles and posts can still be fetched on demand, subject to permissions. |
| **Disabled** | Turns off ActivityPub federation, including remote fetching. Local use can continue. |

Open federation does not mean every post is sent to every server. Delivery still depends on recipients, follows, and the post's boundary. Manual mode is not a queue where administrators approve each outgoing activity.

## What is an Archipelago?

Archipelago is Bonfire's allowlist-only federation mode. A community chooses which other instances or individual actors it permits federation with. An actor is a federated identity, such as a person's account.

Each instance maintains its own allowlist. Adding a partner to your list does not update their list or the lists of other communities. There is no automatic shared membership: if community A allows B, and B allows C, A does not automatically allow C.

Communities can run on separate hardware and use different hosting providers. What matters for this configuration is the federated instance domain or actor identity, together with compatible ActivityPub support and the policies at both ends.

## Add a community or person

You need an account with permission to configure the instance. Other signed-in users may be able to view the instance list without being able to edit it.

1. Open **Instance settings → Configuration → Federation** and select **Archipelago**. This reveals the **Manage archipelago federation allow-list** button.
2. Select **Manage archipelago federation allow-list** to open the **Instance Federation Archipelago** page.
3. Agree with the other community which instance domain or individual actor should be allowed.
4. In **Actor URL, domain, or @handle@domain**, enter one of the following:
   - A bare domain, such as `community.example.org`, to allow all actors on that instance.
   - An actor's URL, such as `https://community.example.org/users/alice`, to allow that actor. Copy the actual URL from the remote service; URL formats vary.
   - A handle, such as `@alice@community.example.org`, to resolve and allow that actor.
5. Select **Add** and confirm that the intended entry appears. A bare domain is the clearest way to request an instance-wide entry.
6. Ask the other administrator to check their own policy. If their instance also uses Archipelago, they need to add your instance or the relevant actors to their allowlist for two-way federation.

An Open partner does not need to switch to Archipelago to communicate with you. Your allowlist must permit them, and their own federation policy must permit communication with you.

To remove an entry, use **Remove** beside it. Removing an individual actor does not exclude them if their whole instance remains allowlisted. Use the appropriate moderation block when you need to restrict an actor on an otherwise allowed instance.

## Allowlists, blocks, and content boundaries

An allowlist permits federation; it does not automatically follow everyone on an instance, subscribe to all their posts, or grant access to restricted content. People still follow accounts and choose audiences for their posts.

Applicable instance-wide and personal blocks take priority over allowlisting. A domain can be allowed while a particular actor on it is blocked. Incoming and outgoing restrictions depend on the type of block.

Archipelago is not a substitute for a post's privacy boundary. Restricting federation does not by itself make a publicly accessible web page private. Choose an appropriate content boundary for material intended for a limited audience.

## Check the connection

After both communities have configured their policies:

1. Use a test account on each instance and look up the other account by its full handle or actor URL.
2. Follow the remote account and accept the request if approval is required.
3. Publish a new post with a boundary that permits federation to the test follower. Check that it arrives on the other instance.
4. Repeat in the opposite direction, then try a reply or mention.

A successful profile lookup alone does not establish that activity delivery works. Test with new activity after configuring the lists rather than relying on older posts appearing.

If an interaction does not arrive, check:

- The effective federation mode of both instances and both accounts. A personal Manual or Disabled setting can prevent outgoing delivery even when the instance permits it.
- The actual remote domain or actor in each applicable allowlist.
- Instance-wide and personal blocks, follow approval, and the post's boundary.
- Remote reachability and federation delivery errors in the server logs.

## Current limitations

Personal allowlists and group-specific Archipelago are on the roadmap but are not currently implemented. For now, use the instance-wide allowlist to manage Archipelago federation.
