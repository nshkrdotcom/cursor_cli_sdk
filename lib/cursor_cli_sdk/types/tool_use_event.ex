defmodule CursorCliSdk.Types.ToolUseEvent do
  @moduledoc "Cursor tool-call start event."

  @enforce_keys [:tool_name, :tool_call_id]
  defstruct type: :tool_use, tool_name: "", tool_call_id: "", input: %{}, raw: %{}, extra: %{}

  @type t :: %__MODULE__{
          type: :tool_use,
          tool_name: String.t(),
          tool_call_id: String.t(),
          input: map(),
          raw: map(),
          extra: map()
        }
end
