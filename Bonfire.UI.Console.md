# Bonfire.UI.Console

Gives an admin a live Elixir (IEx) shell inside the running instance, from a page in the browser, for a window that closes by itself. It exists so an operator can hand someone debugging access for a day without giving them SSH keys or a deploy account.

> WARNING: Only grant this to someone you'd trust with the server itself. See security details below.

## Granting access, step by step

First include the extension in your build. Without this the console isn't available at all.

Then, each time you want to grant access:

1. **Decide how long the door stays open**, e.g. until tomorrow 17:00. Treat it like an invite link with an expiry which doubles as their deadline to finish: when the expiry time arrives, any open shell is cut off, unless they deliberately work around that.

   Generate a UUIDv7 stamped with that moment, at <https://uuidv7.org/> or any generator that lets you set a custom timestamp. The timestamp inside the token *is* the expiry, there's no separate setting.
2. **Set it in `.env` and restart:**
   ```
   BONFIRE_CONSOLE_TOKEN=0188a516-bc8c-7c5a-9b68-12651f558b9e
   ```
   On boot you should see `console is armed until <time>, scheduling its purge for then` in the logs. If you instead see it disarm, the token is malformed or already past.
3. **Make sure their user account is an admin** on the instance. The token alone gets nobody in.
4. **Send them the token** out of band (eg. using end-to-end encrypted chat).
5. **They open** `https://instance.tld/admin/console`, paste it into the form, and get a shell.
6. **Watch the transcript** as they work: every line is logged at `warning`, prefixed `CONSOLE <username> from <ip>`. If the App Logs page is enabled it shows up at `/admin/system/logs`.

To end it early, either of you can press **Revoke console access** on the page. That kills every open shell and stops any new session being opened until the app restarts — it is not "close my tab", which ends only that person's own session and leaves the console armed.

Note that a restart re-arms it, since the token is still in the environment and still in date. To retire it for good, remove `BONFIRE_CONSOLE_TOKEN` and restart.

You don't need to remove token from env or restart when the window ends: the scheduled purge fires on its own.

## WARNING: Only grant this to someone you'd trust with the server itself

A shell in the running app can read and change **everything the app can**: every private post and message, every email address, every credential in its environment, and the database it connects to. That includes content federated from people on other instances, who never agreed to your admin team seeing it. It is not a read-only or scoped view, and there is no way to make it one.

Concretely, it grants the privileges of the OS user the app runs as, inside whatever it runs in:

- **not root**, unless the app is running as root (it shouldn't be), so it can't necessarily touch the host system or other services;
- **in a container, that container** — its filesystem, its network reach, its env vars, and not the host, unless the container is privileged or has the host mounted in or using an exploit to break out;
- **but everything the app can reach**, which usually means the database, object storage, mail credentials, and any API keys in its environment.

No safeguard here changes that, and none can. Every one of them is ordinary Elixir code running in the same instance as the shell it guards, so the shell can call the same functions it does — a guard cannot hold a door from behind it. Someone who decides to keep access can load the purged modules back, cancel the job that would purge them, start a shell by another route, silence/purge their own audit trail, or write something to disk that runs again after a restart. None of it takes unusual skill; it is the same API the console itself uses.

The audit log is subject to that too: a session can switch off its own recording, or remove the log handler entirely. It is a record of what someone did, not evidence against someone who set out to avoid leaving one. Shipping logs off the machine as they are written is what makes it harder to rewrite history, so lines already sent cannot be unsent, even if no further ones arrive.

What the mechanisms below *do* buy: an instance that never includes the extension carries no console code at all; one that includes but doesn't arm it carries none of it loaded; a hijacked admin session without the token gets nothing; and a forgotten grant closes itself. The expiry is the window in which the door is open, not a limit on how long someone can stay once through it. It reliably stops new sessions, and ends one left running by someone who isn't resisting, but guarantees nothing against someone who decides to keep access.

So the bar is "someone I'd trust with full access to this server", even though it is usually narrower than root SSH access. Everything below limits *when it is granted*, not *what it can do or for how long*, and the recourse afterwards (rotating the token, restarting, reading whatever the log did capture) assumes a cooperation you cannot enforce.

**This is deliberately a remote code execution endpoint.** It is built to be absent by default and armed only on purpose:

1. **Not in the build** unless `bonfire_ui_console` is listed in the parent app's deps. Removing that line removes the console and all terminal machinery.
2. **Not armed** unless a time-limited `BONFIRE_CONSOLE_TOKEN` token is set. On every boot without a non-expired token, the console's own modules and its dependencies are deleted and purged from the running VM.
3. **Not usable** without both an admin session *and* the token.

## How it works

**At boot** the extension reads `BONFIRE_CONSOLE_TOKEN`. If it's missing, malformed, or its timestamp has already passed, the console's own modules and the terminal library are deleted from the running app there and then, so on an unarmed instance there is nothing left to call, only a page that refuses. If the token is valid, a purging job is scheduled for the expiry date/time.

**The token** is both the expiry and the bearer secret, which is why there's no second setting to keep in sync. A ULID works as well as a UUIDv7, since both carry a millisecond timestamp and enough randomness to be unguessable; UUID versions without one, such as v4, are refused.

**Opening a session** needs an admin login *and* the token, pasted into a form. The token never appears in a URL, so it reaches no access log, no `Referer` header, and no browser history. The form looks the same whether or not the instance is armed, and every rejection (unarmed, wrong, expired, malformed) gives one identical message, with the real reason logged server-side, so the arming state is not observable.

**The shell itself** runs on the server: an IEx session driven through a terminal emulator, one per open page. The browser only draws it, using a JS terminal UI fetched on demand so it isn't in the main asset bundle. Keystrokes go up over the existing socket, output comes back.

**The transcript** is read from that output stream server-side. Because a terminal echoes what you type, the stream carries the commands as well as their results. Each completed line is logged with the admin's username and the IP address they connected from.

Be aware that this puts an admin's IP address into your logs, and wherever those are shipped and retained.

**At the expiry** the scheduled job deletes those modules, killing any shell still open rather than merely refusing the next session.

That deletion only sticks where the VM preloads code (`embedded` mode), which is what a release usually does: `bin/bonfire start` defaults `RELEASE_MODE` to `embedded`. Under `interactive` (dev, or a release explicitly started with `RELEASE_MODE=interactive`) the modules simply reload the next time they're called, so revoking and expiry come down to the token check alone. 

## Copyright and License

Copyright (c) 2026 Bonfire contributors

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
