<!--
SPDX-FileCopyrightText: 2025 Bonfire Networks <https://bonfirenetworks.org/contact/>

SPDX-License-Identifier: AGPL-3.0-only
SPDX-License-Identifier: CC0-1.0
-->

# Create a new extension
    
Extensions in Bonfire are powerful tools that allow you to extend the functionality and features of your application.
This guide is perfect for developers who are looking to contribute new features or capabilities to the Bonfire ecosystem.
By the end of this page, you should have a solid understanding of how to develop and integrate a new extension in Bonfire, leveraging its modular architecture.


## Create your Bonfire extension

1. To start building your own extension, you can utilise our custom mix generator task. Simply navigate to the Bonfire app root folder in your terminal and type:
        
```
just mix bonfire.extension.new *your_extension_name*
```

This command creates a new directory in `./extensions` named `*your_extension_name*`, complete with all the necessary files and scaffolding.

2. Add your extension to `./config/current_flavour/deps.path` (on a new line, it should look similar to `your_extension_name = "extensions/your_extension_name"`) to enable it locally.

3. Once your new extension is set up, you're ready to dive into coding. Consider these possible steps to enhance your extension:

- Implement extension-specific fake functions for testing purposes.
- Create extension-specific [database migrations](https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html#module-migrations).
- Add any dependencies you need to deps.git and/or deps.hex.
- If your extension includes new pages, you need to link them in the main router. 

> #### Info {: .info}
> Bonfire's Phoenix router module is found in the `bonfire` extension. Refer to the [Routing](/docs/building/routing.md) page to learn how to add new routes.


4. After coding your initial features, create an empty repository on your preferred Git platform. Then, commit and push your local changes to make your work accessible and open for collaboration:

```
git add .
git commit -m "light my fire"
git branch -M main
git remote add origin [your-remote-repository-url]
git push -u origin main
```

5. When you're ready for other people upstream to use your extension, add it to `./config/deps.git` (including the branch name).

And just like that, you've successfully created and prepared your first Bonfire extension and shared with the community 🔥
