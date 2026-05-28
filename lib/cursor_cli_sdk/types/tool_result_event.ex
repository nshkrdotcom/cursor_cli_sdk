defmodule CursorCliSdk.Types.ToolResultEvent do
  @moduledoc "Cursor tool-call completion event."

  @enforce_keys [:tool_call_id]
  defstruct type: :tool_result,
            tool_call_id: "",
            content: nil,
            is_error: false,
            metadata: %{},
            raw: %{},
            extra: %{}

  @type t :: %__MODULE__{
          type: :tool_result,
          tool_call_id: String.t(),
          content: term(),
          is_error: boolean(),
          metadata: map(),
          raw: map(),
          extra: map()
        }
end
