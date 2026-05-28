# Models

`CursorCliSdk.Models` wraps `agent models` and parses the output into model
entries.

```elixir
{:ok, models} = CursorCliSdk.Models.list()

Enum.map(models, fn model ->
  {model.id, model.label, model.default?}
end)
```

## Default Model

```elixir
{:ok, maybe_default} = CursorCliSdk.Models.default_model()
```

The function returns `{:ok, nil}` when Cursor does not mark a default model in
the command output.

## Validate a Model

```elixir
case CursorCliSdk.Models.validate_model("composer-2.5-fast") do
  :ok -> :ok
  {:error, {:unknown_model, model}} -> raise "unknown model: #{model}"
end
```

Validation is a live CLI check. It should be used in operator tooling, not in
hot paths that need to avoid a subprocess call.

## Parsing

`parse/1` is pure and covered by fixture tests:

```elixir
CursorCliSdk.Models.parse("""
* composer-2.5-fast Fast Composer
  other-model Other Model
""")
```

Lines beginning with `*` are treated as default-model entries.
