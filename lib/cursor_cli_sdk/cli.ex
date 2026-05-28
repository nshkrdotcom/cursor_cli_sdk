defmodule CursorCliSdk.CLI do
  @moduledoc "Cursor Agent CLI command resolution and invocation rendering."

  alias CliSubprocessCore.{Command, CommandSpec, ProviderCLI}
  alias CursorCliSdk.{ArgBuilder, Error, GovernedLaunch, Options}
  alias CursorCliSdk.Runtime.CLI, as: RuntimeCLI

  @spec resolve(keyword()) :: {:ok, CommandSpec.t()} | {:error, Error.t()}
  def resolve(opts \\ []) when is_list(opts) do
    provider_opts =
      opts
      |> Keyword.take([:cli_command, :execution_surface])
      |> maybe_put_cli_path(Keyword.get(opts, :cli_command))

    case ProviderCLI.resolve(:cursor, provider_opts, extra_keys: [:cli_path]) do
      {:ok, spec} -> {:ok, spec}
      {:error, reason} -> {:error, Error.normalize(reason, kind: :cli_not_found)}
    end
  end

  @spec build_invocation(keyword()) :: {:ok, Command.t()} | {:error, term()}
  def build_invocation(opts) when is_list(opts) do
    prompt = Keyword.fetch!(opts, :prompt)
    options = opts |> Keyword.get(:options, %Options{}) |> Options.validate!()
    args = ArgBuilder.build_args(options, prompt)

    with {:ok, authority} <- GovernedLaunch.authority(options) do
      case authority do
        nil -> standalone_invocation(args, options)
        _ -> GovernedLaunch.invocation(args, options)
      end
    end
  rescue
    error in [ArgumentError, KeyError] -> {:error, error}
  end

  @spec build_session_options(String.t(), Options.t(), keyword()) :: keyword()
  def build_session_options(prompt, %Options{} = options, opts \\ []) do
    [
      provider: :cursor,
      profile: RuntimeCLI.Profile,
      prompt: prompt,
      options: options,
      metadata: Keyword.get(opts, :metadata, %{}),
      subscriber: Keyword.get(opts, :subscriber),
      session_event_tag: Keyword.get(opts, :session_event_tag, RuntimeCLI.session_event_tag())
    ]
    |> Keyword.reject(fn {_key, value} -> is_nil(value) end)
  end

  @spec command_args(CommandSpec.t(), [String.t()]) :: [String.t()]
  def command_args(%CommandSpec{} = command, args) when is_list(args) do
    CommandSpec.command_args(command, args)
  end

  defp standalone_invocation(args, %Options{} = options) do
    with {:ok, command_spec} <-
           resolve(cli_command: options.cli_command, execution_surface: options.execution_surface) do
      {:ok,
       Command.new(command_spec, args,
         cwd: options.cwd,
         env: build_env(options)
       )}
    end
  end

  @spec build_env(Options.t()) :: map()
  def build_env(%Options{api_key: api_key, env: env}) do
    env
    |> normalize_env()
    |> maybe_put_env("CURSOR_API_KEY", api_key)
  end

  defp maybe_put_cli_path(opts, nil), do: opts
  defp maybe_put_cli_path(opts, cli_command), do: Keyword.put(opts, :cli_path, cli_command)

  defp normalize_env(env) when is_map(env) do
    Map.new(env, fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  defp normalize_env(_env), do: %{}

  defp maybe_put_env(env, _key, nil), do: env
  defp maybe_put_env(env, _key, ""), do: env
  defp maybe_put_env(env, key, value), do: Map.put(env, key, value)
end
