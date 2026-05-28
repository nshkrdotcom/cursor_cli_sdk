# Getting Started

`CursorCliSdk` runs the Cursor Agent CLI (`agent`) from Elixir. The SDK expects
the CLI to be installed and authenticated before live commands run.

## Prerequisites

- Elixir 1.18 or later
- Cursor Agent CLI available as `agent` on `PATH`, or an explicit `cli_command`
- Cursor authentication through CLI login or a caller-provided `CURSOR_API_KEY`

## Install

```elixir
def deps do
  [
    {:cursor_cli_sdk, "~> 0.1.0"}
  ]
end
```

## Stream Events

```elixir
options = CursorCliSdk.Options.new!(permission_mode: :bypass)

CursorCliSdk.execute("Reply with exactly: OK", options)
|> Enum.each(fn
  %CursorCliSdk.Types.MessageEvent{role: :assistant, content: text} ->
    IO.write(text)

  _event ->
    :ok
end)
```

`execute/2` returns a lazy enumerable. The subprocess is started when the stream
is enumerated and is closed when the stream finishes.

## One-Shot Text

```elixir
{:ok, text} =
  CursorCliSdk.run(
    "Reply with exactly: OK",
    CursorCliSdk.Options.new!(permission_mode: :bypass)
  )
```

Use `run/2` when only final assistant text matters. Use `execute/2` when tool
events, init metadata, thinking text, usage, stderr diagnostics, or partial
assistant deltas matter.

## Workspace

```elixir
options =
  CursorCliSdk.Options.new!(
    cwd: "/workspace/app",
    permission_mode: :plan
  )
```

`cwd` is the only workspace option. It is used as the process cwd and mapped to
Cursor's `--workspace <cwd>` flag. There is no `:workspace` option.

## Real Examples

Run the checked examples under the repository root:

```bash
mix run examples/simple_stream.exs
mix run examples/promotion_path/sdk_direct_cursor.exs
```

For live credentials in this workspace, use the shared wrapper:

```bash
~/scripts/with_bash_secrets mix run examples/simple_stream.exs
```
