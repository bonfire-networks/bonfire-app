# What is a Bonfire extension

Extensions in Bonfire are collections of code that introduce new features and enhance the platform's functionality, or explore a different user experience for an existing feature.

They can range from adding entirely new pages, such as [bonfire_invite_links]() which lets admins create and share invites with usage limit and expiration date, to implementing specific components or widgets.
An example is [bonfire_editor_milkdown](), which integrates a markdown-first editor for publishing activities.

Extensions are versatile, they can implement their own schema, database, logic, and components, or they can leverage existing fields, context functions, and UI components, or more commonly, a combination of both.

## Using extensions

In order to make changes to extensions, you need to clone them locally. As you may imagine, we have a `just` command for that.

```
just dep-clone-local **[extension name]** **[extension url]**
```

This command (eg. `just dep-clone-local bonfire_ui_social https://github.com/bonfire-app/bonfire_ui_social`) will create a local copy of the extension in `./extensions/bonfire_ui_social`.

If the extension is enabled locally, you will see an entry in `config/deps.flavour.path` with the path to the local extension: 

```
bonfire_ui_social = "extensions/bonfire_ui_social"
```

If you want to disable the extension, you can remove the entry from `config/deps.flavour.path`

> #### Info {: .info}
>
> `config/deps.flavour.path` is a symlink of the file `flavours/[flavour]/deps.flavour.path`. Ensure this file exist in the flavour you are working on, or create one to begin use your extensions locally.


When the extension is enabled, Bonfire will use the code in `extensions/` instead of the one in `deps/`.

We will dive more into the creation and the lifecycle of extensions in the next sections.

## Extension helpers

Given Bonfire modularity, you will likely find yourself combining functions from several extensions when using the framework.
A significant portion of its codebase is included in extensions, each serving specific purposes.
Moreover, extensions often utilise code from other extensions.
For instance, [bonfire_common](https://github.com/bonfire-networks/bonfire_common) and [bonfire_ui_common](https://github.com/bonfire-networks/bonfire_ui_common) provide a suite of helpers to ease a good amount of tasks.

When using extensions functions, we need a way to ensure the app will not break if the extension is not enabled.

Bonfire provides a few built-in components that allows users to optionally inject components or functions from different extensions.

`Bonfire.Common.Utils.maybe_apply`

- Helpers for calling hypothetical functions in other modules. Returns the result of calling a function with the given arguments, or the result of fallback function if the primary function is not defined (by default just logging an error message).

```elixir
Bonfire.Common.Utils.maybe_apply(Bonfire.Social.Graph, :maybe_applications, [],
          fallback_return: []
        )
```

`Bonfire.UI.Common.Modular.StatefulComponent`

- A built-in component that allows users to optionally inject dynamic live components into a Surface template.
  Based on `Surface.Components.Dynamic.LiveComponent` to which it adds the ability to check if a module is enabled and even to swap it out for another in settings.

```elixir
<StatefulComponent
    :if={current_user(@__context__)}
    module={maybe_component(Bonfire.Boundaries.Web.MyCirclesLive, @__context__)}
    id="circles"
scope={@scope}
/>
```

`Bonfire.UI.Common.Modular.StatelessComponent`

- A built-in component that allows users to optionally inject dynamic functional components into a Surface template.
  Based on `Surface.Components.Dynamic.Component` to which it adds the ability to check if a module is enabled and even to swap it out for another in settings.

```elixir
<StatelessComponent
    selected_tab={@selected_tab}
    module={maybe_component(Bonfire.UI.Me.SettingsViewsLive.InstanceSummaryLive, @__context__)}
/>
```

