# Authentication

The SDK supports two authentication postures:

- standalone: application code supplies env materialization explicitly
- governed: a `CliSubprocessCore.GovernedAuthority` supplies command, cwd, env, and credential materialization

The library does not call `System.get_env/1` from `lib/**`. Environment lookup
belongs at the application boundary.

## Standalone

```elixir
options =
  CursorCliSdk.Options.new!(
    api_key: System.fetch_env!("CURSOR_API_KEY"),
    permission_mode: :bypass
  )
```

`api_key` becomes `CURSOR_API_KEY` in the child process environment. It is never
placed in argv.

You may also provide an explicit env map:

```elixir
CursorCliSdk.Options.new!(
  env: %{"CURSOR_API_KEY" => System.fetch_env!("CURSOR_API_KEY")}
)
```

## CLI Login

If the local Cursor CLI is already authenticated, omit `api_key` and `env`.
The child process inherits the surrounding process environment according to the
underlying command transport.

## Governed

Governed launch rejects caller-owned auth and placement fields:

```elixir
authority =
  CliSubprocessCore.GovernedAuthority.new!(
    command: "agent",
    cwd: "/workspace/app",
    env: %{"CURSOR_API_KEY" => token},
    clear_env?: true
  )

options = CursorCliSdk.Options.new!(governed_authority: authority)
```

When `governed_authority` is present, do not also set `api_key`, `env`, `cwd`,
`cli_command`, or `execution_surface`.

## Exit Codes

`CursorCliSdk.Error.from_exit_code/1` maps known Cursor CLI exits:

| Exit | Kind |
| --- | --- |
| `41` | `:auth_error` |
| `42` | `:input_error` |
| `52` | `:config_error` |
| `130` | `:user_cancelled` |

Other non-zero exits become `:command_failed` or runtime-specific failures.
