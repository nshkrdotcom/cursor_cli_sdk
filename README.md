<p align="center">
  <img src="assets/cursor_cli_sdk.svg" alt="CursorCliSdk" width="200"/>
</p>

<p align="center">
  <a href="https://github.com/nshkrdotcom/cursor_cli_sdk"><img src="https://img.shields.io/badge/GitHub-nshkrdotcom%2Fcursor_cli_sdk-24292e?logo=github" alt="GitHub"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License"/></a>
</p>

# CursorCliSdk

Elixir SDK for the Cursor Agent CLI (`agent`) with stream-json execution,
governed launch, command helpers, MCP wrappers, model/session helpers, and
stack integration through `cli_subprocess_core` and `agent_session_manager`.

## Documentation Menu

- `README.md` - overview and installation
- `guides/provider_behavior_manifest.md` - Phase 3 behavior evidence skeleton
- `CHANGELOG.md` - version history
- `LICENSE` - MIT License (Copyright (c) 2026 nshkrdotcom)

## Status

Phase 3 implementation is active. Full onboarding docs are intentionally
reserved for the Phase 4 documentation pass.

## Installation

```elixir
def deps do
  [
    {:cursor_cli_sdk, "~> 0.1.0", organization: "nshkrdotcom"}
  ]
end
```

Path or git dependency is expected until the first Hex publish.

## Quick Start

```elixir
{:ok, text} =
  CursorCliSdk.run(
    "Reply with exactly: OK",
    %CursorCliSdk.Options{permission_mode: :bypass}
  )
```

For streaming:

```elixir
CursorCliSdk.execute("Reply with exactly: OK", %CursorCliSdk.Options{})
|> Enum.to_list()
```
