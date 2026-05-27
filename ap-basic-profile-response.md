# Response to: ActivityPub Basic Profile for Social API Servers

> Draft: https://swicg.github.io/activitypub-api/basicprofile

Thanks for sharing this — we've done a detailed comparison against Bonfire's implementation. Below is a summary of where we stand, what the draft gets right, and some feedback on gaps and design questions worth discussing.

---

## What Bonfire already implements

### OAuth 2.0 / OpenID Connect provider

- Authorization code flow with PKCE, token refresh, revocation (`/oauth/revoke`), introspection (`/oauth/introspect`)
- Dynamic client registration (RFC 7591) at `/openid/register`
- OpenID Connect layer: userinfo endpoint, JWKS, discovery at `/.well-known/openid-configuration`
- RFC 8414 authorization server metadata at `/.well-known/oauth-authorization-server`, including `client_id_metadata_document_supported: true`

### CIMD (Client ID Metadata Document / FEP-d8c2) — both directions

- **As a client**: we serve our own CIMD at `/.well-known/oauth-client` and use it as `client_id` when authenticating to other servers
- **As a provider**: our `validate_client_id` plug fetches and validates incoming CIMD URLs as `client_id`, allowing third-party clients to authorize without pre-registration

### proxyUrl

- Advertised in our AP actor's `endpoints` object as `proxyUrl: /pub/proxy_remote_object`
- The endpoint is implemented and routed in the `activity_pub` library

### C2S (Client-to-Server ActivityPub)

- `activity_pub` library has a full `C2SOutboxController` handling POST to actor outboxes
- Our adapter has C2S-aware paths: it can federate C2S-submitted activities directly and handle `Update` of local actors from C2S bodies
- Scope validation hook exists and is ready to wire up

---

## What's missing or incomplete

### 1. `activitypub_actor_id` in token responses

Our `token.json` response returns standard OAuth fields (`access_token`, `token_type`, `expires_in`, `refresh_token`, `id_token`, `scope`) but not the AP actor URL. This is the key field the draft adds on top of standard OAuth, and it's what AP-native clients need to resolve the authenticated actor without an extra userinfo roundtrip.

### 2. `activitypub_actor_id` missing from userinfo claims too

Our `claims/2` function currently returns the internal user ID as `sub` and `name`. Neither the AP actor URL nor an `activitypub_actor_id` claim is included. Clients using OpenID Connect will naturally go to userinfo for identity, so the omission there is equally important as in the token response (see feedback section below).

### 3. AP-native scope vocabulary

The draft defines granular per-activity-type scopes (`activitypub:write:create`, `activitypub:write:follow:sameorigin`, etc.). We use Mastodon-compatible scopes (`read`, `write`, `follow`, `push`, `identity`, `data:public`, etc.). We'd need to support both vocabularies or define a mapping.

### 4. C2S scope enforcement

`C2SOutboxController` has scope validation commented out (`# TODO: uncomment when scope validation is implemented`). The hook exists but the AP-profile scope names aren't wired up yet, meaning the C2S endpoint is effectively unguarded at the scope level.

### 5. `activitypub_object_id_as_client_id` flag

Our RFC 8414 metadata declares `client_id_metadata_document_supported: true` but not `activitypub_object_id_as_client_id`. Supporting AP actor URLs directly as `client_id` (without a CIMD fetch) would extend this further.

---

## Pros and cons of our current approach

**What works well:**
- Mastodon API + CIMD combination gives the widest client compatibility today without waiting for this spec to stabilise
- CIMD on both provider and client sides already aligns with the draft's core federation-auth story
- proxyUrl and C2S infrastructure already exists — we're not starting from scratch

**Tradeoffs:**
- Mastodon scopes are coarser — no per-activity-type or `sameorigin` restriction capability
- Missing `activitypub_actor_id` in both token responses and userinfo means AP-native clients need extra roundtrips or guesswork to resolve the authenticated actor
- C2S scope enforcement being TODO means the C2S endpoint is currently unguarded at the scope level

---

## Suggested next steps (low effort, high value)

1. **Add `activitypub_actor_id` to token responses** — resolve the authenticated user's AP actor URL and inject it into the token response
2. **Add `activitypub_actor_id` to userinfo claims** — include it alongside `sub` in the claims returned from the userinfo endpoint
3. **Wire up C2S scope validation** — implement the scope check in `C2SOutboxController` against our existing scope set
4. **Add `activitypub_object_id_as_client_id: true`** to RFC 8414 metadata if/when we support raw AP actor URLs as `client_id`
5. **Track the scope vocabulary** — the `activitypub:*` scopes are the most fluid part of this draft; worth watching before committing to an implementation

The spec is experimental and Mastodon hasn't adopted it yet, so a measured approach makes sense. Items 1 and 2 are worth doing regardless of the spec's trajectory.

---

### Gaps and underspecified areas

#### `sameorigin` semantics are undefined

The draft defines a whole family of `activitypub:write:*:sameorigin` scopes that "restrict operations to objects sharing the client's origin" — but never defines what "origin" means in this context. Is it the RFC 6454 web origin of the `client_id` URL? The AP actor's domain? The `object.origin` property? This needs to be normatively defined before implementations can interoperate. It also raises questions about CIMD-based clients (whose `client_id` is their own instance URL) vs. native app clients with a non-URL or `oob` redirect.

#### CIMD vs. FEP-d8c2 distinction is blurry

The spec treats CIMD URLs and FEP-d8c2 (AP actor URL as `client_id`) as distinct options but doesn't explain the practical difference or when one is preferred. Or we could use 1 doc that supports both. But w

#### `activitypub_actor_id` should be MUST in token responses, not SHOULD

This is the single most important field the spec adds over standard OAuth — it's what allows any AP client to resolve who authenticated without a separate userinfo call. Leaving it as SHOULD means some servers will skip it and clients will need fallback logic, defeating the interoperability goal. We'd suggest upgrading this to MUST (at minimum when `openid` scope is not also in use and the token is not a JWT with the actor URL as `sub`).

#### should `activitypub_actor_id` also be required in the userinfo endpoint?

The draft specifies `activitypub_actor_id` in the token response and as the JWT `sub` claim, but the userinfo endpoint isn't addressed. Clients using OpenID Connect will naturally go to userinfo for identity claims — and they'll find `sub` is the OIDC subject (internal user ID), not the AP actor URL.

The spec should require that `activitypub_actor_id` also appear as a claim in the userinfo response. Alternatively, if the server uses the AP actor URL as `sub` (as the JWT token section requires for JWTs), it should do the same in userinfo, but some apps may include a different ID the the sub, so adding the separate field may redundant but consistent. Without this, a token response can have `activitypub_actor_id: "https://example.com/users/alice"` while the userinfo `sub` is an opaque internal ID, which will confuse clients trying to correlate identity across both endpoints. 

#### Media upload endpoint: no protocol specified

The spec says servers SHOULD support a media upload endpoint but this requires an interoperable spec.

--

### Design questions worth discussing

#### Scope granularity: useful or burdensome?

The draft defines ~40 scopes. This is fine for applications that need fine-grained permissions (a read-only analytics tool, a bot that can only `Announce`), but it places significant burden on both servers (must correctly enforce all of them) and users (consent screens become unwieldy). Worth discussing whether a tiered model — coarse defaults plus fine-grained opt-in — would be more practical, and whether `read`/`write` shorthands should be first-class rather than mere synonyms.

#### No HTTP Signatures mention

The spec is entirely OAuth-centric and doesn't mention HTTP Signatures, which are used for S2S federation across the Fediverse today. For AP-native clients authenticating to their home server this is fine, but a non-normative note on the relationship (and why HTTP Signatures are explicitly out of scope for this profile) would reduce confusion for implementors coming from the S2S world.

#### CORS `*` is incompatible with authenticated requests

The spec says servers SHOULD set `Access-Control-Allow-Origin: *`. However, browsers forbid sending credentials (cookies or `Authorization` headers) alongside a wildcard CORS response — so `*` only works for public, unauthenticated reads. Authenticated API calls require the server to echo back the specific requesting origin in `Access-Control-Allow-Origin` (and include `Vary: Origin` to ensure correct caching).

The spec should clarify: use `*` for public/unauthenticated endpoints (e.g. fetching a public actor or note), and echo-origin CORS for any endpoint that accepts an `Authorization` header. Echo-origin means the server reads the `Origin` header from the request and reflects it back verbatim in the response — paired with `Access-Control-Allow-Credentials: true` when needed. Without this distinction, implementations will either break authenticated browser-based clients or serve overly permissive CORS headers.


