defmodule CursorCliSdk.TypesTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.Types

  alias CursorCliSdk.Types.{
    InitEvent,
    MessageEvent,
    ResultEvent,
    ThinkingEvent,
    ToolResultEvent,
    ToolUseEvent
  }

  test "parse_event/1 projects simple fixture lines" do
    events =
      "simple_response.jsonl"
      |> CursorCliSdk.TestSupport.fixture_path()
      |> File.stream!([], :line)
      |> Enum.flat_map(fn line ->
        {:ok, projected} = Types.parse_event(String.trim_trailing(line, "\n"))
        projected
      end)

    assert Enum.any?(events, &match?(%InitEvent{session_id: "cursor-session-test"}, &1))
    assert Enum.any?(events, &match?(%MessageEvent{content: "CURSOR", delta?: true}, &1))

    assert Enum.any?(
             events,
             &match?(%MessageEvent{content: "CURSOR_OK"}, &1)
           )

    assert Enum.any?(events, &match?(%ResultEvent{result: "CURSOR_OK"}, &1))
  end

  test "parse_event/1 projects tool fixture lines" do
    events =
      "tool_use_response.jsonl"
      |> CursorCliSdk.TestSupport.fixture_path()
      |> File.stream!([], :line)
      |> Enum.flat_map(fn line ->
        {:ok, projected} = Types.parse_event(String.trim_trailing(line, "\n"))
        projected
      end)

    assert Enum.any?(events, &match?(%ThinkingEvent{content: "Need tool"}, &1))
    assert Enum.any?(events, &match?(%ToolUseEvent{tool_name: "shell"}, &1))
    assert Enum.any?(events, &match?(%ToolResultEvent{tool_call_id: "tool-cursor-1"}, &1))
  end
end
