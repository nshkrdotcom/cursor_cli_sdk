defmodule CursorCliSdk.LiveTest do
  use ExUnit.Case, async: false

  alias CursorCliSdk.Options
  alias CursorCliSdk.Types.ResultEvent

  @moduletag :live

  test "real Cursor agent streams and returns exact text" do
    events =
      "Reply with exactly: CURSOR_SDK_LIVE_OK"
      |> CursorCliSdk.execute(%Options{permission_mode: :bypass, timeout_ms: 120_000})
      |> Enum.to_list()

    assert Enum.any?(events, &match?(%ResultEvent{result: "CURSOR_SDK_LIVE_OK"}, &1))
  end
end
