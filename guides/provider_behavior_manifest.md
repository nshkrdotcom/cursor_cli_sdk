# Provider Behavior Manifest

Behavior evidence for `cursor_cli_sdk` and the Cursor Agent CLI (`agent`).

| Surface | Evidence |
| --- | --- |
| CLI command | `agent` resolved through `CliSubprocessCore.ProviderCLI` or explicit `cli_command` |
| Headless stream command | `agent -p --trust --output-format stream-json --stream-partial-output <prompt>` |
| Prompt placement | Positional final argv element; no `--prompt` flag |
| Workspace placement | `Options.cwd` maps to process cwd and `--workspace <cwd>` |
| Auth placement | `Options.api_key` materializes `CURSOR_API_KEY` in env; never argv |
| Governed auth | `CliSubprocessCore.GovernedAuthority` owns env and placement |
| Parser source | `CliSubprocessCore.ProviderProfiles.Cursor` |
| Init event | Cursor `system/init` projects to `CursorCliSdk.Types.InitEvent` |
| Assistant deltas | Partial output projects to `MessageEvent` with `delta?: true` |
| Final snapshot | Core profile tags final snapshots to avoid duplicate accumulated text |
| Tool events | Tool use and result project to typed SDK events |
| Result event | Final status, stop reason, result text, usage, and duration project to `ResultEvent` |
| Error event | CLI/runtime errors project to `ErrorEvent` or `%CursorCliSdk.Error{}` |
| Fixture coverage | `test/support/fixtures/simple_response.jsonl`, `tool_use_response.jsonl` |
| Governed launch | `CursorCliSdk.GovernedLaunch` rejects caller command, cwd, env, api key, and execution surface overrides |
| MCP | `CursorCliSdk.MCP` wraps `agent mcp ...` commands |
| Models | `CursorCliSdk.Models` wraps and parses `agent models` |
| Sessions | `CursorCliSdk.Session` wraps list, resume, and continue helpers |
| Live gate | `mix test.live`, `examples/simple_stream.exs`, `examples/promotion_path/sdk_direct_cursor.exs` |

## Flags Claimed By SDK Docs

| Flag | Source |
| --- | --- |
| `-p` | Core Cursor profile invocation tests |
| `--trust` | Core Cursor profile invocation tests |
| `--output-format stream-json` | Core Cursor profile invocation tests |
| `--stream-partial-output` | Core Cursor profile invocation tests |
| `--workspace <cwd>` | SDK/core invocation contract tests |
| `--model <model>` | SDK ArgBuilder tests |
| `--resume <session_id>` | SDK ArgBuilder and session tests |
| `--mode <mode>` | SDK ArgBuilder tests |
| `--force` | `CliSubprocessCore.ProviderFeatures.permission_args(:cursor, :bypass)` |
| `--approve-mcps` | SDK ArgBuilder and MCP docs |
| `--sandbox <value>` | SDK ArgBuilder tests |
| `--worktree` / `--worktree <value>` | SDK ArgBuilder tests |
| `--worktree-base <path>` | SDK ArgBuilder tests |
| `--skip-worktree-setup` | SDK ArgBuilder tests |
| `--plugin-dir <path>` | SDK ArgBuilder tests |
| `-H <header>` | SDK ArgBuilder tests |

## Phase 3 Live Evidence

| Command | Result |
| --- | --- |
| `~/scripts/with_bash_secrets mix test.live` | Green |
| `~/scripts/with_bash_secrets mix run examples/simple_stream.exs` | Produced `CURSOR_SDK_EXAMPLE_OK` |
| `~/scripts/with_bash_secrets mix run examples/promotion_path/sdk_direct_cursor.exs` | Produced `CURSOR_SDK_DIRECT_OK` |

Transcript:
`~/p/g/n/trinity_framework/tmp/crucible_cleanup/transcripts/phase12_phase3_sdk_live_pre_asm.log`
