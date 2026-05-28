defmodule CursorCliSdk.Types.ThinkingEvent do
  @moduledoc "Cursor thinking delta event."

  @enforce_keys [:content]
  defstruct type: :thinking, content: "", metadata: %{}, raw: %{}, extra: %{}

  @type t :: %__MODULE__{
          type: :thinking,
          content: String.t(),
          metadata: map(),
          raw: map(),
          extra: map()
        }
end
