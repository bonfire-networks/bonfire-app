## Core Principles

- **Extension-Based Modularity**: Organize code into specific extension types (common, data, UI) that can be composed.
- Write clean, concise, functional code using small, focused functions.
- **Explicit Over Implicit**: Prefer clarity over magic.
- **Single Responsibility**: Each module and function should do one thing well.
- **Easy to Change**: Design for maintainability and future change.
- **YAGNI**: Don't build features until they're needed.

## Project Structure

- **Extensions in `extensions/` or `deps/`**: Modular components of the system.
- **Data schemas in `bonfire_data_*` extensions**: For data persistence and schemas.
- **Separation of Core and UI**: Keep business logic in core extensions separate from UI components in UI extensions (in `bonfire_ui_*` extensions).
- **Cross-Cutting Infrastructure**: Place shared functionality or components in common extensions such as `bonfire_common` or `bonfire_ui_common`.
- **Feature-Based Organization**: Group related functionality by feature domain within non-UI extensions, while UI extensions use web framework conventions (components, views, controllers, etc.).

## Coding Style

- **Follow standard Elixir practices** and let `mix format` take care of formatting (run before committing code).
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
- **Avoid N+1 Queries**: Use our `proload` macro to join and preload associations (e.g., `proload(query, activity: [reply_to: [author: [:profile, :account]]])`.
- **Implement proper indexing** for performance.

## UI and Frontend

- **Use Surface UI framework (based on Phoenix LiveView)** for dynamic, real-time interactions.
- **Implement responsive design** with DaisyUI components and Tailwind CSS.
- **Function Components**: Create or use function components (with `use Bonfire.UI.Common.Web, :stateless_component`) or stateful components (with `use Bonfire.UI.Common.Web, :stateful_component`) for reusable UI elements.
- Include components using:
  ```elixir
  <StatelessComponent module={maybe_component(Bonfire.UI.MyExtension.MyFunctionComponentLive, @__context__)} />
  ```
  or 
  ```elixir
  <StatefulComponent id="myid" module={maybe_component(Bonfire.UI.MyExtension.MyLiveComponentLive, @__context__)} />
  ```
- **Localize user-facing strings** with our `l` macro which wraps gettext.
- **Phoenix helpers**: Put `handle_event` functions in a shared `LiveHandler` module per extension to keep views and components DRY.
- **Accessibility**: Apply best practices such as **WCAG**.

## Testing

- **Add tests for all new functionality**.
- Include doctests for pure functions (even if that means making private functions public) and test suites focused on public context APIs or UI flows.
- **Use Faker** for test data creation and extensions' helper modules such as `Bonfire.Me.Fake.fake_user!`.
- **Arrange-Act-Assert**: Structure tests with clear setup, action, and verification phases.

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