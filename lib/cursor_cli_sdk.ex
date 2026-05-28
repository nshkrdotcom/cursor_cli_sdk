defmodule CursorCliSdk do
  @moduledoc """
  Elixir SDK for the Cursor Agent CLI (`agent`).

  The primary API is `execute/2` for streams and `run/2` for one-shot text
  results.
  """

  alias CursorCliSdk.{Error, Options, Stream}
  alias CursorCliSdk.Types.{ErrorEvent, MessageEvent, ResultEvent}

  @spec execute(String.t(), Options.t()) :: Enumerable.t(CursorCliSdk.Types.stream_event())
  def execute(prompt, %Options{} = options \\ %Options{}) when is_binary(prompt) do
    Stream.execute(prompt, options)
  end

  @spec run(String.t(), Options.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def run(prompt, %Options{} = options \\ %Options{}) when is_binary(prompt) do
    prompt
    |> execute(options)
    |> Enum.reduce(nil, fn
      %ResultEvent{status: :completed, result: result}, _acc when is_binary(result) ->
        {:ok, result}

      %ResultEvent{status: :completed}, acc ->
        acc

      %ErrorEvent{} = event, _acc ->
        {:error,
         Error.new(
           kind: event.code || :execution_failed,
           message: event.message,
           details: event.stderr
         )}

      %MessageEvent{role: :assistant, delta?: true, content: content}, nil ->
        {:ok, content}

      %MessageEvent{role: :assistant, delta?: true, content: content}, {:ok, acc} ->
        {:ok, acc <> content}

      _event, acc ->
        acc
    end)
    |> case do
      {:ok, text} ->
        {:ok, text}

      {:error, %Error{} = error} ->
        {:error, error}

      nil ->
        {:error, Error.new(kind: :no_result, message: "No result received from Cursor stream")}
    end
  end

  defdelegate create_options(attrs), to: Options, as: :new
end
