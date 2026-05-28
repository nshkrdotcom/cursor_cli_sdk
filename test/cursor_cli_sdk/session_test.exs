defmodule CursorCliSdk.SessionTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.Session

  test "parse_list_output/1 returns session entries" do
    assert [
             %Session.Entry{id: "abc123", label: "First session"},
             %Session.Entry{id: "def456", label: "Second"}
           ] = Session.parse_list_output("abc123 First session\ndef456\tSecond\n")
  end
end
