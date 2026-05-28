defmodule CursorCliSdk.ErrorKind do
  @moduledoc false

  @known [
    :auth_error,
    :cli_not_found,
    :command_failed,
    :command_timeout,
    :command_execution_failed,
    :config_error,
    :config_invalid,
    :execution_failed,
    :input_error,
    :invalid_event,
    :json_decode_error,
    :no_result,
    :parse_error,
    :stream_start_failed,
    :stream_timeout,
    :transport_error,
    :transport_exit,
    :unknown,
    :unknown_event_type,
    :user_cancelled
  ]

  @spec known() :: [atom()]
  def known, do: @known

  @spec from_external(term()) :: atom()
  def from_external(kind) when kind in @known, do: kind

  def from_external(kind) when is_binary(kind) do
    normalized =
      kind
      |> String.trim()
      |> String.downcase()
      |> String.replace("-", "_")

    Enum.find(@known, :unknown, &(Atom.to_string(&1) == normalized))
  end

  def from_external(_kind), do: :unknown
end
