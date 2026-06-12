Tauri cross-platform native app (simply serves the web app for now)

Usage:

If you don't yet have tauri cli: 

`cargo install tauri-cli --version "^2.11" --locked`

Note: the local plugin forks must be cloned for any build (they are Cargo `[patch]` paths):

```
git clone https://github.com/bonfire-networks/tauri-plugin-openmls forks/tauri-plugin-openmls
git clone -b wip https://github.com/bonfire-networks/tauri-playwright forks/tauri-plugin-playwright
```

The login shell also needs the chat client cloned (bare gitlink, no .gitmodules —
`pick-instance.html` imports its `dist/activitypub/auth.js` for the OAuth flow):

```
git clone https://github.com/bonfire-networks/ap_c2s_client \
  extensions/bonfire_ui_common/assets/static/tauri/assets/ap_c2s_client
(cd extensions/bonfire_ui_common/assets/static/tauri && yarn install && yarn build)
```


To try it in dev, run this (at the root of this repo):

`cargo tauri dev`

and to run a second instance of it (useful for testing two-way user flows): 

`cargo tauri dev --config '{"identifier":"cafe.bonfire.dev2"}'`

For testing on Android:

`cargo tauri android build --apk true`

Or to compile for a single architecture (eg. if using the simulator):

`cargo tauri android build --apk true --target aarch64`

For iOS (see docs/tauri-mobile.md for the full reference):

- Prerequisites: Xcode, `rustup target add aarch64-apple-ios aarch64-apple-ios-sim`
- Run in a simulator: `just tauri-ios-sim` (or `cargo tauri ios dev "iPhone 16 Pro"`)
- Run on a plugged-in iPhone: sign into Xcode with your Apple ID once
  (Settings → Accounts), then `TAURI_APPLE_DEVELOPMENT_TEAM=<team id> just tauri-ios-dev`
- Build an IPA: `just tauri-ios-build`
- The iOS bundle identifier (`cafe.bonfire.app`) is set in `tauri.ios.conf.json`;
  `gen/apple/project.yml` is the committed XcodeGen input — edit it, not the
  generated `.xcodeproj`/`Info.plist`.
