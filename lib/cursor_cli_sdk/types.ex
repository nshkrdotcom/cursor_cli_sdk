defmodule CursorCliSdk.Types do
  @moduledoc "Type projection for Cursor stream-json events."

  alias CliSubprocessCore.Event, as: CoreEvent
  alias CliSubprocessCore.Payload
  alias CliSubprocessCore.ProviderProfiles.Cursor, as: CoreCursor
  alias CursorCliSdk.Error

  alias __MODULE__.{
    ErrorEvent,
    InitEvent,
    MessageEvent,
    ResultEvent,
    ThinkingEvent,
    ToolResultEvent,
    ToolUseEvent
  }

  @type stream_event ::
          InitEvent.t()
          | MessageEvent.t()
          | ThinkingEvent.t()
          | ToolUseEvent.t()
          | ToolResultEvent.t()
          | ErrorEvent.t()
          | ResultEvent.t()

  @spec parse_event(String.t()) :: {:ok, [stream_event()]} | {:error, Error.t()}
  def parse_event(json_line) when is_binary(json_line) do
    {events, _state} = CoreCursor.decode_stdout(json_line, CoreCursor.init_parser_state([]))
    {:ok, Enum.flat_map(events, &project_core_event/1)}
  rescue
    error -> {:error, Error.normalize(error, kind: :parse_error)}
  end

  @spec project_core_event(CoreEvent.t()) :: [stream_event()]
  def project_core_event(%CoreEvent{
        kind: :raw,
        payload: %Payload.Raw{content: %{"type" => "system", "subtype" => "init"} = raw}
      }) do
    [
      %InitEvent{
        session_id: raw["session_id"],
        model: raw["model"],
        cwd: raw["cwd"],
        raw: raw,
        extra: Map.drop(raw, ["type", "subtype", "session_id", "model", "cwd"])
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :user_message,
        payload: %Payload.UserMessage{} = payload,
        raw: raw
      }) do
    [%MessageEvent{role: :user, content: content_text(payload.content), raw: raw || %{}}]
  end

  def project_core_event(%CoreEvent{
        kind: :thinking,
        payload: %Payload.Thinking{} = payload,
        raw: raw
      }) do
    [%ThinkingEvent{content: payload.content || "", metadata: payload.metadata, raw: raw || %{}}]
  end

  def project_core_event(%CoreEvent{
        kind: :assistant_delta,
        payload: %Payload.AssistantDelta{} = payload,
        raw: raw
      }) do
    [
      %MessageEvent{
        role: :assistant,
        content: payload.content || "",
        delta?: true,
        metadata: payload.metadata,
        raw: raw || %{}
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :assistant_message,
        payload: %Payload.AssistantMessage{} = payload,
        raw: raw
      }) do
    [
      %MessageEvent{
        role: :assistant,
        content: content_text(payload.content),
        final_snapshot?: final_snapshot?(payload.metadata),
        model: payload.model,
        metadata: payload.metadata,
        raw: raw || %{}
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :tool_use,
        payload: %Payload.ToolUse{} = payload,
        raw: raw
      }) do
    [
      %ToolUseEvent{
        tool_name: payload.tool_name || "",
        tool_call_id: payload.tool_call_id || "",
        input: normalize_map(payload.input),
        raw: raw || %{}
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :tool_result,
        payload: %Payload.ToolResult{} = payload,
        raw: raw
      }) do
    [
      %ToolResultEvent{
        tool_call_id: payload.tool_call_id || "",
        content: payload.content,
        is_error: payload.is_error,
        metadata: payload.metadata,
        raw: raw || %{}
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :result,
        payload: %Payload.Result{} = payload,
        raw: raw
      }) do
    output = normalize_map(payload.output)
    usage = normalize_map(Map.get(output, :usage, Map.get(output, "usage", %{})))

    [
      %ResultEvent{
        status: payload.status,
        stop_reason: payload.stop_reason,
        result: Map.get(output, :result, Map.get(output, "result")),
        usage: usage,
        duration_ms: Map.get(output, :duration_ms, Map.get(output, "duration_ms")),
        metadata: payload.metadata,
        raw: raw || %{}
      }
    ]
  end

  def project_core_event(%CoreEvent{kind: :error, payload: %Payload.Error{} = payload, raw: raw}) do
    [
      %ErrorEvent{
        severity: Atom.to_string(payload.severity || :error),
        message: payload.message,
        code: payload.code,
        metadata: payload.metadata,
        raw: raw || %{}
      }
    ]
  end

  def project_core_event(_event), do: []

  @spec final_event?(stream_event()) :: boolean()
  def final_event?(%ResultEvent{}), do: true
  def final_event?(%ErrorEvent{severity: "fatal"}), do: true
  def final_event?(_event), do: false

  defp content_text(content) when is_list(content) do
    Enum.map_join(content, "", fn
      %{"type" => "text", "text" => text} when is_binary(text) -> text
      %{type: "text", text: text} when is_binary(text) -> text
      value when is_binary(value) -> value
      _other -> ""
    end)
  end

  defp content_text(content) when is_binary(content), do: content
  defp content_text(_content), do: ""

  defp final_snapshot?(metadata) when is_map(metadata) do
    Map.get(metadata, :source) == :cursor_final_snapshot or
      Map.get(metadata, "source") in [:cursor_final_snapshot, "cursor_final_snapshot"]
  end

  defp final_snapshot?(_metadata), do: false

  defp normalize_map(%{} = map), do: map
  defp normalize_map(_value), do: %{}
end
