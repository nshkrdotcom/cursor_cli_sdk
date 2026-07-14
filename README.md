<p align="center">
  <img src="assets/cursor_cli_sdk.svg" alt="CursorCliSdk" width="200"/>
</p>

<p align="center">
  <a href="https://github.com/nshkrdotcom/cursor_cli_sdk"><img src="https://img.shields.io/badge/GitHub-nshkrdotcom%2Fcursor_cli_sdk-24292e?logo=github" alt="GitHub"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"/></a>
</p>

# CursorCliSdk

Elixir SDK for the Cursor Agent CLI (`agent`). It runs Cursor's headless
stream-json mode through `cli_subprocess_core`, projects NDJSON into typed
Elixir events, exposes synchronous and streaming APIs, and provides governed
launch, MCP, model, session, and ASM integration helpers.

## Documentation Menu

- [Getting Started](guides/getting-started.md)
- [Options](guides/options.md)
- [Models](guides/models.md)
- [Configuration](guides/configuration.md)
- [Authentication](guides/authentication.md)
- [Streaming](guides/streaming.md)
- [Synchronous Runs](guides/synchronous.md)
- [Sessions](guides/sessions.md)
- [Error Handling](guides/error-handling.md)
- [Architecture](guides/architecture.md)
- [Governed Launch](guides/governed-launch.md)
- [ASM Integration](guides/asm-integration.md)
- [MCP](guides/mcp.md)
- [Testing](guides/testing.md)
- [Provider Behavior Manifest](guides/provider_behavior_manifest.md)
- [Examples](examples/README.md)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

## Features

- Lazy streaming with `CursorCliSdk.execute/2`
- One-shot text responses with `CursorCliSdk.run/2`
- Typed event projection for init, assistant message, thinking, tool use, tool result, result, and error events
- Shared Cursor parser and invocation contract from `CliSubprocessCore.ProviderProfiles.Cursor`
- Governed launch validation that rejects caller command, cwd, env, API key, and execution-surface smuggling
- Cursor command helpers for version, models, status, chat creation, sessions, and MCP commands
- Session resume and continue helpers
- Runtime configuration for timeouts, stderr buffering, and headless spawn staggering
- ASM SDK lane support through `agent_session_manager`

## Installation

CursorCliSdk 0.1.0 requires Elixir 1.19 or later.

```elixir
def deps do
  [
    {:cursor_cli_sdk, "~> 0.1.0"}
  ]
end
```

The `agent` binary must be available on `PATH`, or pass `cli_command:` in
standalone options. Authenticate with Cursor's CLI login flow or materialize
`CURSOR_API_KEY` through `CursorCliSdk.Options.api_key`, `Options.env`, or a
governed launch authority.

The package depends on `cli_subprocess_core ~> 0.2.0`. That lower package must
be available before a Hex-only installation can resolve.

## Authentication

Standalone callers provide credentials explicitly:

```elixir
options =
  CursorCliSdk.Options.new!(
    api_key: System.fetch_env!("CURSOR_API_KEY"),
    permission_mode: :bypass
  )
```

The library never reads `System.get_env/1` from `lib/**`. Application code owns
environment lookup. In governed mode, credentials come from
`CliSubprocessCore.GovernedAuthority`; caller-supplied `api_key`, `cwd`, `env`,
`cli_command`, and `execution_surface` are rejected.

See [Authentication](guides/authentication.md) and
[Governed Launch](guides/governed-launch.md).

## Quick Start

Streaming:

```elixir
options = CursorCliSdk.Options.new!(permission_mode: :bypass)

CursorCliSdk.execute("Reply with exactly: OK", options)
|> Enum.each(fn event ->
  IO.inspect(event)
end)
```

Synchronous:

```elixir
{:ok, text} =
  CursorCliSdk.run(
    "Reply with exactly: OK",
    CursorCliSdk.Options.new!(permission_mode: :bypass)
  )
```

Workspace placement:

```elixir
options =
  CursorCliSdk.Options.new!(
    cwd: "/workspace/app",
    model: "composer-2.5-fast",
    permission_mode: :plan
  )
```

`cwd` is the only workspace field. It becomes the process cwd and Cursor's
`--workspace <cwd>` argv pair.

Sessions:

```elixir
{:ok, sessions} = CursorCliSdk.Session.list_sessions()

events =
  CursorCliSdk.Session.resume_session(
    hd(sessions).id,
    CursorCliSdk.Options.new!(permission_mode: :bypass),
    "Continue with a one-sentence summary."
  )

Enum.to_list(events)
```

## Examples

Run the SDK-owned example suite with:

```bash
~/scripts/with_bash_secrets bash examples/run_all.sh
```

See [Examples](examples/README.md) for the full inventory. These are direct SDK
examples; ASM provider examples live in `agent_session_manager/examples`.

## Event Types

| Struct | Meaning |
| --- | --- |
| `CursorCliSdk.Types.InitEvent` | Cursor `system/init` metadata such as session, model, and cwd |
| `CursorCliSdk.Types.MessageEvent` | User or assistant message content; assistant deltas set `delta?: true` |
| `CursorCliSdk.Types.ThinkingEvent` | Cursor thinking/progress text when emitted |
| `CursorCliSdk.Types.ToolUseEvent` | Tool call name, call id, and input |
| `CursorCliSdk.Types.ToolResultEvent` | Tool call result payload |
| `CursorCliSdk.Types.ResultEvent` | Final status, stop reason, result text, usage, and timing |
| `CursorCliSdk.Types.ErrorEvent` | Stream or CLI error projected into a typed event |

## Headless Invocation Contract

The canonical streaming command shape is:

```bash
agent -p --trust --output-format stream-json --stream-partial-output [options] "prompt text"
```

The prompt is positional. There is no `--prompt` flag in this SDK contract.

## ASM Integration

`agent_session_manager` can run Cursor through either lane:

- `:core` lane: `CliSubprocessCore.ProviderProfiles.Cursor`
- `:sdk` lane: `CursorCliSdk.Runtime.CLI` when `cursor_cli_sdk` is present

See [ASM Integration](guides/asm-integration.md).

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `agent` not found | Install Cursor Agent CLI or pass `cli_command:` |
| Auth failure / exit 41 | Confirm CLI login or materialized `CURSOR_API_KEY` |
| Immediate exit in many concurrent runs | Lower app concurrency or increase `spawn_stagger_ms` |
| Stream timeout | Increase `timeout_ms` on `CursorCliSdk.Options` |
| No assistant text from `run/2` | Inspect streaming events with `execute/2` and stderr diagnostics |

## Links

- [Cursor CLI documentation](https://cursor.com/docs/cli/overview)
- [cli_subprocess_core](https://github.com/nshkrdotcom/cli_subprocess_core)
- [agent_session_manager](https://github.com/nshkrdotcom/agent_session_manager)
