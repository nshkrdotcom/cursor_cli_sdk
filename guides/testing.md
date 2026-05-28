# Testing

The repo uses unit tests, fixture projection tests, live CLI tests, Credo, and
Dialyzer.

## Local QC

```bash
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix credo --strict
mix dialyzer
mix docs --warnings-as-errors
```

The `mix ci` alias wraps the non-live checks.

## Live Tests

Live tests require the real `agent` binary and credentials:

```bash
mix test.live
```

In the shared workspace, run through the secrets wrapper:

```bash
~/scripts/with_bash_secrets mix test.live
~/scripts/with_bash_secrets mix run examples/simple_stream.exs
~/scripts/with_bash_secrets mix run examples/promotion_path/sdk_direct_cursor.exs
```

## Fixtures

Fixtures under `test/support/fixtures/` cover:

- simple assistant response
- tool use / tool result response

Projection tests parse these through the same core Cursor profile used by live
streams.

## Audits

Required audits for this SDK:

- no dynamic atom creation from CLI or JSON input
- no `System.get_env/1` in `lib/**`
- no `--prompt` flag in invocation docs or tests
- no `:workspace` option on `CursorCliSdk.Options`
