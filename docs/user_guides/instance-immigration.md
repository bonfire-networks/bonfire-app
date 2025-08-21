# Moving to a Bonfire instance

A step-by-step guide for migrating your account from another fediverse instance to Bonfire.

*Moving to Bonfire opens up new possibilities for community-driven, boundary-respecting social networking.*

## Table of Contents

- [Before you move](#before-you-move)
- [Step 1: Export your data from your old instance](#step-1-export-your-data-from-your-old-instance)
- [Step 2: Create your Bonfire account](#step-2-create-your-bonfire-account)
- [Step 3: Set up account aliases](#step-3-set-up-account-aliases)
- [Step 4: Import your data into Bonfire](#step-4-import-your-data-into-bonfire)
- [Step 5: Move your followers](#step-5-move-your-followers)
- [Step 6: Clean up your old account](#step-6-clean-up-your-old-account)
- [Troubleshooting](#troubleshooting)

## Before you move

### Things to consider

- **Posts cannot be migrated** - Your post history will remain on your previous instance
<!-- 
- **30-day cooldown** - You can only migrate once every 30 days on most instances 
-->
- **Process is irreversible** - Profiles moves cannot be undone
- **New features** - Bonfire has unique features like circles that may not exist on your previous instance

### What can be migrated

✅ **Automatically transferred:**
- Your followers (if your old instance supports ActivityPub moves)

✅ **Can be manually imported:**
- Profiles you follow
- Blocked accounts
- Muted accounts
- Bookmarked posts (if your old instance exports them)

❌ **Cannot be migrated:**
- Your posts and media
- Post statistics (likes, boosts, replies)
- Conversation history
- Instance-specific features (lists may become circles, etc.)


## Step 1: Export your data from your old instance

The export process varies by software. Here are common locations:

### From Mastodon
1. Go to **Settings > Import and export > Data export**
2. Download CSV files for follows, blocks, mutes, bookmarks, and lists
3. Request archive of posts and media

### From Bonfire (if migration between two Bonfire instances)
1. Go to **Settings > Export**
2. Download CSV files for follows, silences, ghosts, etc
3. Request full archive of activities and uploads

### From Akkoma
1. Go to **Settings > Data export**
2. Export follows, blocks, mutes as available

### From Misskey & co
1. Go to **Settings > Import/Export**
2. Export following list, blocked users, muted users
3. Lists and other data may need to be manually recreated

### From other instances
- Check your instance's documentation
- Look for "Export", "Backup" or "Data" in settings
- Contact your instance admin if unsure

## Step 2: Create your new Bonfire account

1. **Choose your Bonfire instance**
   - Research the instance's community and rules
   - Check that it federates with your old instance

2. **Sign up for your account**
   - Use the same username if available
   - Set up your profile with display name and bio
   - Upload your profile picture and header

3. **Explore Bonfire's unique features**
   - Create custom circles for controlling how you share, and to organise your feeds
   - Set up your boundaries and privacy preferences
   - Familiarize yourself with Bonfire's interface

## Step 3: Set up account aliases

### On your old instance

The process varies by software:

**Mastodon/Akkoma/Pixelfed:**
1. Go to **Settings > Account**
2. Look for "Moving from another account" or "Account aliases"
3. Add your new Bonfire account: `@yournewusername@bonfire-instance.com`

**Bonfire** (if migration between two Bonfire instances):
1. Go to **Settings > Export**
2. Look for "Moving to a different profile" 
3. Add your new Bonfire account: `@yournewusername@bonfire-instance.com`

**Misskey/etc:**
1. Account aliasing may not be supported
2. You may need to manually notify followers

### On your Bonfire instance

1. Go to **Settings > Import** 
2. Scroll to the bottom for migration options
3. In the "Account aliases" section:
   - Add your old account: `@youroldusername@old-instance.com`
4. Save the alias

### **Verify your new account is working**
1. Follow it from your old profile
2. Follow your old account from your new Bonfire profile
3. Make a test post on each profile
4. Ensure federation is working properly in both directions
5. ✅ Both accounts should now show the other as a verified alias


## Step 4: Import your data into Bonfire

1. Go to **Settings > Import** in your Bonfire instance

2. **Import following list:**
   - Upload your following CSV file
   - They will automatically be re-followed little by little (you can check the progress and results by clicking on "Import History")

3. **Import blocks and/or silences and ghosts:**
   - Upload CSV files you exported previously

<!-- 
4. **Import bookmarks:**
   - Upload bookmarks CSV if available from your previous instance 
-->

<!-- 
5. **Import lists as circles** 
-->

⏱️ **Processing time:** Large lists may take several minutes or hours to process


## Step 5: Move your followers

⚠️ **Warning:** This step is irreversible and may have a cooldown period!

### On your old instance

1. Go to your old instance's account settings
2. Look for "Move to a different account" or similar option
3. Enter your new Bonfire account address: `@yourusername@bonfire-instance.com`
4. **Read all warnings carefully**
5. Enter your password to confirm the move

### What happens next:

- Your old account should be marked as moved (a "This account has moved" notice may appear on your old profile, otherwise you can edit your bio with a link to your new profile)
- Your followers will receive a notification about your new account
- Followers running compatible software will automatically re-follow your new Bonfire profile
- Your old account may be restricted (no new posts, followers, etc.)

### If your old instance doesn't support moves:
- Manually announce your move in a final post
- Pin the announcement to your profile
- Ask followers to follow your new Bonfire account
- Consider keeping the old account as a redirect


## Step 6: Clean up your old account

### Option A: Keep as redirect (Recommended)
- Leave your account as-is to to point visitors to your new account (you can update your bio with a notice)
- This means your old posts and activities are still accessible
- No further action needed

### Option B: Delete your old account
⚠️ **Only do this if you're absolutely sure!**

1. Wait at least a week after moving to ensure followers have migrated
2. Follow your old instance's account deletion process
3. **This is usually permanent and irreversible**
4. Your username *may* become available for others to use


## Troubleshooting

### My followers didn't transfer
- **Check if your old instance supports moves** - Some instances may not support ActivityPub moves
- **Wait 48-72 hours** - Federation can be slow between instances
- **Manual solution:** Make an announcement post asking followers to follow your new Bonfire account

### Import failed on Bonfire
- **Check the progress** and results by clicking on Settings -> Import -> Import History
- **Check file format** - Ensure CSV files are properly formatted
- **File size limits** - Very large lists may need to be split into smaller files
- **Unsupported data** - Some instance-specific data may not be importable

### Can't set up aliases
- **Federation issues** - Ensure both instances can communicate with each other
- **Account verification** - Double-check that account addresses are correct
- **Software limitations** - Your old instance may not support aliasing

### Move option not available
- **Aliases not set up** - Both accounts must have each other as aliases (if supported)
- **Cooldown period** - You may need to wait if you've moved recently
- **Instance restrictions** - Check with your old instance's admin

### Features work differently on Bonfire
- **Lists become circles** - Recreate your lists as Bonfire circles with enhanced privacy controls
- **Different privacy model** - Bonfire's boundaries system may work differently than your old instance
- **New interaction options** - Explore Bonfire's unique features like circles and boundaries

---

### Welcome to Bonfire!

- Explore the [Bonfire user guides](user-guides.md) to learn about unique features
- Join community discussions to connect with other users
- Set up circles to organize your social experience
- Configure your boundaries for a personalized, safe social environment

