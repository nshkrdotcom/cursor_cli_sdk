defmodule CursorCliSdk.Types.Stats do
  @moduledoc "Aggregated stream stats."

  defstruct input_tokens: 0, output_tokens: 0, duration_ms: nil

  @type t :: %__MODULE__{
          input_tokens: non_neg_integer(),
          output_tokens: non_neg_integer(),
          duration_ms: non_neg_integer() | nil
        }
end
