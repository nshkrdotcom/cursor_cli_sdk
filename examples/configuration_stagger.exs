Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("configuration_stagger", config)

IO.puts("spawn_stagger_ms=#{CursorCliSdk.Configuration.spawn_stagger_ms()}")

prompts = [
  {"first", "Reply with exactly: CURSOR_STAGGER_ONE_OK"},
  {"second", "Reply with exactly: CURSOR_STAGGER_TWO_OK"}
]

prompts
|> Task.async_stream(
  fn {label, prompt} ->
    {label, CursorCliSdk.run(prompt, Helper.options(config))}
  end,
  max_concurrency: 1,
  timeout: 180_000
)
|> Enum.each(fn
  {:ok, {label, {:ok, text}}} ->
    IO.puts("#{label}=#{inspect(text)}")

  {:ok, {label, {:error, error}}} ->
    Mix.raise("#{label} failed: #{Exception.message(error)}")

  {:exit, reason} ->
    Mix.raise("task failed: #{inspect(reason)}")
end)
