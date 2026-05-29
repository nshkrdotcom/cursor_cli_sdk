# Examples

Runnable examples for `cursor_cli_sdk`. These examples exercise SDK-owned
surfaces directly. ASM examples stay in `agent_session_manager/examples`.

Prerequisites:

- Cursor Agent CLI (`agent`) installed and authenticated
- `mix deps.get`
- secrets wrapper for live local sweeps: `~/scripts/with_bash_secrets`

Run one example:

```bash
mix run examples/simple_stream.exs
mix run examples/model_selection.exs -- --model composer-2.5
```

Run all examples:

```bash
bash examples/run_all.sh
~/scripts/with_bash_secrets bash examples/run_all.sh
```

Run one example through the runner:

```bash
bash examples/run_all.sh simple_stream
bash examples/run_all.sh promotion_path/sdk_direct_cursor --cwd /repo
```

Shared flags:

- `--cwd <path>`
- `--cli-command <path>`
- `--model <id>`
- `--prompt <text>`
- `--danger-full-access`
- `--ssh-host <host>`
- `--ssh-user <user>`
- `--ssh-port <port>`
- `--ssh-identity-file <path>`

SSH flags are parsed consistently, but the default runner does not include a
remote-only example. Passing `--ssh-host` routes examples through the shared
`execution_surface` option.

## Inventory

| Example | SDK surface |
| --- | --- |
| `simple_stream.exs` | `CursorCliSdk.execute/2`, typed stream projection |
| `sync_run.exs` | `CursorCliSdk.run/2` blocking API |
| `model_selection.exs` | `CursorCliSdk.Models`, model validation, `--model` rendering |
| `mode_agent_plan_ask.exs` | `Options.mode` rendering |
| `permission_and_trust.exs` | permission mode and trust flag rendering |
| `session_resume_continue.exs` | session list, resume, and continue option rendering |
| `typed_events_tooling.exs` | typed event parsing for init/message/thinking/tool/result events |
| `mcp_helpers.exs` | `CursorCliSdk.MCP.list/1` and `approve_mcps` rendering |
| `worktree_options.exs` | worktree flags and temp git workspace setup |
| `plugin_dirs_and_headers.exs` | plugin directory and header rendering |
| `configuration_stagger.exs` | spawn stagger config and repeated live calls |
| `governed_launch_demo.exs` | governed authority invocation and smuggling rejection |
| `error_handling.exs` | validation and command-resolution errors |
| `command_module.exs` | `CursorCliSdk.Command.version/1` |
| `options_schema.exs` | `CursorCliSdk.Options` schema success/failure |
| `env_api_key.exs` | env/API-key materialization without argv leakage |
| `promotion_path/sdk_direct_cursor.exs` | SDK-only promotion path, no ASM imports |

Optional skip exit code `20` is reserved for future fleet-only examples. The
current default suite should pass without skips when the local Cursor CLI is
available and authenticated.
