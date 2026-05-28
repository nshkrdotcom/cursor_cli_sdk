# Synchronous Runs

`CursorCliSdk.run/2` executes a prompt and returns final assistant text.

```elixir
{:ok, text} =
  CursorCliSdk.run(
    "Reply with exactly: OK",
    CursorCliSdk.Options.new!(permission_mode: :bypass)
  )
```

Use `run/2` for simple prompt/response workflows where intermediate events are
not needed.

## Result Selection

`run/2` prefers the final `ResultEvent.result` when Cursor emits one. If the
stream has assistant deltas but no final result text, it accumulates assistant
deltas. Fatal error events return `{:error, %CursorCliSdk.Error{}}`.

## When to Prefer Streaming

Prefer `execute/2` when you need:

- tool-use telemetry
- init metadata such as session id or model
- usage and duration
- thinking/progress events
- stderr diagnostics
- final-vs-delta distinction

## Timeout

The same `Options.timeout_ms` setting applies:

```elixir
CursorCliSdk.run("Long task", CursorCliSdk.Options.new!(timeout_ms: 900_000))
```
