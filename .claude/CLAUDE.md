# Project instructions

**See [AGENTS.md](../AGENTS.md) for the core principles, project structure, coding style, naming, error handling, data/database, UI, testing, security, and Elixir/Phoenix guidelines.** Those apply here in full and supersede anything else.

This file only adds usage rules and library references.

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
