# Bonfire.UI.Boundaries

A template for creating custom extensions for [Bonfire](https://bonfire.cafe/)

## How to use it
- Clone the repository on your `/extensions` folder
```
cd extensions
git clone https://github.com/bonfire-networks/bonfire_ui_boundaries.git {your-extension-name-here}
cd {your-extension-name-here} 
```
- Rename all the modules names to match your extension name:
    - Find & replace Bonfire.UI.Boundaries -> Bonfire.YourExtensionName 
    - Find & replace bonfire_ui_boundaries -> bonfire_your_extension_name
- Rename the `bonfire_ui_boundaries.exs` config file to match your extension name `bonfire_your_extension_name.exs`
- Add paths to the router if you need it. If you add paths you will need to include the route module on [bonfire-app router module](https://github.com/bonfire-networks/bonfire-app/blob/main/lib/web/router.ex#L51) 
- Add extension specific Fake functions
- Add extension specific migrations
- Add extension deps to deps.git and/or deps.hex 
- Delete the bonfire extension template git history and initiate a new .git 
    ```
    rm -rf .git
    git init    
    ```
- Create your empty extension repository on your preferred platform
- Push your local changes
    ```
      git add .
      git commit -m "first commit"
      git branch -M main
      git remote add origin {your-remote-repository}
      git push -u origin main
    ```
- Add the extension on your bonfire deps.path to include it in your local development
- Add `use_if_enabled(Bonfire.UI.Boundaries.Routes)` in your app's `Router` module
- Add the extension on deps.git also (specifying the branch name) to allow others that do not have it in their fork to use it
- Write a meaningful readme
- TADA 🔥!

### Add your navigation

> **Warning**
> The following pattern is likely to change in the coming period.

Each extension can specify it's own navbar in a quite flexible way, leveraging on 2 macro: `declare_extension` and `declare_nav_link`.


- On your extension homepage call the `declare_extension` macro, specifying the extension name, its icon (that will be mostly used to list the extension with the other active ones) and the default_nav.

```
declare_extension(
      "ExtensionTemplate",
      icon: "bi:app",
      default_nav: [
        Bonfire.UI.Boundaries.HomeLive,
        Bonfire.UI.Boundaries.AboutLive
      ])
```

- The views you will include in the `default_nav` section, will be the ones that will be shown on the navigation sidebar. 

- The last step is to call `declare_nav_link` on each of those view/components already specified in declare_extension. 

```
declare_nav_link(l("About"),
    page: "About",
    href: "/bonfire_ui_boundaries/about",
    icon: "typcn:info-large"
  )
```


## Copyright and License

Copyright (c) 2020 Bonfire, VoxPublica, and CommonsPub Contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with this program.  If not, see <https://www.gnu.org/licenses/>.
