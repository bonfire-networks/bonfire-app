# How to Create Effective Usage Rules for LLM-Assisted Development

This guide explains best practices for creating `usage-rules.md` files that help LLMs understand and correctly use your library or framework without hallucinating incorrect patterns.

## Core Principles

### 1. Start with Clear Concepts
Begin your usage rules by explaining the fundamental concepts and mental models:
- What problem does your library solve?
- What are the core abstractions?
- How do the pieces fit together?

```markdown
## Core Concepts

### [Main Abstraction]
[Brief explanation of what it is and why it exists]

### [Supporting Concept]
[How it relates to the main abstraction]
```

### 2. Show, Don't Just Tell
Every concept should be immediately followed by a practical example:

```markdown
### Creating Activities

Use the Activities module to create and manage activities:

```elixir
# Create an activity for any verb
{:ok, activity} = Activities.create(user, :post, post)
{:ok, activity} = Activities.create(user, :follow, target_user)
```
```

### 3. Progress from Simple to Complex
Structure your examples to build understanding incrementally:
1. Basic usage (minimal parameters)
2. Common options
3. Advanced patterns
4. Edge cases

## Essential Sections

### Module Setup
Always start with how to properly set up and use your modules:

```markdown
## Core Module Setup

Always use the provided module templates for consistency:

```elixir
# For general modules
use Bonfire.Common

# For Ecto schemas  
use Bonfire.Common.Schema
```
```

### API Reference with Context
Don't just list functions - explain when and why to use them:

```markdown
### Safe Data Extraction

Use the `e/3` macro for safe nested data access with fallbacks:

```elixir
# Extract nested values safely
e(user, :profile, :name, "Anonymous")

# Works with maps, structs, tuples, and Access behavior
settings = e(socket, :assigns, :current_user, :settings, %{})
```
```

### Error Handling Patterns
Show how to handle both success and failure cases:

```markdown
## Error Handling

### Validation Errors

Changeset errors are automatically promoted to epic errors:

```elixir
case Posts.create(user, attrs) do
  {:ok, post} ->
    {:ok, Epic.assign(epic, :post, post)}
    
  {:error, changeset} ->
    {:error, Epic.add_error(epic, act: :create_post, changeset: changeset)}
end
```
```

### Anti-Patterns Section
Explicitly show what NOT to do and provide the correct alternative:

```markdown
## Common Anti-Patterns to Avoid

### ❌ Direct Map Access
```elixir
# Bad
user.profile.name  # Can raise if nil

# Good  
e(user, :profile, :name, "Anonymous")
```
```

## Writing Style Guidelines

### Be Concise but Complete
- Use bullet points for lists
- Keep explanations focused
- Include all necessary context
- Remove redundant information

### Use Consistent Formatting
- Code blocks with language hints
- Clear section headers
- Visual markers (✅ ❌) for do's and don'ts
- Proper indentation and spacing

### Include Real-World Patterns
Show complete workflows, not just isolated functions:

```markdown
## Complete Epic Patterns

### CRUD Operations

```elixir
# Create epic
config :my_app, :epics,
  create_article: [
    MyApp.Acts.ValidateArticleAct,
    MyApp.Acts.PrepareArticleAct,
    {Bonfire.Ecto.Acts.Begin, []},
    {Bonfire.Ecto.Acts.Work, []},
    {Bonfire.Ecto.Acts.Commit, []},
    MyApp.Acts.IndexArticleAct
  ]
```
```

## Structure Template

1. **Title and Introduction** - What the library does
2. **Core Concepts** - Mental models and abstractions
3. **Setup/Installation** - How to get started
4. **Basic Usage** - Simple, common patterns
5. **API Patterns** - Main functions with examples
6. **Advanced Patterns** - Complex scenarios
7. **Error Handling** - How to handle failures
8. **Testing** - How to test code using the library
9. **Performance** - Optimization tips
10. **Best Practices** - Recommended patterns
11. **Anti-Patterns** - What to avoid
12. **Debugging** - Troubleshooting tips
13. **Integration** - How to use with other libraries

## LLM-Specific Considerations

### Prevent Hallucinations
- Show exact import statements
- Include complete function signatures
- Specify return types and error tuples
- Document all required parameters

### Provide Context Clues
Help LLMs understand when to use your library:

```markdown
# Use this tool when you need to retrieve and analyze web content
# IMPORTANT: If an MCP-provided web fetch tool is available, prefer using that
```

### Include Module Paths
Always show the full module path in examples:

```elixir
defmodule MyApp.Acts.ProcessDataAct do
  use Bonfire.Epics.Act
  import Bonfire.Ecto
```

### Document Integration Points
Show how your library connects with others:

```markdown
## Integration with Other Extensions

### Use Acts from Other Extensions

```elixir
config :my_app, :epics,
  create_social_post: [
    MyApp.Acts.ValidateContentAct,
    Bonfire.Social.Acts.PostContentsAct,
    Bonfire.Social.Acts.FederateAct
  ]
```
```

## Testing Your Usage Rules

### Completeness Check
- Can someone implement basic features using only your rules?
- Are all public APIs documented with examples?
- Do examples compile and run?

### Clarity Check
- Would a developer new to your library understand the concepts?
- Are examples self-contained?
- Is the progression logical?

### LLM Compatibility
- Test with an LLM to see if it generates correct code
- Check for common hallucination patterns
- Ensure the LLM uses your patterns, not generic ones

## Example Opening

Here's an effective opening for a usage-rules.md file:

```markdown
# MyLibrary Usage Rules

MyLibrary provides [specific functionality] for [target use case]. These rules ensure [key benefit] while avoiding [common pitfall].

## Core Concepts

### [Main Concept]
[One paragraph explanation]

```elixir
# Simple example showing the concept
```

### Quick Start

```elixir
# Minimal working example
defmodule MyApp.Example do
  use MyLibrary
  
  def my_function(data) do
    MyLibrary.process(data)
  end
end
```
```

## Maintenance

- Update usage rules when APIs change
- Add new patterns as they emerge
- Remove deprecated patterns
- Include version compatibility notes

Remember: Good usage rules make the difference between an LLM that hallucinates generic patterns and one that correctly uses your specific APIs and conventions.