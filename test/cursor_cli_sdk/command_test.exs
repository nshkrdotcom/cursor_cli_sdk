defmodule CursorCliSdk.CommandTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.Command

  test "command helpers build Cursor argv" do
    capture = Path.join(CursorCliSdk.TestSupport.tmp_dir!("cursor-command"), "argv")

    script =
      CursorCliSdk.TestSupport.executable_script!("""
      printf '%s\\n' "$@" > "#{capture}"
      printf 'ok\\n'
      """)

    assert {:ok, "ok"} = Command.models(cli_command: script)
    assert File.read!(capture) == "models\n"

    assert {:ok, "ok"} = Command.version(cli_command: script)
    assert File.read!(capture) == "--version\n"

    assert {:ok, "ok"} = Command.create_chat(cli_command: script)
    assert File.read!(capture) == "create-chat\n"
  end
end
