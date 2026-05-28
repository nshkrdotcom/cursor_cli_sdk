# Configuration

`CursorCliSdk.Configuration` owns numeric runtime defaults. These values are
read from the `:cursor_cli_sdk` application environment.

| Function | Default |
| --- | --- |
| `command_timeout_ms/0` | `60_000` |
| `stream_timeout_ms/0` | `300_000` |
| `default_timeout_ms/0` | `300_000` |
| `transport_close_grace_ms/0` | `2_000` |
| `transport_kill_grace_ms/0` | `250` |
| `max_stderr_buffer_size/0` | `262_144` |
| `max_inflight_headless/0` | `4` |
| `spawn_stagger_ms/0` | `75` |

## Configure

```elixir
config :cursor_cli_sdk,
  stream_timeout_ms: 600_000,
  max_inflight_headless: 2,
  spawn_stagger_ms: 150
```

## Inspect

```elixir
CursorCliSdk.Configuration.all()
```

## Concurrency

Cursor's headless process can reject or exit quickly when many invocations are
spawned at once. Use `max_inflight_headless` in owner tooling and stagger start
times by `spawn_stagger_ms` when dispatching batches.

The SDK exposes these values but does not impose a global queue. Higher-level
runtimes such as ASM own fleet-level concurrency decisions.
