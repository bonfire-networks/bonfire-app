# Admin Tools

Instance admins have access to advanced tools for managing users, extensions, and the overall health of the Bonfire instance.

## User Management

- View, manage, or remove user accounts from the **Instance members** section.
- Promote users to moderator or admin roles.
- Manage invites and registration settings.

## Instance Settings

- Edit general configuration, default user preferences, and resource usage limits.
- In **General Config**, you can set:
    - Instance name, icon, description, etc
    - Set federation and privacy options, such as enabling/disabling federation, hiding member counts, and limiting sign-ups.
    - Resource limits (max file upload size, max number of profiles per account, etc)
- In **Default user preferences** you can set default values for new users (such as language, theme, notification settings, and more).  
  Users can override these defaults in their own preferences and profile settings.
- **Terms** such as moderation policies and code of conduct

## Circles, Roles & Boundaries

- Organize admins, moderators, and more into circles.
- Assign roles and permissions for each circle or user.
- Manage and import/export blocklists.

## Advanced Monitoring and Maintenance

- Access real-time metrics and logs via the **LiveDashboard** at `/admin/system/`.
- Monitor queued jobs (e.g. federation, media processing) by clickig on **Oban** in the LiveDashboard.
<!-- - Browse and edit database data via **LiveAdmin** at `/admin/system/data`. -->
- Profile performance with **Orion** at `/admin/system/orion`.
- Use **Web Observer** for alternative metrics at `/admin/system/wobserver`.

## Tips

- Keep your instance updated for security and new features.
- Regularly review user and moderation activity.
- Use admin tools to support your community’s needs.

---

For setup and deployment, see [Running Your Own Instance](./running-your-own.md).  
For moderation, see [Moderator Tools](./moderator-tools.md).
