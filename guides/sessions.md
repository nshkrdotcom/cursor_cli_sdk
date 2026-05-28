# Sessions

`CursorCliSdk.Session` wraps Cursor session listing and continuation helpers.

## List Sessions

```elixir
{:ok, sessions} = CursorCliSdk.Session.list_sessions()
```

Each entry is a `%CursorCliSdk.Session.Entry{}` with:

- `id`
- `label`
- `updated_at`
- `raw_line`

The parser accepts whitespace- and tab-separated CLI output.

## Resume a Session

```elixir
events =
  CursorCliSdk.Session.resume_session(
    "session-id",
    CursorCliSdk.Options.new!(permission_mode: :bypass),
    "Continue with a short summary."
  )

Enum.to_list(events)
```

This sets `Options.resume` and streams through the normal runtime path.

## Continue Latest

```elixir
CursorCliSdk.Session.continue_latest(
  CursorCliSdk.Options.new!(permission_mode: :bypass),
  "Continue the latest conversation."
)
|> Enum.to_list()
```

This sets `Options.continue` for runtimes that expose latest-session
continuation.
