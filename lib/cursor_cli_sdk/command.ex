defmodule CursorCliSdk.Command do
  @moduledoc "Synchronous Cursor command helpers built on `cli_subprocess_core`."

  alias CliSubprocessCore.Command, as: CoreCommand
  alias CliSubprocessCore.Command.Error, as: CoreCommandError
  alias CliSubprocessCore.Command.RunResult
  alias CliSubprocessCore.ProcessExit
  alias CliSubprocessCore.ProviderCLI
  alias CursorCliSdk.{CLI, Configuration, Error, GovernedLaunch}

  @type run_opt ::
          {:timeout, non_neg_integer() | :infinity}
          | {:stdin, iodata()}
          | {:cd, String.t()}
          | {:cli_command, String.t()}
          | {:governed_authority, CliSubprocessCore.GovernedAuthority.t() | keyword() | map()}
          | {:execution_surface, CliSubprocessCore.ExecutionSurface.t() | map() | keyword()}

  @spec run([String.t()], [run_opt()]) :: {:ok, String.t()} | {:error, Error.t()}
  def run(args, opts \\ []) when is_list(args) and is_list(opts) do
    with :ok <- GovernedLaunch.validate_command_options(opts),
         {:ok, authority} <- GovernedLaunch.authority(opts),
         {:ok, invocation} <- invocation(args, opts, authority) do
      do_run(invocation, args, opts)
    else
      {:error, %Error{} = error} -> {:error, error}
      {:error, reason} -> {:error, Error.normalize(reason, kind: :config_invalid)}
    end
  end

  @spec version(keyword()) :: {:ok, String.t()} | {:error, Error.t()}
  def version(opts \\ []), do: run(["--version"], opts)

  @spec models(keyword()) :: {:ok, String.t()} | {:error, Error.t()}
  def models(opts \\ []), do: run(["models"], opts)

  @spec create_chat(keyword()) :: {:ok, String.t()} | {:error, Error.t()}
  def create_chat(opts \\ []), do: run(["create-chat"], opts)

  @spec status(keyword()) :: {:ok, String.t()} | {:error, Error.t()}
  def status(opts \\ []), do: run(["status"], opts)

  @spec list_sessions(keyword()) :: {:ok, String.t()} | {:error, Error.t()}
  def list_sessions(opts \\ []), do: run(["ls"], opts)

  defp invocation(args, opts, nil) do
    with {:ok, command} <- CLI.resolve(opts) do
      {:ok, CoreCommand.new(command, args, cwd: Keyword.get(opts, :cd))}
    end
  end

  defp invocation(args, opts, _authority), do: GovernedLaunch.invocation(args, opts)

  defp do_run(invocation, args, opts) do
    timeout = Keyword.get(opts, :timeout, Configuration.command_timeout_ms())

    case CoreCommand.run(invocation,
           stdin: Keyword.get(opts, :stdin),
           timeout: timeout,
           stderr: :separate
         ) do
      {:ok, %RunResult{} = result} ->
        handle_run_result(result, invocation.command, args, opts)

      {:error, %CoreCommandError{} = error} ->
        {:error,
         Error.normalize(error.reason,
           kind: :command_execution_failed,
           context: error.context
         )}
    end
  end

  defp handle_run_result(%RunResult{exit: exit} = result, command, args, opts) do
    if ProcessExit.successful?(exit) do
      {:ok, result |> combined_output() |> String.trim()}
    else
      failure =
        ProviderCLI.runtime_failure(:cursor, exit,
          execution_surface: Keyword.get(opts, :execution_surface),
          cwd: Keyword.get(opts, :cd),
          stderr: combined_output(result),
          command: command
        )

      {:error,
       Error.from_runtime_failure(failure,
         context: %{program: command, args: args},
         exit_code: ProcessExit.code(exit)
       )}
    end
  end

  defp combined_output(%RunResult{} = result), do: result.stdout <> result.stderr
end
