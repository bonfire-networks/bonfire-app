# Setting Up Your Code of Conduct, Privacy Policy & Community Rules

When you start a new instance, one of the first things to do (ideally before you invite anyone) is tell people what to expect: how members should treat each other, what content is welcome, and what you do with their data.

Bonfire gives you three places for this:

| What | Where people see it | Where you edit it |
|---|---|---|
| **Code of Conduct** (or Terms of Use) | `/conduct` | Instance settings → **Terms / Policies** |
| **Privacy Policy** | `/privacy` | Instance settings → **Terms / Policies** |
| **Community Rules** (a quick checklist of what's allowed) | `/rules`, and at sign-up | Instance settings → **Community Rules** |

You can also add an **Impressum** (legal notice) and an extra **consent checkbox** for sign-up from the same Terms / Policies page.

> You need to be an instance admin to change any of these.

## Before you start

Write your texts in a document first (or reuse an existing one). You don't have to start from scratch. Good starting points:

- The [Bonfire project's Code of Conduct](https://bonfirenetworks.org/conduct) and [Privacy Policy](https://bonfirenetworks.org/privacy)
- Codes of conduct from other fediverse communities that share your values

Whatever you borrow, adapt it: put in your instance's name, who runs it, how to contact the moderators, and anything specific to your community.

## 1. Add your Code of Conduct and Privacy Policy

1. Open **Settings**, then switch to the **Instance** settings (or go to `/settings/instance/terms` directly).
2. In the sidebar, under **Pages**, click **Terms / Policies**.
3. Next to **Terms of Use / Code of Conduct**, click **Expand** and paste your text.
4. Next to **Privacy Policy**, click **Expand** and paste your text.
5. Click **Save**.

### Formatting

Both fields accept **Markdown**, so you can use headings (`## Heading`), lists, **bold** text and links (`[link text](https://example.org)`).

### Keeping the text somewhere else

Instead of pasting the text, you can paste the **web address of a Markdown document**, for example a file in a git repository or on your community's website. Bonfire will fetch it and show its contents. This is handy if several instances share the same policy, or if you want to keep a history of changes.

The address should point to the raw Markdown file, not to a web page that displays it.

## 2. Choose your Community Rules

Community Rules are a short, scannable list that sits next to your Code of Conduct. Instead of writing everything out, you tick the rules that apply and, for some of them, say how they apply.

1. In the instance settings sidebar, open **Community Rules** (listed with your other extensions), or go to `/settings/instance/bonfire_community_rules`.
2. Go through the groups (**Behavior** and **Content**) and tick the rules that apply to your instance. For example:
    - *Civility*: be respectful, no personal attacks…
    - *Harassment and personal safety*: no harassment, no doxxing, no block evasion…
    - *Content warnings*: content warnings for sexual content, alt text for images…
    - *Spam and advertising*, *AI-generated media*, *adult content*, and more
3. Some rules let you choose **how** they apply rather than just yes or no:
    - **Allowed**
    - **Not allowed**
    - **Allowed with labeling / disclosure** (e.g. AI-generated media is fine if marked as such)
    - **Approval required** (e.g. commercial advertising only after asking the moderators)
4. Missing something? Use **Add custom rule** in any group to write your own.

Changes are saved as you go. Check the **Selected rules** summary to see how the final list will read.

> If the Community Rules page isn't in your settings, the Community Rules extension may be turned off on your instance. You can enable it from the extensions settings (see [Extensions](./extensions.md)).

## 3. Optional: Impressum and extra sign-up consent

On the same **Terms / Policies** page you'll also find:

- **Impressum**: a legal notice identifying who runs the site. This is required in some countries (e.g. Germany and Austria). If you leave it empty, no Impressum link is shown.
- **Consent checkbox**: turn this on to add an extra checkbox people must tick when signing up. Use the default text, or write your own (for example, "I confirm I am over 16" or "I understand this instance is for members of our co-op").

Remember to click **Save**.

## Where members will see all this

Once saved, your texts show up across the instance:

- **At sign-up**: new members must tick *"I have read the Code of Conduct"* (and the Privacy Policy, if you added one) before creating their profile. If you've chosen Community Rules, they're shown on the sign-up page too.
- **In the navigation**: links to the Code of Conduct and Privacy pages appear in the sidebar, the footer, and the menu for logged-out visitors.
- **In the "getting started" checklist**: new members are invited to read your community rules (or your Code of Conduct, if you haven't chosen any rules).

If you haven't added a Code of Conduct, members will see a message saying the instance hasn't added one yet, with a link to the Bonfire project's Code of Conduct as a reference. Don't leave it like that for long.
