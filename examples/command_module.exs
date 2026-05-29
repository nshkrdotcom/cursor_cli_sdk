Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("command_module", config)

case CursorCliSdk.Command.version(Helper.command_opts(config)) do
  {:ok, version} -> IO.puts("cursor_version=#{String.trim(version)}")
  {:error, error} -> Mix.raise("version failed: #{Exception.message(error)}")
end
