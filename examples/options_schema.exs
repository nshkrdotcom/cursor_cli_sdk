alias CursorCliSdk.Options

options = Options.new!(permission_mode: :bypass, mode: :plan, headers: [{"X-Mode", "plan"}])

IO.puts("permission_mode=#{inspect(options.permission_mode)}")
IO.puts("mode=#{inspect(options.mode)}")
IO.puts("header_count=#{length(options.headers)}")

case Options.new(timeout_ms: -1) do
  {:error, error} -> IO.puts("invalid_timeout=#{Exception.message(error)}")
  {:ok, _options} -> Mix.raise("expected invalid timeout")
end
