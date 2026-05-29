Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("mcp_helpers", config)

args = Helper.render_args(config, [approve_mcps: true], "MCP approval render")
Helper.assert_arg(args, "--approve-mcps")

case CursorCliSdk.MCP.list(Helper.command_opts(config)) do
  {:ok, output} -> IO.puts("mcp_list_bytes=#{byte_size(output)}")
  {:error, error} -> Mix.raise("mcp list failed: #{Exception.message(error)}")
end
