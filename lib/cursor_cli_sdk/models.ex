defmodule CursorCliSdk.Models do
  @moduledoc "Cursor model-list helpers."

  alias CursorCliSdk.Command

  defmodule Model do
    @moduledoc "Cursor model entry."
    @enforce_keys [:id]
    defstruct [:id, :label, default?: false, raw_line: nil]

    @type t :: %__MODULE__{
            id: String.t(),
            label: String.t() | nil,
            default?: boolean(),
            raw_line: String.t() | nil
          }
  end

  @spec list(keyword()) :: {:ok, [Model.t()]} | {:error, CursorCliSdk.Error.t()}
  def list(opts \\ []) do
    with {:ok, output} <- Command.models(opts) do
      {:ok, parse(output)}
    end
  end

  @spec default_model(keyword()) :: {:ok, String.t() | nil} | {:error, CursorCliSdk.Error.t()}
  def default_model(opts \\ []) do
    with {:ok, models} <- list(opts) do
      {:ok, models |> Enum.find(& &1.default?) |> then(&(&1 && &1.id))}
    end
  end

  @spec validate_model(String.t(), keyword()) :: :ok | {:error, term()}
  def validate_model(model, opts \\ []) when is_binary(model) do
    with {:ok, models} <- list(opts) do
      if Enum.any?(models, &(&1.id == model)), do: :ok, else: {:error, {:unknown_model, model}}
    end
  end

  @spec parse(String.t()) :: [Model.t()]
  def parse(output) when is_binary(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    default? = String.starts_with?(line, "*")
    cleaned = line |> String.trim_leading("*") |> String.trim()
    [id | rest] = String.split(cleaned, ~r/\s+/, parts: 2)
    %Model{id: id, label: List.first(rest), default?: default?, raw_line: line}
  end
end
