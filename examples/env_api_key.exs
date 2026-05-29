alias CursorCliSdk.{CLI, Options}

options = Options.new!(api_key: "cursor-secret", env: %{"CURSOR_EXTRA" => "1"})
env = CLI.build_env(options)
args = CursorCliSdk.ArgBuilder.build_args(options, "Env render")

IO.puts("api_key_env_present=#{Map.get(env, "CURSOR_API_KEY") == "cursor-secret"}")
IO.puts("extra_env_present=#{Map.get(env, "CURSOR_EXTRA") == "1"}")

if Enum.any?(args, &String.contains?(&1, "cursor-secret")) do
  Mix.raise("api key leaked into argv: #{inspect(args)}")
end

IO.puts("api_key_argv_leak=false")
