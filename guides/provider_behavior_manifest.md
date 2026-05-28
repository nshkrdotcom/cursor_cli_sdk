# Provider Behavior Manifest

Phase 3 evidence skeleton for `cursor_cli_sdk`.

| Surface | Evidence |
| --- | --- |
| Headless stream command | `agent -p --trust --output-format stream-json --stream-partial-output <prompt>` |
| Prompt placement | Positional final argv element; no `--prompt` flag |
| Workspace placement | `Options.cwd` maps to process cwd and `--workspace <cwd>` |
| Auth placement | `Options.api_key` materializes `CURSOR_API_KEY` in env; never argv |
| Parser source | `CliSubprocessCore.ProviderProfiles.Cursor` |
| Fixture coverage | `test/support/fixtures/simple_response.jsonl`, `tool_use_response.jsonl` |
| Governed launch | `CursorCliSdk.GovernedLaunch` rejects caller command, cwd, env, api key, and execution surface overrides |
| Live gate | `mix test.live`, `examples/simple_stream.exs`, `examples/promotion_path/sdk_direct_cursor.exs` |

Phase 4 expands this into the full docs evidence table after the live gates are rerun.

