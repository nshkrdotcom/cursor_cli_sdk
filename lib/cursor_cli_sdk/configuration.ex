defmodule CursorCliSdk.Configuration do
  @moduledoc """
  Numeric runtime defaults for Cursor CLI SDK streams and helper commands.
  """

  @defaults [
    command_timeout_ms: 60_000,
    stream_timeout_ms: 300_000,
    default_timeout_ms: 300_000,
    transport_close_grace_ms: 2_000,
    transport_kill_grace_ms: 250,
    max_stderr_buffer_size: 262_144,
    max_inflight_headless: 4,
    spawn_stagger_ms: 75
  ]

  for {key, default} <- @defaults do
    @doc "Returns configured `#{key}`; defaults to `#{default}`."
    @spec unquote(key)() :: pos_integer()
    def unquote(key)(), do: Application.get_env(:cursor_cli_sdk, unquote(key), unquote(default))
  end

  @doc "Returns all Cursor SDK configuration keys and current values."
  @spec all() :: keyword(pos_integer())
  def all do
    Enum.map(@defaults, fn {key, _default} -> {key, apply(__MODULE__, key, [])} end)
  end
end
