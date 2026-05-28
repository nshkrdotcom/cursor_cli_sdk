# ASM Integration

`agent_session_manager` registers Cursor as the fifth provider and can run it
through two lanes.

| Lane | Runtime |
| --- | --- |
| `:core` | `CliSubprocessCore.ProviderProfiles.Cursor` |
| `:sdk` | `CursorCliSdk.Runtime.CLI` |

## Dependency

ASM activates the SDK lane when `cursor_cli_sdk` is present:

```elixir
{:cursor_cli_sdk, "~> 0.1.0"}
```

## Start a Cursor SDK Session

```elixir
{:ok, session} =
  ASM.start_session(
    provider: :cursor,
    lane: :sdk,
    permission_mode: :bypass
  )
```

## Cursor Native Overrides

ASM common options own provider, cwd, model, auth materialization, execution
surface, and permission posture. Cursor-specific settings flow through
`ASM.Options.Cursor` and the provider SDK extension boundary:

- `mode`
- `sandbox`
- `approve_mcps`
- `worktree`
- `worktree_base`
- `skip_worktree_setup`
- `plugin_dirs`
- `headers`

There is no ASM `:workspace` key. Common `:cwd` maps to Cursor `--workspace`.

## Examples

```bash
mix run --no-start examples/provider_cursor_core_stream.exs -- --provider cursor
mix run --no-start examples/provider_cursor_sdk_stream.exs -- --provider cursor --lane sdk
mix run --no-start examples/promotion_path/hybrid_asm_plus_cursor.exs -- --provider cursor --lane sdk
```
