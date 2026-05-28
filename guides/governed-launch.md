# Governed Launch

Governed launch lets an owner process decide command, cwd, environment, and
execution surface. The SDK validates that prompt callers cannot override those
launch boundaries.

## Authority

```elixir
authority =
  CliSubprocessCore.GovernedAuthority.new!(
    command: "agent",
    cwd: "/workspace/app",
    env: %{"CURSOR_API_KEY" => token},
    clear_env?: true
  )

options =
  CursorCliSdk.Options.new!(
    governed_authority: authority,
    permission_mode: :bypass
  )
```

## Rejected Option Fields

When `governed_authority` is present, these option fields are rejected if set:

- `:api_key`
- `:cli_command`
- `:cwd`
- `:env`
- `:execution_surface`

`model_payload.env_overrides` is also rejected.

## Rejected Command Fields

`CursorCliSdk.Command.run/2` rejects these command options in governed mode:

- `:api_key`
- `:cd`
- `:clear_env`
- `:clear_env?`
- `:cli_command`
- `:cli_path`
- `:command`
- `:command_spec`
- `:cwd`
- `:env`
- `:executable`
- `:execution_surface`

## Invocation

In governed mode, `CursorCliSdk.GovernedLaunch.invocation/2` renders the Cursor
argv but gets command placement from the authority:

```elixir
{:ok, command} =
  CursorCliSdk.GovernedLaunch.invocation(
    ["-p", "--trust", "--output-format", "stream-json", "Hello"],
    options
  )
```

Use this in owner frameworks that need to audit command placement before
launching.
