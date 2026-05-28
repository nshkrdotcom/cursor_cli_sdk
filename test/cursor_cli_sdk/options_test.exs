defmodule CursorCliSdk.OptionsTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.Options

  test "new/1 normalizes Cursor-native options" do
    assert {:ok, %Options{} = opts} =
             Options.new(
               model: "composer-2.5-fast",
               mode: "ask",
               permission_mode: "bypass",
               cwd: "/tmp/work",
               api_key: "secret",
               plugin_dirs: ["plugins"],
               headers: ["X-Test: 1"]
             )

    assert opts.mode == :ask
    assert opts.permission_mode == :bypass
    assert opts.cwd == "/tmp/work"
    assert opts.api_key == "secret"
  end

  test "workspace is not an SDK option" do
    assert {:error, %KeyError{key: :workspace}} = Options.new(workspace: "/tmp/not-allowed")
  end

  test "validate! rejects invalid permission modes" do
    assert_raise ArgumentError, ~r/permission_mode/, fn ->
      Options.validate!(%Options{permission_mode: :everything})
    end
  end
end
