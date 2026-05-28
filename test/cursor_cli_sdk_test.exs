defmodule CursorCliSdkTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.Options
  alias CursorCliSdk.Types.{MessageEvent, ResultEvent}

  test "execute/2 and run/2 are exposed" do
    assert Code.ensure_loaded?(CursorCliSdk)
    assert Code.ensure_loaded?(CursorCliSdk.Application)
    assert %Options{} = %Options{}
  end

  test "run/2 returns final result from streamed Cursor events" do
    script =
      CursorCliSdk.TestSupport.executable_script!("""
      cat "#{CursorCliSdk.TestSupport.fixture_path("simple_response.jsonl")}"
      """)

    assert {:ok, "CURSOR_OK"} =
             CursorCliSdk.run("ignored", %Options{cli_command: script, timeout_ms: 1_000})
  end

  test "execute/2 projects message and result events" do
    script =
      CursorCliSdk.TestSupport.executable_script!("""
      cat "#{CursorCliSdk.TestSupport.fixture_path("simple_response.jsonl")}"
      """)

    events =
      "ignored"
      |> CursorCliSdk.execute(%Options{cli_command: script, timeout_ms: 1_000})
      |> Enum.to_list()

    assert Enum.any?(events, &match?(%MessageEvent{content: "CURSOR", delta?: true}, &1))
    assert Enum.any?(events, &match?(%ResultEvent{result: "CURSOR_OK"}, &1))
  end
end
