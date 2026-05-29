alias CursorCliSdk.{Command, Options}

case Options.new(timeout_ms: 0) do
  {:error, error} -> IO.puts("invalid_options=#{Exception.message(error)}")
  {:ok, _options} -> Mix.raise("expected invalid options error")
end

case Command.version(cli_command: "/definitely/not/cursor-agent") do
  {:error, error} ->
    IO.puts("command_error_kind=#{inspect(error.kind)}")
    IO.puts("command_error=#{Exception.message(error)}")

  {:ok, output} ->
    Mix.raise("expected command failure, got #{inspect(output)}")
end
