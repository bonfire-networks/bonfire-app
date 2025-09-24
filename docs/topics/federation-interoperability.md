# Bonfire Federation Interoperability Guide

## 1. Introduction

Bonfire is a modular, extensible, privacy-focused federated platform built on top of [ActivityPub](#activitypub) and [ActivityStreams](#activitystreams). It aims to provide a flexible foundation for building social, collaborative, and community-oriented applications that can interoperate with the wider Fediverse.

Unlike monolithic platforms, Bonfire is designed built as a framework that powers multiple apps (flavours) with features provided by optional extensions, allowing instances to enable only the features they need. This modularity also makes it easier to experiment with new protocols, object types, and interaction patterns.

Bonfire strives for maximum interoperability with other ActivityPub-based software such as [Mastodon][3], Pixelfed, Mobilizon, GoToSocial [8], Peertube, and others, while also supporting advanced privacy controls, custom boundaries, and experimental [FEPs](#fep).

This guide documents how Bonfire federates, how it handles ActivityPub objects and activities, and what to expect when integrating with or building on top of Bonfire.

- **Protocols:** [ActivityPub](#activitypub), [WebFinger](#webfinger)
- **Syntax:** [ActivityStreams Core][11]
- **Vocabulary:** [ActivityStreams Vocabulary][12], ValueFlows[13]
- **Extensions:** ActivityPub [FEPs](#fep), Bonfire extensions

> See the [Glossary](#glossary) for definitions of key terms.

## 2. Protocol Support & Endpoints

Bonfire supports the core [ActivityPub](#activitypub) server-to-server (S2S) protocol for federation, as well as [WebFinger](#webfinger) for user and resource discovery. This enables Bonfire instances to interoperate with a wide range of other Fediverse software, including [Mastodon][3], Akkoma, Pixelfed, Mobilizon, Wordpress, GoToSocial [8], and many more.

### ActivityPub Endpoints

Bonfire exposes the standard ActivityPub endpoints for each actor:

- **Inbox**: Receives incoming activities from remote servers.  
  Example: `https://your.bonfire.instance/pub/actors/{username}/inbox`
- **Outbox**: Lists activities published by the actor.  
  Example: `https://your.bonfire.instance/pub/actors/{username}/outbox`
- **Followers / Following**: Collections of followers and followed actors.
- **Shared Inbox**: (Optional) For batching deliveries to multiple actors on the same instance.

HTTP requests should use the correct `Accept` header (`application/activity+json` or `application/ld+json; profile="https://www.w3.org/ns/activitystreams"`).

See [ActivityPub Spec][1] and [ActivityStreams Core][11] for details on endpoint structure and payloads.

### WebFinger Endpoint

Bonfire implements the [WebFinger][2] protocol for resource discovery:

- Endpoint: `https://your.bonfire.instance/.well-known/webfinger`
- Query parameter: `resource=acct:username@domain`

WebFinger responses include links to the actor's ActivityPub profile and HTML profile page. See [WebFinger RFC][2] for details.

### Supported Verbs and Objects

Bonfire supports all major ActivityPub activity types (verbs), including:

- `Create`, `Update`, `Delete`, `Follow`, `Accept`, `Reject`, `Undo`, `Like`, `Announce`, `Flag`, `Block`, `Move`, and more.

Supported object types include `Note`, `Article`, and others as defined in [ActivityStreams Vocabulary][12]. Any object types not specifically implemented (in a Bonfire extension) are still stored as JSON objects, with a fallback preview UI component attempting to display them in feeds (tip: use the `preview` property to attach another object such as a `Note` to be used as a preview for unimplemented objects). 

### Compatibility

Bonfire aims for broad compatibility with major ActivityPub implementations. It supports and regularly tests against:

Mastodon [3], Akomma, GoToSocial [8]
Misskey and derivatives
Pixelfed
Peertube
Mobilizon
WriteFreely, Wordpress, Ghost
Lemmy, kbin, and PieFed
Castopod, Funkwhale
BookWyrm
- [And more](https://github.com/bonfire-networks/bonfire-app/wiki/Manual-federation-testing)

### FEPs and Extensions

Bonfire implements and/or experiments with several [Fediverse Enhancement Proposals (FEPs)][4], including:

- [FEP-1b12][5] (Interaction Policy)
- [FEP-400e][6] (Private Mentions)
- [FEP-044f][7] (Quote Posts)

Support for additional FEPs and experimental features not listed here may be implemented and enabled by extensions.

> For more on Bonfire's federation rules and extension points, see [Bonfire ActivityPub Implementation Docs][9].

## 3. Actor & Object Model

Bonfire uses the [ActivityStreams](#activitystreams) data model for representing actors and objects, along with the [ActivityPub](#activitypub) specification and [ActivityStreams Vocabulary][12]. This section describes how Bonfire maps its internal data to ActivityPub actors and objects, and how it interprets incoming data from remote instances.

### Actor Types

Bonfire supports the following ActivityStreams actor types:

- **Person**: Represents a user account or individual.
- **Group**: Represents a group, category, or collective identity.
- **Service**: Used for bots or automated accounts.
- (Other types may be supported by extensions.)

Bonfire maps its internal "character" abstraction (users, groups, categories, etc.) to the appropriate ActivityStreams actor type. See [Canonical URI](#canonical-uri) for how actor IDs are constructed.

### Object Types

Bonfire supports a wide range of ActivityStreams object types, including:

- **Note**: Short-form post or status update.
- **Article**: Long-form post or article.
- **Question**: Poll or question (if enabled by extension).
- **Image**, **Video**, **Audio**, **Event**, etc. (as defined in [ActivityStreams Vocabulary][12] and supported by extensions).

Objects not explicitly supported by Bonfire are still stored and can be previewed in the UI, with a fallback display.

### Addressing and Audience

Bonfire uses the standard ActivityPub addressing fields to determine the audience for activities and objects:

- `to`: Primary recipients (can include actors, collections, or the [Public URI](#public-uri)).
- `cc`: Secondary recipients (e.g., followers).
- `bto`, `bcc`: Blind recipients (not visible to all, used for addressing activities with custom circles or boundaries).
- `audience`: Additional audience specification (rarely used).

Bonfire enforces audience boundaries and privacy settings based on these fields and local boundaries. See [Boundary](#boundary) and [Access Control](#9-access-control).

### Canonical URIs and ID Formats

All Bonfire actors and objects have globally unique, canonical URIs (typically HTTPS URLs) that serve as their ActivityPub `id`. These URIs are stable and dereferenceable, allowing remote instances to fetch the ActivityStreams representation of the resource.

- Example actor URI: `https://a.bonfire.instance/pub/actors/alice`
- Example object URI: `https://a.bonfire.instance/pub/objects/01H8ZK2YXP9QCT5BE1JWQSAM3B6`

Bonfire uses [ULIDs](https://github.com/ulid/spec) for object IDs, ensuring uniqueness and sortability.

> For more details on actor and object mapping, see [Bonfire ActivityPub Implementation Docs][9] and [ActivityStreams Vocabulary][12].

## 4. Content Types & Extensions

Bonfire supports a broad range of [ActivityStreams](#activitystreams) object types, as defined in the [ActivityStreams Vocabulary][12]. The most common types are:

- **Note**: Short-form post or status update.
- **Article**: Long-form post or article.
- **Image**, **Video**, **Audio**, **Link**: Media attachments.
- **Event**, **Question**, etc: Supported if a relevant Bonfire extension is enabled.
- **Any other types**: Any object (whether defined in ActivityStreams or not) type will be stored and displayed, even if not natively supported by any enabled Bonfire extension. For unknown types, Bonfire attempts to render a preview using the `preview` property if present, otherwise using fallbacks to generate a preview using some common object properties such as `name`, `summary`, or `image`.

### Extensions and Custom Types or Properties

Bonfire supports [AP extensions](#ap-extensions) such as:

- **Hashtag**: For topic tags, using the `Hashtag` object type.
- **Emoji**: For custom emoji, using the `Emoji` object type.
- **PropertyValue**: For profile metadata fields, using the [schema.org PropertyValue][propertyvalue] extension.

As of this writing there is no Bonfire extension currently defining new object types or properties, but extensions can add support for new types or properties. Some extensions are using types and properties defined by specs or FEPs outside of ActivityStreams though, for example enabling the ValueFlows extension adds support for economic objects and activities as defined by the [ValueFlows vocabulary][13]. This should be documented in each extension's docs or right here:

#### FEPs and Experimental Features

Bonfire can enable support for experimental ActivityPub features and [FEPs](#fep) via extensions. Notable examples include:

- [FEP-1b12][5]: Interaction Policy (fine-grained control over who can interact with a post)
- [FEP-400e][6]: Private Mentions
- [FEP-044f][7]: Quote Posts

Support for additional FEPs or custom types may be added by enabling the relevant extension.

> For a full list of supported types and extensions, see [ActivityStreams Vocabulary][12] and [Bonfire ActivityPub Implementation Docs][9].

## 5. Federation Flows

Bonfire federates content and activities using the [ActivityPub](#activitypub) protocol, following the same general flows as other major Fediverse platforms.

### Outgoing Federation

When a user or app extension triggers an action (such as creating, updating, or deleting content), Bonfire:

- Checks boundaries and federation settings to determine if the content should be federated (see [Access Control](#9-access-control)).
- Serializes the object/activity into ActivityStreams JSON, including all required addressing fields (`to`, `bto`, etc. taking circles, follow status, boundaries and blocks into account).
- Queues the activity for delivery to remote recipients' inboxes, batching deliveries to the same instance when possible (sending them to the [shared inbox](#shared-inbox) if one declared is declared in recipients' `Actor` object, in which case the addressing fields should be used by recipient instances to determine who to deliver it to).
- Signs all outgoing requests with HTTP signatures ([HTTP Signature](#http-signature)).

Common outgoing activities include:
- `Create` (new posts, replies, etc.)
- `Update` (edits to posts or profiles)
- `Delete` (removal of posts or profiles)
- `Follow`, `Accept`, `Reject`, `Undo`, `Like`, `Announce`, `Flag`, `Block`, `Move`, and others as supported by extensions.

### Incoming Federation

When Bonfire receives an activity from a remote instance:

- Validates the HTTP signature and checks the sender's domain and actor (see [Access Control](#9-access-control)). If no valid signature is verified, it attempts to re-fetch the canonical object and processes that instead.
- Parses, validates and transforms the activity data against a standardized version of the ActivityStreams vocabulary and any supported extensions, and saves the activity/object JSON in the database.
- Passed the activity to active Bonfire extensions for processing: e.g., creates or updates a local objects, adds to feeds, triggers notifications, applies moderation or boundaries.
- Handles errors gracefully, logging and rejecting invalid or unauthorized activities.

Bonfire supports all standard ActivityPub flows, including:
- Receiving posts, replies, likes, boosts, follows, blocks, reports, and more.
- Handling incoming `Flag` activities as moderation reports.
- Processing `Move` activities for account migration.

### Profile Discovery and Following

To follow a remote user or resource, Bonfire:

- Performs a [WebFinger](#webfinger) lookup to resolve `@username@domain` to an ActivityPub actor URI (see [WebFinger Integration](#webfinger-integrating) section for details).
- Fetches and validates the actor's profile using a signed GET request.
- Sends a `Follow` activity to the remote actor's inbox.
- Handles `Accept` or `Reject` responses to update the local following state.

### Example Flows

- **Status federation:** A user creates a post, which is serialized as a `Create` activity with a `Note` object and delivered to the appropriate remote inboxes.
- **Profile federation:** Profile updates, follows, and blocks are federated as `Update`, `Follow`, `Block`, etc., activities.

> For more details on the federation pipeline and extension points, see [Bonfire ActivityPub Implementation Docs][9].

## 6. WebFinger Integration

Bonfire implements the [WebFinger](#webfinger) protocol for user and resource discovery, enabling remote servers to resolve `@username@domain` identifiers to canonical ActivityPub actor URIs. This is a key part of [profile discovery and following](#profile-discovery-and-following).

- **Endpoint:** `https://your.bonfire.instance/.well-known/webfinger`
- **Query parameter:** `resource=acct:username@domain`

A typical WebFinger response includes:
- The `subject` field set to the queried account (e.g., `acct:alice@your.bonfire.instance`)
- A `self` link pointing to the actor's ActivityPub URI
- Optionally, a link to the user's HTML profile

**Example request:**
```
GET /.well-known/webfinger?resource=acct:alice@your.bonfire.instance
Accept: application/jrd+json
```

**Example response:**
```json
{
  "subject": "acct:alice@your.bonfire.instance",
  "links": [
    {
      "rel": "self",
      "type": "application/activity+json",
      "href": "https://your.bonfire.instance/pub/actors/alice"
    },
    {
      "rel": "http://webfinger.net/rel/profile-page",
      "type": "text/html",
      "href": "https://your.bonfire.instance/@alice"
    }
  ]
}
```

**Interop requirements:**
- The `rel=self` link must point to the canonical ActivityPub actor URI.
- The `subject` must match the queried account.
- The endpoint must respond with the correct content type (`application/jrd+json`).

**Common pitfalls:**
- Incorrect or missing `rel=self` link.
- Mismatched `subject` field.
- Not supporting both `application/jrd+json` and `application/json` Accept headers.

> For more on how Bonfire uses WebFinger for profile discovery and following, see [Federation Flows](#5-federation-flows).

## 7. HTTP Signatures & Secure Fetch

All ActivityPub server-to-server (S2S) requests to Bonfire endpoints should be signed with [HTTP Signatures](#http-signature), including both `GET` and `POST` requests. Bonfire also signs all outgoing federation requests, following the [Cavage HTTP Signatures RFC][10], for compatibility with Mastodon, GoToSocial, Pixelfed, and others.

### Requirements

- **Signature required:** By default, all S2S requests (including fetches of public resources) must include a valid HTTP signature. 
- **Supported algorithms:** Bonfire supports `rsa-sha256` and `ed25519` (and others as per the RFC).
- **Key discovery:** The public key for a Bonfire actor is published in the actor's ActivityPub JSON under the `publicKey` property.
- **Signature headers:** Outgoing requests include the required headers (`(request-target)`, `host`, `date`, and `digest` for `POST`).

### Quirks and Compatibility

- **Query parameters:** Bonfire signs requests including query parameters in the signature string, but will attempt validation both with and without query parameters for compatibility with other implementations.
- **keyId format:** Bonfire uses the fragment format for `keyId` (e.g., `https://your.bonfire.instance/pub/actors/alice#main-key`), matching Mastodon and most other platforms.
- **Public key endpoint:** The `keyId` in the signature header should match the `id` of the `publicKey` object in the actor's JSON.

### Secure Fetch

By default, Bonfire requires signed `GET` requests for fetching actor and object JSON at ActivityPub endpoints (e.g., `/pub/actors/{username}`, `/pub/objects/{id}`), even for public resources. Unsigned requests to these endpoints may be rejected with HTTP 401. This is equivalent to Mastodon's "secure mode" and helps prevent abuse and scraping by blocked or defederated instances.

**Configurability:**  
This behavior can be changed by admins in an instance's configuration, if they want unsigned GETs (to public resources) to be allowed.

### Common Pitfalls

- Missing or invalid signature header.
- Using an incorrect `keyId` or public key.
- Not including required headers in the signature.
- Not handling both with/without query parameters for signature validation.

> For more details, see [HTTP Signatures RFC][10] and [Bonfire ActivityPub Implementation Docs][9].

## 8. Rate Limiting

Bonfire applies rate limiting to all federation endpoints, including both incoming and outgoing ActivityPub and WebFinger requests.

### Incoming Federation Endpoints

Federation endpoints are rate limited per IP address. If the rate limit is exceeded, Bonfire responds with HTTP status `429 Too Many Requests` and a `Retry-After` header indicating when to retry. The default rate limits can be configured by the instance admin. Rate limited endpoints include:

- **Inbox / Shared Inbox:**  Incoming POST requests to inbox endpoints
- **GET requests for Actor and Object** endpoints (e.g. `/pub/actors/{username}` and `/pub/objects/{id}`)
- **WebFinger:**  Incoming GET requests to the WebFinger endpoint

### Outgoing Federation Requests

- **Outgoing HTTP requests** (to remote servers) also support rate limiting and include retry logic. If a remote server responds with `429 Too Many Requests` or `503 Service Unavailable`, Bonfire will respect the `Retry-After` header and automatically retry after the indicated delay.

### HTTP Status Codes and Headers

- `429 Too Many Requests`: Returned when the rate limit is exceeded.
- `503 Service Unavailable`: May be returned by remote servers; Bonfire will retry as appropriate.
- `Retry-After`: Indicates how many seconds to wait before retrying.

### Interop Notes

- Remote servers should respect `Retry-After` headers and avoid retrying requests too quickly.
- If you receive a `429` from Bonfire, wait the indicated time before retrying.
- Rate limits are applied per IP and per endpoint.

> For more details, see the [Bonfire ActivityPub Implementation Docs][9].

## 9. Moderation, Flagging, and Blocking

Bonfire provides robust moderation tools and supports federated moderation activities to help maintain healthy communities and enforce local policies.

### Blocking

Bonfire supports several types of blocks, each with distinct effects:

- **Ghost block**: The blocked user is prevented from seeing or interacting with you or your content on your instance:
  - Private posts and activities are never delivered to ghosted users.
  - Public posts may still be visible to ghosted users on remote instance or via public instance web views.
  - Ghosted users cannot follow, mention, or message you, and you cannot mention or message them.
  - Undoing a ghost block is possible, but missed activities are not retroactively delivered.
  - Instance admins can enforce ghost blocks globally, preventing a user from seeing or interacting with any local users.

- **Silence**: You stop seeing content from the silenced user:
  - Their posts and activities are filtered from your feeds and notifications.
  - You can still view their profile or posts via direct links.
  - You won't see mentions or messages from them, and you cannot follow them.
  - Undoing a silence is possible, but missed activities are not retroactively restored.
  - Instance admins can silence a user for all local users, hiding their content from all local feeds.

- **Full block**: All of the above.

- **Instance-level blocks (defederation)**: Admins can block entire domains, preventing all federation with those instances.

All block types are enforced at the boundaries level and affect both incoming and outgoing federation as appropriate.

### Flagging (Reporting)

- **Flag activities:**  
  - Bonfire supports the ActivityStreams `Flag` activity for reporting users, posts, or other objects for moderation.
  - Incoming `Flag` activities from remote instances are processed as moderation reports and routed to moderators.
  - Outgoing `Flag` activities are federated to remote instances' [shared inbox](#shared-inbox) when a user reports content originating elsewhere.
- **Moderation workflow:**  
  - Reports can be reviewed, actioned, or dismissed by moderators. Actions may include warning, silencing, blocking, labeling, editing, or deleting content or accounts.

### Interop Notes

- Remote instances can expect Bonfire to process incoming `Flag` activities according to local moderation policy.
- Bonfire federates moderation actions as appropriate, including `Flag`, `Update`, and `Delete` activities.
- Bonfire follows the ActivityPub and ActivityStreams conventions for moderation activities, ensuring compatibility with major implementations.

> For more details, see [Bonfire ActivityPub Implementation Docs][9] and the [ActivityStreams Spec][1] for `Flag` and `Block` activities.

## 10. Circles, Boundaries & Interaction Policies

Bonfire provides advanced privacy and interaction controls, supporting both standard ActivityPub audience fields and newer proposals like [FEP-1b12](https://codeberg.org/fediverse/fep/src/branch/main/fep/1b12/fep-1b12.md) for interaction policies.

### Circles and Boundaries

- **Circles** in Bonfire are flexible audience groups (similar to "circles" or "lists" in other platforms), used to define custom sharing boundaries for posts and activities.
- **Boundaries** are Bonfire's mechanism for enforcing privacy, collaboration permission, and blocks. They determine who can see, interact with, or receive a given activity.
- When federating, Bonfire always maps circles and boundaries to ActivityPub addressing fields (in `bto` or `bcc`) as appropriate. Circles are not federated as named groups; only the resolved list of recipients is included in the addressing fields.
- Remote instances will only see the addressing fields, not the internal circle names or membership. Circle membership is not exposed to other users or to remote servers by default.

### Interaction Policies (FEP-1b12 and related)

- Bonfire supports [FEP-1b12](https://codeberg.org/fediverse/fep/src/branch/main/fep/1b12/fep-1b12.md) and related proposals for fine-grained interaction control.
- Posts and objects can include an `interactionPolicy` property, specifying who can like, reply, announce, or quote.
- Sub-policies include `canLike`, `canReply`, `canAnnounce`, and `canQuote`, each with `automaticApproval` and optionally `manualApproval` fields.
- Bonfire includes `interactionPolicy` [15] on outgoing posts when appropriate. This property is intended as an FYI for remote instances, so they can disable or hide actions in their UI (and avoid users enacting interactions that will not be properly federated to their intended recipients but could still seen by users of their own instance). 
- Bonfire will always enforce these policies, e.g. if a remote instance does not support or respect `interactionPolicy`, Bonfire will still reject any incoming interaction (reply, like, announce, etc) that violates the policy.

### Approval Flows

- Both automatic and manual approval flows are supported for local and remote users.
- When a remote user attempts an interaction that requires manual approval, Bonfire federates a pending request and responds with `Accept` or `Reject` activities as appropriate, following FEP-1b12.
- The `approvedBy` property is used to indicate explicit approval by the post author, and Bonfire supports both auto-accept and manual approval flows.

### Interop Notes

- Remote servers that do not support `interactionPolicy` will fall back to default ActivityPub behavior (anyone who can see a post can interact with it), but Bonfire will still enforce its policies and reject unauthorized interactions.
- Bonfire will respect incoming `interactionPolicy` properties from remote posts, enforcing restrictions locally.
- Audience enforcement is always based on both addressing fields and interaction policies.

> For more details, see [Bonfire ActivityPub Implementation Docs][9] and [FEP-1b12][5].

## 11. Testing & Debugging

Testing and debugging federation with Bonfire requires understanding ActivityPub S2S flows, HTTP signatures, and proper request formatting.

### Required Headers

- `Accept`: Use `application/activity+json` or `application/ld+json; profile="https://www.w3.org/ns/activitystreams"` for ActivityPub endpoints.
- `Signature`: All S2S requests should be signed (see [HTTP Signatures](#7-http-signatures--secure-fetch)), unless the instance accepts non-signed requests for public objects.
- `Date`: Required for signature validation.
- `Digest`: Required for signed POST requests.

**Note:** All example curl commands below assume you will include the required headers if needed, including a valid `Signature` header.

### Example curl commands

**Fetch a remote actor (signed GET):**
```sh
curl -H "Accept: application/activity+json" \
     -H "Date: $(date -u +'%a, %d %b %Y %H:%M:%S GMT')" \
     https://a.bonfire.instance/pub/actors/alice
```

**Fetch a remote object (signed GET):**
```sh
curl -H "Accept: application/activity+json" \
     -H "Date: $(date -u +'%a, %d %b %Y %H:%M:%S GMT')" \
     https://a.bonfire.instance/pub/objects/01H8ZK2YXP9QCT5BE1JWQSAM3B6
```

**Send an activity to an inbox (signed POST):**
```sh
curl -X POST \
     -H "Accept: application/activity+json" \
     -H "Content-Type: application/activity+json" \
     -H "Date: $(date -u +'%a, %d %b %Y %H:%M:%S GMT')" \
     -H "Digest: SHA-256=..." \
     --data-binary @activity.json \
     https://a.bonfire.instance/pub/actors/alice/inbox
```

**WebFinger lookup (no signature required):**
```sh
curl -H "Accept: application/jrd+json" \
     "https://a.bonfire.instance/.well-known/webfinger?resource=acct:alice@your.bonfire.instance"
```

### Debugging Tips

- Check for required headers (eg `Signature`) and correct content types.
- Use verbose curl output (`-v`) to inspect HTTP status codes and headers.
- Check logs for signature validation errors, rate limiting (`429`), or access control (`403`).
- Inspect the job queues for stuck or failed federation jobs. Bonfire users can view their federation queue at `/settings/user/federation_status`.

### Troubleshooting Common Issues

- **401 Unauthorized**: Missing or invalid HTTP signature.
- **403 Forbidden**: Blocked by boundaries, blocks, or instance defederation.
- **429 Too Many Requests**: Rate limit exceeded; check `Retry-After` header.
- **406 Not Acceptable**: Incorrect `Accept` or `Content-Type` header.
- **422 Unprocessable Entity**: Malformed activity or object.
- **503 Service Unavailable**: Remote server is down or overloaded.

> For more details, see [Bonfire ActivityPub Implementation Docs][9] and the [ActivityPub Spec][1].

<!--
## 12. Compatibility Notes
- Known quirks with Mastodon [3], Pixelfed, GoToSocial [8], etc.
- Supported/not-currently-supported ActivityStreams extensions [1], [3]
- JSON-LD context handling
- HTML sanitization [3]

## 13. Quirks & Gotchas
- Known interop issues and edge cases
- Differences from Mastodon [3], GtS [8], etc.
- Common pitfalls for implementers

## 14. FAQ / Troubleshooting
- Common issues and solutions
- Contact/support links
-->

## 15. Glossary

### ActivityPub
A decentralized social networking protocol based on the ActivityStreams data format. [1]

### ActivityStreams
A model/data format for representing potential and completed activities using JSON. [11]

### Actor
An ActivityStreams object capable of performing activities (e.g., Person, Group, Service). [12]

### Dereference
To fetch the ActivityStreams representation of a resource (e.g., actor or object) by making an HTTP request to its canonical URI.

### WebFinger
A protocol for resolving user identifiers (e.g., `@user@domain`) to canonical profile URIs. [2]

### FEP 
Fediverse Enhancement Proposal, a community process for proposing and documenting protocol extensions. [4]

### HTTP Signature 
A cryptographic signature for HTTP requests, used to authenticate and authorize ActivityPub S2S messages. [10]

### Inbox 
Endpoint on an actor for receiving activities.

### Outbox
Endpoint on an actor for publishing activities.

### Public URI
The special URI `https://www.w3.org/ns/activitystreams#Public` used to indicate public addressing.

### MRF
Message Rewrite Facility, a policy system for filtering or modifying federated activities.

### Boundary 
Bonfire’s mechanism for enforcing privacy, blocks, and audience restrictions.

### Peered 
A mapping between a local object and its canonical URI.

### Canonical URI 
An activty, object or actor's `id`: an authoritative, globally unique URI.

### ApprovedBy 
Property indicating an interaction was explicitly approved by the target actor (see FEP-1b12 [5]).

### Flag 
The ActivityStreams activity type for reporting moderation issues.

### Interaction Policy 
A set of rules (e.g., canLike, canReply) governing who can interact with a post. [5]

### Instance
A single deployment of a federated server (e.g., a Bonfire, Mastodon, or GtS server).

### Shared Inbox 
An endpoint for batching delivery of activities to multiple actors on the same instance. [14]

### Tombstone
An object indicating that a resource (e.g., a post or actor) has been deleted.

### Hashtag
An ActivityStreams extension representing a topic tag.

### Emoji 
An ActivityStreams extension representing a custom emoji.

### PropertyValue 
A [schema.org](https://schema.org/PropertyValue) extension for profile metadata fields.

### Create 
The ActivityStreams activity type for creating an object. [12]

### Update 
The ActivityStreams activity type for updating an object. [12]

### Delete 
The ActivityStreams activity type for deleting an object. [12]

### Accept 
The ActivityStreams activity type for accepting an activity. [12]

### Reject 
The ActivityStreams activity type for rejecting an activity. [12]

### Note 
An ActivityStreams object type representing a short-form post. [12]

### Article
An ActivityStreams object type representing a long-form post. [12]


<!-- ## 17. References -->

[1]: https://www.w3.org/TR/activitypub/ "ActivityPub Specification"  
[2]: https://datatracker.ietf.org/doc/html/rfc7033 "WebFinger RFC"  
[3]: https://docs.joinmastodon.org/spec/activitypub/ "Mastodon ActivityPub Docs"  
[4]: https://codeberg.org/fediverse/fep "Fediverse Enhancement Proposals (FEPs)"  
[5]: https://codeberg.org/fediverse/fep/src/branch/main/fep/1b12/fep-1b12.md "FEP-1b12: Interaction Policy"  
[6]: https://codeberg.org/fediverse/fep/src/branch/main/fep/400e/fep-400e.md "FEP-400e: Private Mentions"  
[7]: https://codeberg.org/fediverse/fep/src/branch/main/fep/044f/fep-044f.md "FEP-044f: Quote Posts"  
[8]: https://docs.gotosocial.org/en/latest/federation/ "GoToSocial Federation Docs"  
[9]: https://docs.bonfirenetworks.org/TODO "Bonfire ActivityPub Implementation Docs"  
[10]: https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures "HTTP Signatures RFC"  
[11]: https://www.w3.org/TR/activitystreams-core/ "ActivityStreams 2.0 Core Syntax"  
[12]: https://www.w3.org/TR/activitystreams-vocabulary/ "ActivityStreams 2.0 Vocabulary"
[13]: https://www.valueflo.ws "ValueFlows"
[14]: https://www.w3.org/TR/activitypub/#shared-inbox-delivery "ActivityPub Shared Inbox Delivery"
[15]: https://docs.gotosocial.org/en/v0.19.2/federation/interaction_policy/ "Interaction Policy"