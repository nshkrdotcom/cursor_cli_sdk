# Error Handling

SDK operations return `%CursorCliSdk.Error{}` for normalized failures.

```elixir
case CursorCliSdk.run("Hello") do
  {:ok, text} ->
    text

  {:error, %CursorCliSdk.Error{kind: :auth_error} = error} ->
    raise error.message
end
```

## Error Fields

| Field | Meaning |
| --- | --- |
| `:kind` | Stable normalized error atom |
| `:message` | Human-readable summary |
| `:cause` | Original exception or runtime failure |
| `:details` | Stderr or additional diagnostic text |
| `:context` | Map of command/runtime context |
| `:exit_code` | CLI exit code when known |

## Common Kinds

- `:auth_error`
- `:cli_not_found`
- `:config_invalid`
- `:input_error`
- `:parse_error`
- `:stream_start_failed`
- `:stream_timeout`
- `:transport_error`
- `:transport_exit`
- `:user_cancelled`

## Stream Errors

`execute/2` emits `%CursorCliSdk.Types.ErrorEvent{}` instead of raising.
Fatal stream errors stop the enumerable.

## Command Errors

Command helpers such as `CursorCliSdk.Command.models/1` and
`CursorCliSdk.MCP.list/1` return `{:error, %CursorCliSdk.Error{}}` when the CLI
exits non-zero or cannot be launched.
