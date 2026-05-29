defmodule CursorCliSdk.ArgBuilder do
  @moduledoc "Converts `CursorCliSdk.Options` into Cursor Agent CLI argv."

  alias CliSubprocessCore.ProviderFeatures
  alias CursorCliSdk.Options

  @spec build_args(Options.t(), String.t()) :: [String.t()]
  def build_args(%Options{} = opts, prompt) when is_binary(prompt) do
    []
    |> add_required_flags(opts)
    |> add_model(opts)
    |> add_workspace(opts)
    |> add_resume(opts)
    |> add_continue(opts)
    |> add_mode(opts)
    |> add_sandbox(opts)
    |> add_flag("--approve-mcps", opts.approve_mcps)
    |> add_worktree(opts.worktree)
    |> add_pair("--worktree-base", opts.worktree_base)
    |> add_flag("--skip-worktree-setup", opts.skip_worktree_setup)
    |> add_repeat("--plugin-dir", opts.plugin_dirs)
    |> add_headers(opts.headers)
    |> add_permission(opts.permission_mode)
    |> Kernel.++([prompt])
  end

  defp add_required_flags(args, %Options{trust: trust, output_format: output_format} = opts) do
    args =
      if trust do
        args ++ ["-p", "--trust", "--output-format", output_format]
      else
        args ++ ["-p", "--output-format", output_format]
      end

    if opts.stream_partial_output do
      args ++ ["--stream-partial-output"]
    else
      args
    end
  end

  defp add_model(args, %Options{} = opts), do: add_pair(args, "--model", resolved_model(opts))
  defp add_workspace(args, %Options{cwd: cwd}), do: add_pair(args, "--workspace", cwd)
  defp add_resume(args, %Options{resume: resume}), do: add_pair(args, "--resume", resume)

  defp add_continue(args, %Options{continue: continue?}),
    do: add_flag(args, "--continue", continue?)

  defp add_mode(args, %Options{mode: mode}) when mode in [nil, :agent, :default], do: args
  defp add_mode(args, %Options{mode: mode}), do: add_pair(args, "--mode", mode)

  defp add_sandbox(args, %Options{sandbox: true}), do: add_pair(args, "--sandbox", "enabled")
  defp add_sandbox(args, %Options{sandbox: false}), do: args
  defp add_sandbox(args, %Options{sandbox: nil}), do: args
  defp add_sandbox(args, %Options{sandbox: value}), do: add_pair(args, "--sandbox", value)

  defp add_worktree(args, true), do: args ++ ["--worktree"]
  defp add_worktree(args, value) when is_binary(value), do: add_pair(args, "--worktree", value)
  defp add_worktree(args, _value), do: args

  defp add_permission(args, permission_mode) do
    args ++ ProviderFeatures.permission_args(:cursor, permission_mode || :default)
  end

  defp add_flag(args, _flag, false), do: args
  defp add_flag(args, _flag, nil), do: args
  defp add_flag(args, flag, true), do: args ++ [flag]

  defp add_pair(args, _flag, value) when value in [nil, ""], do: args
  defp add_pair(args, flag, value), do: args ++ [flag, to_string(value)]

  defp add_repeat(args, _flag, []), do: args

  defp add_repeat(args, flag, values) when is_list(values) do
    Enum.reduce(values, args, fn
      value, acc when is_binary(value) and value != "" -> acc ++ [flag, value]
      _other, acc -> acc
    end)
  end

  defp add_headers(args, headers) when is_list(headers) do
    Enum.reduce(headers, args, fn
      {name, value}, acc when is_binary(name) and is_binary(value) ->
        acc ++ ["-H", "#{String.trim(name)}: #{String.trim(value)}"]

      value, acc when is_binary(value) and value != "" ->
        acc ++ ["-H", value]

      _other, acc ->
        acc
    end)
  end

  defp add_headers(args, _headers), do: args

  defp resolved_model(%Options{model_payload: payload}) when is_map(payload) do
    Map.get(payload, :resolved_model, Map.get(payload, "resolved_model"))
  end

  defp resolved_model(%Options{model: model}), do: model
end
