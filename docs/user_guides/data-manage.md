# Managing your data on Bonfire

Take control of your information on Bonfire.

## Table of Contents

- [Moving your information](#moving-your-information)
  - [Available exports](#available-exports)
  - [Importing data](#importing-data)
- [Deleting your data](#deleting-your-data)
- [Frequently Asked Questions](#frequently-asked-questions)

## Moving your information

Bonfire provides data portability, you can export and/or import your data at any time to maintain control over your information.

### Available exports

You can export the following data as CSV files from **Settings > Export**:

- **Following** and **Follow Requests** - All profiles you follow
- **Followers** - All profiles who follow you
- **Blocked, silenced and/or ghosted accounts** - List of profiles and domains you've blocked
- **Posts** and **Messages** - Things you've posted or sent
- **Circles** - Export your custom circles and lists, and the list of their members
- **Bookmarks** - Your saved posts and activities 


#### Archive requests

You can request a complete archive of your posts and media once every 7 days. Archives are provided in Activity Streams 2.0 JSON format, which can be read by any compatible software.


### Importing data

Some types of data (whether exported from a Bonfire instance, or another compatible one such as Mastodon) can be imported at **Settings > Import** by uploading CSV files:

- **Following** - Profiles you want to (re-)follow
- **Blocked, silenced and/or ghosted accounts** - List of profiles and domains you want to block
- **Lists/circles** - Importing lists turns them into circles
- **Bookmarks** - Any saved posts and activities 


## Deleting your data

### Important considerations

- **Irreversible action** - Cannot be undone
- **Profile and posts/activities data is permanently removed**
- **Username becomes permanently unavailable** - No one can use your old username again
- **A copy of content may remain cached** on other instances. Bonfire sends an instruction to delete data to instances known to have a copy, but some may be unknown or unreachable and some software may be buggy or not comply. 

### Before deleting

Consider these alternatives:
1. [Export your data](#moving-your-information) for backup
2. Delete specific posts or activities
3. [Redirect your profile](#profile-redirect) instead of deleting
4. [Move your account](#profile-move) to a different instance

### Deleting your profile

Profile deletion can be found at the bottom of **Settings > Profile**.

Deleting your user profile will remove all associated data from this server. This includes all posts, comments, and any other data associated with this user profile. It will also send requests to delete your data to other fediverse servers.

### Deleting your account

Account deletion can be found at the bottom of **Settings > Account**.

Deleting your account will delete all your user profiles, and remove all your data from this server. This includes all your posts, comments, and any other data associated with your account.


## Frequently Asked Questions

### Can I recover my account after deletion?

No, account deletion is permanent and cannot be undone. Your username will also be permanently unavailable.

### What happens to my data on other servers?

Bonfire will attempt to notify other servers to delete your data, but cannot guarantee compliance due to software or network limitations.

### How often can I request an archive?

You can request a full archive of your posts and media once every 7 days.

### Can I import data from other platforms?

You can import compatible CSV exports from Bonfire and other fediverse platforms like Mastodon for supported data types.

### Where can I get help?

If you need assistance, contact your instance administrator or visit the Bonfire community channels.

