# Options

`CursorCliSdk.Options` is the typed input for streaming and synchronous Cursor
invocations.

```elixir
options =
  CursorCliSdk.Options.new!(
    cwd: "/workspace/app",
    model: "composer-2.5-fast",
    mode: :ask,
    permission_mode: :bypass,
    approve_mcps: true
  )
```

## Core Fields

| Field | Meaning |
| --- | --- |
| `:cli_command` | Optional command path. Defaults to provider resolution for `agent`. |
| `:cwd` | Process cwd and Cursor `--workspace <cwd>`. This is the only workspace field. |
| `:model` | Model name passed as `--model`. |
| `:api_key` | Materialized as `CURSOR_API_KEY` in the child env, never argv. |
| `:env` | Additional child environment map for standalone runs. |
| `:timeout_ms` | Stream receive timeout. |
| `:max_stderr_buffer_bytes` | Tail buffer size for stderr diagnostics. |

## Cursor Native Fields

| Field | CLI behavior |
| --- | --- |
| `:mode` | Cursor operational mode. `:ask` becomes `--mode ask`; `:agent` omits the flag. |
| `:permission_mode` | Provider permission posture. `:bypass` maps to `--force`; `:plan` maps to `--mode plan`. |
| `:trust` | Emits `--trust` when true. |
| `:output_format` | Defaults to `stream-json`. |
| `:stream_partial_output` | Emits `--stream-partial-output` when true. |
| `:resume` | Emits `--resume <session_id>`. |
| `:continue` | Tracks latest-session continuation intent for runtimes that expose it. |
| `:sandbox` | Emits `--sandbox <value>` for string or true values. |
| `:approve_mcps` | Emits `--approve-mcps`. |
| `:worktree` | Emits `--worktree` or `--worktree <value>`. |
| `:worktree_base` | Emits `--worktree-base <path>`. |
| `:skip_worktree_setup` | Emits `--skip-worktree-setup`. |
| `:plugin_dirs` | Repeated `--plugin-dir <path>`. |
| `:headers` | Repeated `-H <header>`. |

## Permission Mode vs Mode

`:ask` is a Cursor mode, not a permission mode:

```elixir
CursorCliSdk.Options.new!(mode: :ask, permission_mode: :default)
```

Bypass is a permission posture:

```elixir
CursorCliSdk.Options.new!(permission_mode: :bypass)
```

## Governed Fields

`governed_authority` switches the SDK into governed launch mode. In that mode
caller-owned launch placement is rejected:

- `:api_key`
- `:cli_command`
- `:cwd`
- `:env`
- non-empty `:execution_surface`

See [Governed Launch](governed-launch.md).
