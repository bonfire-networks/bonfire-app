# Moving away from your Bonfire instance

A step-by-step guide for migrating your account from Bonfire to another fediverse instance.

*Moving between fediverse instances preserves the decentralized nature of the network while giving you control over your online presence.*

## Table of Contents

- [Before you move](#before-you-move)
- [Step 1: Export your data](#step-1-export-your-data)
- [Step 2: Create your new account](#step-2-create-your-new-account)
- [Step 3: Set up account aliases](#step-3-set-up-account-aliases)
- [Step 4: Import your data to the new instance](#step-4-import-your-data-to-the-new-instance)
- [Step 5: Move your followers](#step-5-move-your-followers)
- [Step 6: Clean up your old account](#step-6-clean-up-your-old-account)
- [Troubleshooting](#troubleshooting)

## Before you move

### Things to consider

- **Posts cannot be migrated** - Your post history will remain on your old Bonfire instance
- **Process is irreversible** - Account moves cannot be undone
- **Different features** - Your new instance may have different capabilities than Bonfire

### What can be migrated

✅ **Automatically transferred:**
- Your followers (if the destination supports ActivityPub moves)

✅ **Can be manually imported:**
- Profiles you follow
- Blocked, silenced, and ghosted profiles
- Bookmarked posts
- Custom circles/lists 

❌ **Cannot be migrated:**
- Your posts and media
- Post statistics (likes, boosts, replies)
- Conversation history


## Step 1: Export your Bonfire data

1. Go to **Settings > Export** in your Bonfire instance
2. Download CSV files for:
   - Following list
   - Blocked, silenced, and ghosted profiles
   - Bookmarks
   - Circles/Lists 
3. Request a full archive of your posts for personal backup, which will contain
   - All of the CSV files above
   - Activities in ActivityPub JSON format
   - Your uploads
   - Your profile info and public/private key

💡 **Tip:** Export your data even if you're just testing - it's good to have a backup!


## Step 2: Create your new account

1. **Choose your destination instance**
   - Research the instance's rules and community
   - Check if they support account migration (most Bonfire, Mastodon, Akkoma, Pixelfed, and some other ActivityPub instances should)
   - Verify the new instance can federate with your old Bonfire instance

2. **Sign up for your new account on your destination instance**
   - Use the same username if available
   - Set up your profile with the same display name and bio
   - Upload your profile picture and header


## Step 3: Set up account aliases

### On your new instance
1. Go to your new instance's profile settings
2. Look for section such as "Aliases" or "Moving from another account"
3. Add your old Bonfire account as an alias:
   - Enter: `@youroldusername@your-bonfire-instance.org`
4. Save the alias

### On your old Bonfire instance
1. Go to **Settings > Account** 
2. Scroll to the bottom for migration options
3. In the "Account aliases" section:
   - Add your new account: `@yournewusername@new-instance.net`
4. Save the alias

### **Verify your new account is working**
1. Follow it from your old Bonfire profile
2. Follow your old Bonfire profile from your new account
3. Make a test post on each profile
4. Ensure federation is working properly in both directions
5. ✅ Both accounts should now show the other as a verified alias


## Step 4: Import your data to the new instance

1. Go to your new instance's **Settings > Import** (location may vary by software)

2. **Import following list:**
   - Upload your `following.csv` from Bonfire
   - Choose "Merge" to add to existing follows, or "Overwrite" to replace

3. **Import blocks and mutes:**
   - Upload `blocked_accounts.csv` and `muted_accounts.csv`
   - Choose your merge/overwrite preference

4. **Import other lists:**
   - Upload any other CSV files (bookmarks, custom lists/circles)
   - Note: Not all instance types support all import types

⏱️ **Processing time:** Large lists may take several minutes to process


## Step 5: Move your followers

⚠️ **Warning:** This step is irreversible!

1. **On your old Bonfire instance**, go to **Settings > Export**
2. Scroll to the bottom and find "Move to a different account"
3. Enter your new account address: `@yourusername@new-instance.com`
4. **Read all warnings carefully**
5. Enter your old account password to confirm
6. Click "Move followers"

### What happens next:

<!-- 
- Your Bonfire account will be marked as moved
- A "This account has moved" notice will appear on your profile 
-->
- Your followers will receive a notification to follow your new account
- Most ActivityPub-compatible software will automatically act on that notification and re-follow your new account on behalf of your followers
<!-- 
- Your Bonfire account will be restricted (no new posts, followers, etc.) 
-->


## Step 6: Clean up your old account

### Option A: Keep as redirect (Recommended)
- Leave your account as-is to to point visitors to your new account (you can update your bio with a notice)
- This means your old posts and activities are still accessible
- No further action needed

### Option B: Delete your old account
⚠️ **Only do this if you're absolutely sure!**

1. Wait at least a week after moving to ensure followers have migrated
2. **This is permanent and irreversible**
3. Your old username will become permanently unavailable
4. If you're sure, follow the instructions to [delete your data, profile, and/or account](data-manage.md#deleting-your-data)


## Troubleshooting

### My followers didn't transfer
- **Check if the destination instance supports moves** - Some software, or older or custom instances may not
- **Wait 48-72 hours** - Federation can be slow
- **Manual solution:** Ask followers to follow your new account directly

### Import failed
- **Check file format** - Ensure CSV files are from Bonfire export
- **File size limits** - Very large lists may need to be split
- **Instance compatibility** - Not all software supports all import types

### Can't set up aliases
- **Federation issues** - Ensure both instances can communicate
- **Account not found** - Verify the account address is correct and the account exists
- **Wait and retry** - Sometimes federation takes time

### Move button is disabled
- **Aliases not set up** - Both accounts must have each other as aliases
- **Recent move** - You may be in the 30-day cooldown period
- **Account restrictions** - Ensure your account is in good standing

### Getting error messages
- **Double-check account addresses** - Ensure the format is `@username@instance.com`
- **Contact instance admin** - They may need to check federation or account status
- **Try again later** - Temporary server issues can cause problems

---

### Need help?

- Check your Bonfire instance's documentation or help section
- Consult the destination instance's migration guide and documentation
- Contact your instance administrators
- Ask for help in the Bonfire community

