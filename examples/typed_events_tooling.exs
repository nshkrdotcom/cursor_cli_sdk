alias CursorCliSdk.Types.{
  InitEvent,
  MessageEvent,
  ResultEvent,
  ThinkingEvent,
  ToolResultEvent,
  ToolUseEvent
}

lines = [
  ~s({"type":"system","subtype":"init","session_id":"cursor-example","model":"Composer 2.5","cwd":"/tmp/cursor"}),
  ~s({"type":"thinking","subtype":"delta","text":"Need tool","session_id":"cursor-example","timestamp_ms":1000}),
  ~s({"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"CURSOR"}]},"session_id":"cursor-example","timestamp_ms":1001}),
  ~s({"type":"tool_call","subtype":"started","call_id":"tool-cursor-1","tool_call":{"shellToolCall":{"args":{"command":"pwd","toolCallId":"tool-cursor-1"},"description":"Print working directory"}},"session_id":"cursor-example","timestamp_ms":1002}),
  ~s({"type":"tool_call","subtype":"completed","call_id":"tool-cursor-1","tool_call":{"shellToolCall":{"args":{"command":"pwd","toolCallId":"tool-cursor-1"},"result":{"success":{"stdout":"/tmp\\n","stderr":"","exitCode":0}},"description":"Print working directory"}},"session_id":"cursor-example","timestamp_ms":1003}),
  ~s({"type":"result","subtype":"success","duration_ms":300,"is_error":false,"result":"CURSOR_TYPED_EVENTS_OK","session_id":"cursor-example","usage":{"inputTokens":4,"outputTokens":2}})
]

events =
  Enum.flat_map(lines, fn line ->
    {:ok, parsed} = CursorCliSdk.Types.parse_event(line)
    parsed
  end)

assertions = [
  init: Enum.any?(events, &match?(%InitEvent{}, &1)),
  thinking: Enum.any?(events, &match?(%ThinkingEvent{}, &1)),
  message: Enum.any?(events, &match?(%MessageEvent{}, &1)),
  tool_use: Enum.any?(events, &match?(%ToolUseEvent{}, &1)),
  tool_result: Enum.any?(events, &match?(%ToolResultEvent{}, &1)),
  result: Enum.any?(events, &match?(%ResultEvent{result: "CURSOR_TYPED_EVENTS_OK"}, &1))
]

for {name, true} <- assertions do
  IO.puts("#{name}=true")
end

failed = for {name, false} <- assertions, do: name
if failed != [], do: Mix.raise("missing typed events: #{inspect(failed)}")
