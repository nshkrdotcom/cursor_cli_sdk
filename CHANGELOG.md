# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-08-11

### Changed

- Updated the runtime boundary to `cli_subprocess_core ~> 0.7.0`, making the
  SDK compatible with the current Agent Session Manager dependency graph.
- Release checks now prove that repository-only `build_support` tooling is
  excluded from the published package.

## [0.2.0] - 2026-07-27

### Changed

- Adopted the shared dependency-source contract, including deterministic
  source selection, source-lock verification, release DAG ordering, and a
  fail-closed preflight for the exact local sibling release on Hex. Nested
  package tasks resolve the helper-owning repository, and manifest self-entries
  are excluded from prerequisites.
- Release metadata now targets `cli_subprocess_core ~> 0.3.0`.

## [0.1.0] - 2026-07-13

### Added

- Cursor Agent CLI option validation and provider-native argv rendering for
  model, workspace, mode, permissions, sandbox, MCP approval, worktrees,
  plugins, headers, resume, and continuation.
- Lazy streaming and synchronous prompt APIs backed by the shared Cursor
  profile and `CliSubprocessCore` command/session facades.
- Typed init, assistant, thinking, tool-use, tool-result, result, and error
  event projection with fixture coverage for partial output and tool calls.
- Governed authority launch support that fails closed on caller command, cwd,
  environment, API key, model environment, and execution-surface smuggling.
- Cursor command, MCP, model-list, and session helpers, including pure parsers
  for model and session output.
- SDK-direct examples, offline fixtures, a live opt-in gate, and a provider
  behavior manifest covering the documented Cursor CLI contract.
- Full README onboarding and HexDocs guides for options, authentication,
  configuration, streaming, synchronous runs, sessions, errors, architecture,
  governed launch, MCP, testing, and ASM integration.

### Changed

- Restricted the Hex archive to consumer-facing source, guides, examples, and
  public documentation/assets, with a consistent 200px README presentation.
- Prepared the first Hex release for Elixir `~> 1.19` and
  `cli_subprocess_core ~> 0.2.0`.

### Security

- Runtime library code accepts explicitly materialized credentials and does
  not read the host OS environment directly.
- API keys are placed only in the child environment, never on argv, and
  governed launch rejects unmanaged credential or placement overrides.

[Unreleased]: https://github.com/nshkrdotcom/cursor_cli_sdk/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/nshkrdotcom/cursor_cli_sdk/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/nshkrdotcom/cursor_cli_sdk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/nshkrdotcom/cursor_cli_sdk/releases/tag/v0.1.0
