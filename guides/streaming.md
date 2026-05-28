# Streaming

`CursorCliSdk.execute/2` returns a lazy stream of typed events.

```elixir
stream =
  CursorCliSdk.execute(
    "Reply with exactly: OK",
    CursorCliSdk.Options.new!(permission_mode: :bypass)
  )

Enum.to_list(stream)
```

## Event Projection

The SDK delegates Cursor NDJSON parsing to
`CliSubprocessCore.ProviderProfiles.Cursor` and then projects core events into
SDK structs:

- `CursorCliSdk.Types.InitEvent`
- `CursorCliSdk.Types.MessageEvent`
- `CursorCliSdk.Types.ThinkingEvent`
- `CursorCliSdk.Types.ToolUseEvent`
- `CursorCliSdk.Types.ToolResultEvent`
- `CursorCliSdk.Types.ResultEvent`
- `CursorCliSdk.Types.ErrorEvent`

## Assistant Deltas and Final Snapshots

Cursor can emit partial assistant text and final assistant snapshots. The core
profile tags final snapshots so the SDK can expose deltas without duplicating
the final text. Use `MessageEvent.delta?` to distinguish streamed text from a
final assistant snapshot.

## Backpressure

The stream only receives the next event when the enumerable is consumed. The
subprocess still runs underneath, so callers should consume promptly or collect
into a supervised process when doing expensive work per event.

## Stderr

Stderr is diagnostics only. It is not parsed as JSON. Fatal stream errors carry
the stderr tail when available, bounded by `max_stderr_buffer_bytes`.

## Timeouts

`Options.timeout_ms` controls how long the stream waits for the next event.
Increase it for long-running prompts:

```elixir
CursorCliSdk.Options.new!(timeout_ms: 600_000)
```
