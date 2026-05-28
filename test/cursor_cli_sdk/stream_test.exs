defmodule CursorCliSdk.StreamTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.{Options, Stream}
  alias CursorCliSdk.Types.{ErrorEvent, ResultEvent}

  test "execute/2 streams from a stub Cursor CLI" do
    script =
      CursorCliSdk.TestSupport.executable_script!("""
      cat "#{CursorCliSdk.TestSupport.fixture_path("simple_response.jsonl")}"
      """)

    events =
      "ignored"
      |> Stream.execute(%Options{cli_command: script, timeout_ms: 1_000})
      |> Enum.to_list()

    assert Enum.any?(events, &match?(%ResultEvent{result: "CURSOR_OK"}, &1))
  end

  test "execute/2 emits a structured start failure" do
    [event] =
      "ignored"
      |> Stream.execute(%Options{cli_command: "/not/a/real/agent", timeout_ms: 10})
      |> Enum.to_list()

    assert %ErrorEvent{code: "stream_start_failed"} = event
  end
end
