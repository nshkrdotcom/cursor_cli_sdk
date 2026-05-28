defmodule CursorCliSdk.Session do
  @moduledoc "Cursor session helpers."

  alias CursorCliSdk.{Command, Options, Stream}

  defmodule Entry do
    @moduledoc "Structured Cursor session list entry."

    @enforce_keys [:id]
    defstruct [:id, :label, :updated_at, raw_line: nil]

    @type t :: %__MODULE__{
            id: String.t(),
            label: String.t() | nil,
            updated_at: String.t() | nil,
            raw_line: String.t() | nil
          }
  end

  @spec list_sessions(keyword()) :: {:ok, [Entry.t()]} | {:error, CursorCliSdk.Error.t()}
  def list_sessions(opts \\ []) do
    with {:ok, output} <- Command.list_sessions(opts) do
      {:ok, parse_list_output(output)}
    end
  end

  @spec resume_session(String.t(), Options.t(), String.t()) ::
          Enumerable.t(CursorCliSdk.Types.stream_event())
  def resume_session(session_id, %Options{} = opts \\ %Options{}, prompt \\ "")
      when is_binary(session_id) and is_binary(prompt) do
    Stream.execute(prompt, %{opts | resume: session_id})
  end

  @spec continue_latest(Options.t(), String.t()) ::
          Enumerable.t(CursorCliSdk.Types.stream_event())
  def continue_latest(%Options{} = opts \\ %Options{}, prompt \\ "") when is_binary(prompt) do
    Stream.execute(prompt, %{opts | continue: true})
  end

  @spec parse_list_output(String.t()) :: [Entry.t()]
  def parse_list_output(output) when is_binary(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce([], fn line, acc ->
      case parse_line(line) do
        {:ok, entry} -> [entry | acc]
        :error -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp parse_line(""), do: :error

  defp parse_line(line) do
    cond do
      String.contains?(line, "\t") ->
        [id | rest] = String.split(line, "\t")
        {:ok, %Entry{id: id, label: Enum.join(rest, "\t"), raw_line: line}}

      String.contains?(line, " ") ->
        [id | rest] = String.split(line, " ", parts: 2)
        {:ok, %Entry{id: id, label: List.first(rest), raw_line: line}}

      true ->
        {:ok, %Entry{id: line, raw_line: line}}
    end
  end
end
