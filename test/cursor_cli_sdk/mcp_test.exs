defmodule CursorCliSdk.MCPTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.MCP

  test "MCP wrappers build Cursor subcommands" do
    capture = Path.join(CursorCliSdk.TestSupport.tmp_dir!("cursor-mcp"), "argv")

    script =
      CursorCliSdk.TestSupport.executable_script!("""
      printf '%s\\n' "$@" > "#{capture}"
      printf 'ok\\n'
      """)

    assert {:ok, "ok"} = MCP.enable("server-a", cli_command: script)
    assert File.read!(capture) == "mcp\nenable\nserver-a\n"

    assert {:ok, "ok"} = MCP.list_tools("server-a", cli_command: script)
    assert File.read!(capture) == "mcp\nlist-tools\nserver-a\n"
  end
end
