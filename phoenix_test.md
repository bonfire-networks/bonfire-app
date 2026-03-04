# PhoenixTest

PhoenixTest provides a unified way of writing feature tests -- regardless of whether you're testing LiveView pages or static pages.

It also handles navigation between LiveView and static pages seamlessly. So, you don't have to worry about what type of page you're visiting. Just write the tests from the user's perspective.

Thus, you can test a flow going from static to LiveView pages and back without having to worry about the underlying implementation.

This is a sample flow:

test "admin can create a user", %{conn: conn} do
  conn
  |> visit("/")
  |> click_link("Users")
  |> fill_in("Name", with: "Aragorn")
  |> choose("Ranger")
  |> assert_has(".user", text: "Aragorn")
end


Usage
Now that we have all the setup out of the way, we can create tests like this:

# test/my_app_web/features/admin_can_create_user_test.exs

defmodule MyAppWeb.AdminCanCreateUserTest do
  use MyAppWeb.ConnCase, async: true

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
copy
Filling out forms
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