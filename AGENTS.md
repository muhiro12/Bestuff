This document defines the minimum coding and content standards for Agents in this repository.

# AGENTS.md

## Coding Guidelines for Codex Agents

These guidelines describe the expectations for Agents contributing to the Codex project within this repository.

## Swift Code Guidelines

### Follow SwiftLint rules

All Swift code must comply with the SwiftLint rules defined in the project.

### Avoid abbreviated variable names

Do not use unclear abbreviations such as `res`, `img`, or `btn`.
Use descriptive and explicit names like `result`, `image`, or `button`.

### Use `.init(...)` when the return type is explicitly known

In contexts where the return type is clear (for example, function return values or computed properties), use `.init(...)` for initialization and rely on the surrounding explicit type information.

#### Preferred

```swift
func makeUser() -> User {
    .init(name: "Bob") // ✅ Explicit return type supplies context
}
```

#### Not preferred

```swift
let user = .init(name: "Carol") // ❌ Missing explicit type context; prefer `let user: User = .init(name: "Carol")`
```

### Multiline control-flow and trailing-closure formatting

Avoid single-line bodies for **any** control-flow statement (`if`, `guard`, `while`, `switch`, etc.) or trailing closures.
Always place the body on its own indented line between braces to improve readability and make diffs cleaner.

#### Preferred

```swift
guard let currentUser = optionalUser else {
    return
}

if isDebugMode {
    logger.debug("Entering debug state")
}

tasks.filter {
    $0.isCompleted
}
```

#### Not preferred

```swift
guard let currentUser = optionalUser else { return }
if isDebugMode { logger.debug("Entering debug state") }
tasks.filter { $0.isCompleted }
```

### View naming conventions

Name view structs according to the primary full-screen container and avoid conflicts with SwiftUI built-in types.
Use a `*Screen` suffix for all top-level screens to keep naming consistent.

- Use `FooNavigationScreen` when the root is a `NavigationStack` or `NavigationSplitView`.
- Use `FooListScreen` when the entire screen is a `List` or a scrollable list equivalent.
- Use `FooFormScreen` when a `Form` is the main content.
- Use `FooTabBarScreen` when the screen is organized with a tab bar.
- Avoid reusing names of SwiftUI types such as `NavigationView`; choose names like `FooNavigationScreen` instead.

## Markdown Guidelines

### Follow markdownlint rules for Markdown files

All Markdown documents must conform to the rules defined at:
https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

## Project-wide Conventions

### Use English for naming and comments

Use English for:

- Branch names (e.g., `feature/add-intent-support`, `bugfix/crash-on-startup`)
- Code comments
- Documentation and identifiers (variables, methods, etc.)

Avoid using Japanese or other non-English languages in code unless strictly necessary (e.g., legal compliance, UI text localization).

### Bestuff-specific Guardrails

- No unfounded product rankings or comparative claims.
- Disclose sponsorships or affiliate relationships clearly (for example, include "#ad").
- Make subjective ratings explicit (for example, "Personal rating: 4.5/5").
