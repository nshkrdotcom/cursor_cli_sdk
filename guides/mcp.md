# MCP

`CursorCliSdk.MCP` wraps Cursor's MCP command group.

```elixir
{:ok, servers} = CursorCliSdk.MCP.list()
{:ok, _} = CursorCliSdk.MCP.enable("server-name")
{:ok, _} = CursorCliSdk.MCP.list_tools("server-name")
```

## Approving MCPs for Headless Runs

Prompt execution can pass `--approve-mcps`:

```elixir
CursorCliSdk.run(
  "Use the configured MCP if needed.",
  CursorCliSdk.Options.new!(approve_mcps: true, permission_mode: :bypass)
)
```

`approve_mcps` is a Cursor-native option. In ASM it belongs in the Cursor
provider options or native override boundary, not in common provider-agnostic
options.

## Command Options

MCP helpers accept the same command options as `CursorCliSdk.Command.run/2`,
including `:timeout`, `:cli_command`, and governed authority options.
