## Core Principles

- Consent-based coding, always think and plan, then check assumptions and present your solution, and only then can you help implementing.
- Write clean, concise, functional code using small, focused functions.
- **Explicit Over Implicit**: Prefer clarity over magic.
- **Single Responsibility**: Each module, component, and function should do one thing well.
- **Easy to Change**: Design for maintainability and future change.
- **YAGNI**: Don't build features until they're needed.

## Project Structure

- This is a modular multi-repo web application written in Elixir using Phoenix and Surface web frameworks.
- Bonfire is *modular*, with *extensions as mix dependencies* which are typically included as path deps during dev, so when looking for a component or module like `<Bonfire.UI.Me.ProfileLinkLive.render> lib/components/profile/links/profile_link_live.sface:1 (bonfire_ui_me)` you should look first in `extensions/bonfire_ui_me/lib/components/profile/links/profile_link_live.sface`
- When you can't guess the correct path, look first in `lib` and `extensions/*/lib` and `forks/*/lib`, and if not then in `deps/*/lib` - DO NOT grep without specifying a path. For frontend code filter by *.heex, *.sface, *.ex. For backend code filter by *.ex, *.exs.
- Dependencies are usually defined in files such as `deps.hex`, `deps.git`, and `deps.local` instead of all being listed in `mix.exs`
- **Extensions are cloned in `extensions/`**: Modular components of the system.
- **Libraries that are being modified are cloned in `forks/`**
- **Data schemas in `bonfire_data_*` extensions**: For data persistence and schemas.
- **Separation of Core and UI**: Keep business logic in core extensions separate from UI components in UI extensions (in `bonfire_ui_*` extensions).
- **Cross-Cutting Infrastructure**: Place shared functionality or components in common extensions such as `bonfire_common` or `bonfire_ui_common`.
- **Feature-Based Organization**: Group related functionality by feature domain within non-UI extensions, while UI extensions use web framework conventions (components, views, controllers, etc.).

## Coding Style

- **Follow standard Elixir practices** and let `just mix format` take care of formatting (run before committing Elixir code).
- **Always assume the server is running on port 4000**
- **Use Tidewave MCP to: run SQL queries, run elixir code, introspect the logs and runtime, fetch doccumentation from hex docs, see all the ecto schemas, and much more**
- **Use one module per file** unless the module is only used internally by another module.
- **Use appropriate pipe operators**: Use standard `|>` for function chaining and `~>` from `Arrows` for handling error tuples.
- **Prefer using full module names or aliases** rather than imports.
- **Use descriptive variable and function names**: e.g., `user_signed_in?`, `calculate_total`.
- **Prefer higher-order functions and recursion** over imperative loops.

## Naming Conventions

- **Verb-First Functions**: Start function names with verbs (`create_user`, not `user_create`).
- **Singular/Plural Naming**: Use singular for DB tables and schema modules, plural for contexts.
- **LiveView Naming**: Use `ComponentLive` for reusable components and `ViewLive` for page views.
- **Extensions** follow `Bonfire.Extension` namespace pattern.
- **Otherwise follow Phoenix naming conventions** for contexts, schemas, and controllers.

## Error Handling

- **Use `Bonfire.Fail` for standardized error handling**: `raise(Bonfire.Fail, :not_found)`.
- **Embrace the "let it crash" philosophy**.
- **Railway-Oriented Programming**: Chain operations with `with` for elegant error handling:
    
    ```elixir
    with 
      {:ok, user} <- find_user(id),
      {:ok, updated} <- update_user(user, attrs) 
    do  
      {:ok, updated}
    end
    ```
    
- **Result Tuples**: Return tagged tuples like `{:ok, result}` or `{:error, reason}` for operations that can fail, unless the function name ends with `!`.
- **User-friendly error messages**: Implement proper error logging and user-friendly messages, using `assign_error` or `assign_flash` in the UI.

## Data Validation and Database

- **Use Ecto changesets** for data validation, even outside of database contexts.
- **Implement proper indexing** for performance.
- **Always** preload Ecto associations (in queries, contexts, or using `update_many` in components to avoid n+1) when they'll be accessed in UI, ie a message that needs to reference the `message.user.email`. Use our `proload` macro to join and preload associations on queries (e.g., `proload(query, activity: [reply_to: [author: [:profile, :account]]])`.
- `Ecto.Schema` fields always use the `:string` type, even for `:text`, columns, ie: `field :name, :string`
- By default, Ecto validations only run if a change for the given field exists and the change value is not nil, so such as option is never needed
- As such, `Ecto.Changeset.validate_number/2` DOES NOT SUPPORT the `:allow_nil` option
- You **must** use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- Fields which are set programatically, such as `user_id`, must not be listed in `cast` calls or similar for security purposes. Instead they must be explicitly set when creating the struct

## UI and Frontend

- **Use Surface UI framework (based on Phoenix LiveView)** for dynamic, real-time interactions.
- **Produce world-class responsive UI designs** using DaisyUI components and TailwindCSS, with a focus on usability, accessibility, progressive enhancement, simple aesthetics, and modern design principles
- **Localize user-facing strings** with our `l` macro which wraps gettext.
- **Accessibility**: Apply best practices such as **WCAG**.
- Implement **subtle micro-interactions** (e.g., button hover effects, and smooth transitions), using `Phoenix.LiveView.JS` where possible
- Ensure **clean typography, spacing, and layout balance** for a refined, premium look
- Focus on **delightful details** like hover effects, loading states, and smooth page transitions

## Testing

- **Add tests for all new functionality**.
- Include doctests for pure functions (even if that means making private functions public) and test suites focused on public context APIs or UI flows.
- **Use Faker** for test data creation and extensions' helper modules such as `Bonfire.Me.Fake.fake_user!`.
- **Arrange-Act-Assert**: Structure tests with clear setup, action, and verification phases.
- Use PhoenixTest for UI testing.

## Security

- **Security First**: Always consider security implications (CSRF, XSS, etc.).
- **Use strong parameters** in controllers (params validation).
- **Protect against common web vulnerabilities** (XSS, CSRF, SQL injection).

## Documentation and Quality

- Describe why, not what it does.
- **Document Public Functions**: Add `@doc` to all public functions.
- **Examples in Docs**: Include examples in documentation (as doctests when possible).
- **Cautious Refactoring**: Propose bug fixes or optimizations without changing behavior or unrelated code.
- **Comments**: Write comments only when information cannot be included in docs.

## Mix guidelines

- Prepend every mix action with `just`, eg. `just mix format` instead of `mix format`. You can read the `justfile` for a list of just commands.
- Read the docs and options before using tasks (by using `just mix help task_name`)
- To debug test failures, run tests in a specific file with `just test test/my_test.exs` or run all previously failed tests with `just test --failed`
- `just mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason

## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir supports `if/else` but **does NOT support `if/else if` or `if/elsif`. **Never use `else if` or `elseif` in Elixir**, **always** use `cond` or `case` for multiple conditionals.

  **Never do this (invalid)**:

      <%= if condition do %>
        ...
      <% else if other_condition %>
        ...
      <% end %>

  Instead **always** do this:

      <%= cond do %>
        <% condition -> %>
          ...
        <% condition2 -> %>
          ...
        <% true -> %>
          ...
      <% end %>

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc, you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- Use `with` for chaining operations that return `{:ok, _}` or `{:error, _}`
- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (for which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark (eg. `thing?`). Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## Phoenix HTML guidelines

- **Function Components**: Create or use function components (with `use Bonfire.UI.Common.Web, :stateless_component`) or stateful components (with `use Bonfire.UI.Common.Web, :stateful_component`) for reusable UI elements.
- Include components using:
  ```elixir
  <StatelessComponent module={maybe_component(Bonfire.UI.MyExtension.MyFunctionComponentLive, @__context__)} />
  ```
  or 
  ```elixir
  <StatefulComponent id="myid" module={maybe_component(Bonfire.UI.MyExtension.MyLiveComponentLive, @__context__)} />
  ```
- **Phoenix helpers**: Put `handle_event` functions in a shared `LiveHandler` module per extension to keep views and components DRY.
- Remember Phoenix router `scope` blocks include an optional alias which is prefixed for all routes within the scope. **Always** be mindful of this when creating routes within a scope to avoid duplicate module prefixes.
- Phoenix and Surface templates **always** use `~H` or `~S` or .heex or .sface files (known as HEEx), **never** use `~E`. Prefer using Surface with separate `.sface` files by default.
- **Always** use the imported `Phoenix.Component.form/1` and `Phoenix.Component.inputs_for/1` function to build forms. **Never** use `Phoenix.HTML.form_for` or `Phoenix.HTML.inputs_for` as they are outdated
- When building forms **always** use the already imported `Phoenix.Component.to_form/2` (`assign(socket, form: to_form(...))` and `<.form for={@form} id="msg-form">`), then access those forms in the template via `@form[:field]`
- **Always** add *UNIQUE* DOM IDs to key elements (like forms, buttons, etc) when writing templates, these IDs can later be used in tests (`<.form for={@form} id="signup-form">` or `<.li id={"item-#{id}"}>`)
- For "app wide" template imports, you can import/alias into the `Bonfire.UI.Common.Web`'s `html_helpers` block, so they will be available to all LiveViews, LiveComponent's, and all modules that do `use Bonfire.UI.Common.Web, :html` 
- **Never** use `<% Enum.each %>` or non-for comprehensions for generating template content, instead **always** use `<%= for item <- @collection do %>`
- HEEx HTML comments use `<%!-- comment --%>`. **Always** use this syntax for HEEx template comments. Surface HTML comments use `{!-- comment --}`. **Always** use this syntax for Surface template comments.
- HEEx and Surface allow interpolation via `{...}` instead of the outdated `<%= ... %>`. **Always** use the `{...}` syntax.

<!-- usage-rules-start -->
<!-- usage-rules-header -->
# Usage Rules

**IMPORTANT**: Consult these usage rules early and often when working with the packages listed below. 
Before attempting to use any of these packages or to discover if you should use them, review their usage rules to understand the correct patterns, conventions, and best practices.
<!-- usage-rules-header-end -->

<!-- igniter-start -->
## igniter usage
_A code generation and project patching framework_

[igniter usage rules](deps/igniter/usage-rules.md)
<!-- igniter-end -->
<!-- usage_rules-start -->
## usage_rules usage
_A dev tool for Elixir projects to gather LLM usage rules from dependencies_

[usage_rules usage rules](deps/usage_rules/usage-rules.md)
<!-- usage_rules-end -->
<!-- usage_rules:elixir-start -->
## usage_rules:elixir usage
[usage_rules:elixir usage rules](deps/usage_rules/usage-rules/elixir.md)
<!-- usage_rules:elixir-end -->
<!-- usage_rules:otp-start -->
## usage_rules:otp usage
[usage_rules:otp usage rules](deps/usage_rules/usage-rules/otp.md)
<!-- usage_rules:otp-end -->
<!-- activity_pub-start -->
## activity_pub usage
_activity_pub_

[activity_pub usage rules](deps/activity_pub/usage-rules.md)
<!-- activity_pub-end -->
<!-- bonfire_common-start -->
## bonfire_common usage
_bonfire_common_

[bonfire_common usage rules](deps/bonfire_common/usage-rules.md)
<!-- bonfire_common-end -->
<!-- bonfire_ui_common-start -->
## bonfire_ui_common usage
_bonfire_ui_common_

[bonfire_ui_common usage rules](deps/bonfire_ui_common/usage-rules.md)
<!-- bonfire_ui_common-end -->
<!-- bonfire_social-start -->
## bonfire_social usage
_bonfire_social_

[bonfire_social usage rules](deps/bonfire_social/usage-rules.md)
<!-- bonfire_social-end -->
<!-- bonfire_boundaries-start -->
## bonfire_boundaries usage
_bonfire_boundaries_

[bonfire_boundaries usage rules](deps/bonfire_boundaries/usage-rules.md)
<!-- bonfire_boundaries-end -->
<!-- bonfire_ui_boundaries-start -->
## bonfire_ui_boundaries usage
_bonfire_ui_boundaries_

[bonfire_ui_boundaries usage rules](deps/bonfire_ui_boundaries/usage-rules.md)
<!-- bonfire_ui_boundaries-end -->
<!-- bonfire_ui_me-start -->
## bonfire_ui_me usage
_bonfire_ui_me_

[bonfire_ui_me usage rules](deps/bonfire_ui_me/usage-rules.md)
<!-- bonfire_ui_me-end -->
<!-- usage-rules-end -->

## PhoenixTest

**IMPORTANT**: Consult this section early and often when working with tests.

PhoenixTest provides a unified way of writing feature tests -- regardless of whether you're testing LiveView pages or static pages.

It also handles navigation between LiveView and static pages seamlessly. So, you don't have to worry about what type of page you're visiting. Just write the tests from the user's perspective.

Thus, you can test a flow going from static to LiveView pages and back without having to worry about the underlying implementation.

This is a sample flow:

```
test "admin can create a user", %{conn: conn} do
  conn
  |> visit("/")
  |> click_link("Users")
  |> fill_in("Name", with: "Aragorn")
  |> choose("Ranger")
  |> assert_has(".user", text: "Aragorn")
end
```

## Usage
Now that we have all the setup out of the way, we can create tests like this:

`test/my_app_web/features/admin_can_create_user_test.exs`

```
defmodule MyAppWeb.AdminCanCreateUserTest do
  use MyAppWeb.FeatureCase, async: true

  test "admin can create user", %{conn: conn} do
    conn
    |> visit("/")
    |> click_link("Users")
    |> fill_in("Name", with: "Aragorn")
    |> fill_in("Email", with: "aragorn@dunedain.com")
    |> click_button("Create")
    |> assert_has(".user", text: "Aragorn")
  end
end
```

### Filling out forms
We can fill out forms by targetting their inputs, selects, etc. by label:

test "admin can create user", %{conn: conn} do
  conn
  |> visit("/")
  |> click_link("Users")
  |> fill_in("Name", with: "Aragorn")
  |> select("Elessar", from: "Aliases")
  |> choose("Human") # <- choose a radio option
  |> check("Ranger") # <- check a checkbox
  |> click_button("Create")
  |> assert_has(".user", text: "Aragorn")
end

copy
For more info, see fill_in/3, select/3, choose/3, check/2, uncheck/2.

Submitting forms without clicking a button
Once we've filled out a form, you can click a button with click_button/2 to submit the form. But sometimes you want to emulate what would happen by just pressing <Enter>.

For that case, you can use submit/1 to submit the form you just filled out.

session
|> fill_in("Name", with: "Aragorn")
|> check("Ranger")
|> submit()
copy
For more info, see submit/1.

Targeting which form to fill out
If you find yourself in a situation where you have multiple forms with the same labels (even when those labels point to different inputs), then you might have to scope your form-filling.

To do that, you can scope all of the form helpers using within/3:

session
|> within("#user-form", fn session ->
  session
  |> fill_in("Name", with: "Aragorn")
  |> check("Ranger")
  |> click_button("Create")
end)

Functions
assert_has(session, selector)
Assert helper to ensure an element with given CSS selector is present. eg. `assert_has(session, "div")` or `assert_has(session, "#my_div")`
assert_has(session, selector, opts)
Assert helper to ensure an element with given CSS selector and options. eg: `assert_has(session, "div", text: "my string")`
assert_path(session, path)
Assert helper to verify current request path. Takes an optional query_params map.
assert_path(session, path, opts)
Same as assert_path/2 but takes an optional query_params map.
check(session, label, opts \\ [exact: true])
Check a checkbox.
check(session, checkbox_selector, label, opts)
Like check/3 but allows you to specify the checkbox's CSS selector.
choose(session, label, opts \\ [exact: true])
Choose a radio button option.
choose(session, radio_selector, label, opts)
Like choose/3 but you can specify an input's selector (in addition to the label).
click_button(session, text)
Perfoms action defined by button with given text (using a substring match). The action is based on attributes present.
click_button(session, selector, text)
Performs action defined by button with CSS selector and text.
click_link(session, text)
Clicks a link with given text (using a substring match) and performs the action.
click_link(session, selector, text)
Clicks a link with given CSS selector and text and performs the action. selector to target the link.
fill_in(session, label, opts)
Fills text inputs and textareas, targetting the elements by their labels.
fill_in(session, input_selector, label, opts)
Like fill_in/3 but you can specify an input's selector (in addition to the label).
open_browser(session)
Open the default browser to display current HTML of session.
refute_has(session, selector)
Opposite of assert_has/2 helper. Verifies that element with given CSS selector is not present.
refute_has(session, selector, opts)
Opposite of assert_has/3 helper. Verifies that element with given CSS selector and text is not present.
refute_path(session, path)
Verifies current request path is NOT the one provided. Takes an optional query_params map for more specificity.
refute_path(session, path, opts)
Same as refute_path/2 but takes an optional query_params for more specific refutation.
select(session, option, opts)
Selects an option from a select dropdown.
select(session, select_selector, option, opts)
Like select/3 but you can specify a select's CSS selector (in addition to the label).
submit(session)
Helper to submit a pre-filled form without clicking a button (see fill_in/3, select/3, choose/3, etc. for how to fill a form.)
uncheck(session, label, opts \\ [exact: true])
Uncheck a checkbox.
uncheck(session, checkbox_selector, label, opts)
Like uncheck/3 but allows you to specify the checkbox's CSS selector.
unwrap(session, fun)
Escape hatch to give users access to underlying "native" data structure.
upload(session, label, path, opts \\ [exact: true])
Upload a file.
upload(session, input_selector, label, path, opts)
Like upload/4 but you can specify an input's selector (in addition to the label).
visit(conn, path)
Entrypoint to create a session.
within(session, selector, fun)
Helpers to scope filling out form within a given selector. Use this if you have more than one form on a page with similar labels.


## Example from the Bonfire codebase

  setup do
    account = fake_account!()
    me = fake_user!(account)

    conn = conn(user: me, account: account)

    {:ok, conn: conn, account: account, me: me}
  end
  
  test "I can add a circle to a preset and specify the role", %{conn: conn, me: me} do
    {:ok, circle} = Bonfire.Boundaries.Circles.create(me, %{named: %{name: "bestie"}})

    conn
    |> visit("/boundaries/acls")
    |> click_button("[data-role=open_modal]", "New preset")
    |> fill_in("Enter a name for the boundary preset", with: "friends")
    |> click_button("[data-role=new_acl_submit]", "Create")
    |> assert_has("[role=banner]", text: "friends")
    |> click_button("[data-role=add-circle-to-acl]", "bestie")
    |> assert_has("#edit_grants", text: "bestie")
    |> choose("Edit")
    |> assert_has("[data-role=toggle_role]", text: "Edit")
  end