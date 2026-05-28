defmodule CursorCliSdk.MCP do
  @moduledoc "Cursor MCP command wrappers."

  alias CursorCliSdk.Command

  @spec list(keyword()) :: {:ok, String.t()} | {:error, CursorCliSdk.Error.t()}
  def list(opts \\ []), do: Command.run(["mcp", "list"], opts)

  @spec enable(String.t(), keyword()) :: {:ok, String.t()} | {:error, CursorCliSdk.Error.t()}
  def enable(name, opts \\ []) when is_binary(name),
    do: Command.run(["mcp", "enable", name], opts)

  @spec disable(String.t(), keyword()) :: {:ok, String.t()} | {:error, CursorCliSdk.Error.t()}
  def disable(name, opts \\ []) when is_binary(name),
    do: Command.run(["mcp", "disable", name], opts)

  @spec login(String.t(), keyword()) :: {:ok, String.t()} | {:error, CursorCliSdk.Error.t()}
  def login(name, opts \\ []) when is_binary(name), do: Command.run(["mcp", "login", name], opts)

  @spec list_tools(String.t(), keyword()) :: {:ok, String.t()} | {:error, CursorCliSdk.Error.t()}
  def list_tools(name, opts \\ []) when is_binary(name),
    do: Command.run(["mcp", "list-tools", name], opts)
end
