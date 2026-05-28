defmodule CursorCliSdk.Schema.Options do
  @moduledoc false

  alias CliSubprocessCore.{ExecutionSurface, Schema.Conventions}
  alias CursorCliSdk.{Configuration, Options, Schema}

  @mode_values [:agent, :ask, :plan]
  @permission_values [:default, :bypass, :plan]

  @spec schema() :: Zoi.schema()
  def schema do
    Zoi.map(
      %{
        execution_surface: execution_surface_schema(),
        governed_authority: Conventions.optional_any(),
        model_payload: Conventions.optional_any(),
        model: Conventions.optional_trimmed_string(),
        mode: mode_schema(),
        api_key: Conventions.optional_trimmed_string(),
        cli_command: Conventions.optional_trimmed_string(),
        cwd: Conventions.optional_trimmed_string(),
        permission_mode: permission_schema(),
        trust: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), true),
        output_format: output_format_schema(),
        stream_partial_output: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), true),
        resume: Conventions.optional_trimmed_string(),
        continue: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        sandbox: Conventions.optional_any(),
        approve_mcps: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        worktree: Conventions.optional_any(),
        worktree_base: Conventions.optional_trimmed_string(),
        skip_worktree_setup: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        plugin_dirs: Conventions.string_list([]),
        headers: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.array(Zoi.any()))), []),
        timeout_ms: positive_integer_schema(:timeout_ms, Configuration.default_timeout_ms()),
        max_stderr_buffer_bytes:
          positive_integer_schema(
            :max_stderr_buffer_bytes,
            Configuration.max_stderr_buffer_size()
          ),
        env: Conventions.default_map(%{})
      },
      unrecognized_keys: :error
    )
  end

  @spec parse(Options.t() | map()) ::
          {:ok, Options.t()}
          | {:error, {:invalid_options, CliSubprocessCore.Schema.error_detail()}}
  def parse(%Options{} = opts), do: parse(Map.from_struct(opts))

  def parse(attrs) when is_map(attrs) do
    case Schema.parse(schema(), attrs, :invalid_options) do
      {:ok, parsed} -> {:ok, project(parsed)}
      {:error, {:invalid_options, details}} -> {:error, {:invalid_options, details}}
    end
  end

  @doc false
  def normalize_positive_integer(value, opts), do: normalize_positive_integer(value, :value, opts)

  @doc false
  def normalize_positive_integer(value, field, _opts) do
    if is_integer(value) and value > 0 do
      {:ok, value}
    else
      {:error, "#{field} must be positive, got #{inspect(value)}"}
    end
  end

  @doc false
  def normalize_execution_surface(value, opts), do: normalize_execution_surface(value, [], opts)

  @doc false
  def normalize_execution_surface(value, _args, _opts) do
    case Options.normalize_execution_surface(value) do
      {:ok, surface} ->
        {:ok, surface}

      {:error, {:invalid_execution_surface, other}} ->
        {:error, "invalid execution_surface: #{inspect(other)}"}

      {:error, reason} ->
        {:error, "invalid execution_surface: #{inspect(reason)}"}
    end
  end

  @doc false
  def normalize_output_format(value, opts),
    do: normalize_output_format(value, "stream-json", opts)

  @doc false
  def normalize_output_format(value, default, _opts) do
    case value do
      nil -> {:ok, default}
      binary when is_binary(binary) -> {:ok, String.trim(binary)}
      other -> {:error, "output_format must be a string, got #{inspect(other)}"}
    end
  end

  defp execution_surface_schema do
    Zoi.default(
      Zoi.optional(
        Zoi.nullish(Zoi.any() |> Zoi.transform({__MODULE__, :normalize_execution_surface, []}))
      ),
      %ExecutionSurface{}
    )
  end

  defp mode_schema, do: Conventions.default_enum(@mode_values, :agent)
  defp permission_schema, do: Conventions.default_enum(@permission_values, :default)

  defp output_format_schema do
    Zoi.default(
      Zoi.optional(
        Zoi.nullish(
          Zoi.any()
          |> Zoi.transform({__MODULE__, :normalize_output_format, ["stream-json"]})
        )
      ),
      "stream-json"
    )
  end

  defp positive_integer_schema(field, default) do
    Zoi.default(
      Zoi.optional(
        Zoi.nullish(
          Zoi.any()
          |> Zoi.transform({__MODULE__, :normalize_positive_integer, [field]})
        )
      ),
      default
    )
  end

  defp project(parsed) do
    %Options{
      execution_surface: Map.get(parsed, :execution_surface, %ExecutionSurface{}),
      governed_authority: Map.get(parsed, :governed_authority),
      model_payload: Map.get(parsed, :model_payload),
      model: blank_to_nil(Map.get(parsed, :model)),
      mode: Map.get(parsed, :mode, :agent),
      api_key: blank_to_nil(Map.get(parsed, :api_key)),
      cli_command: blank_to_nil(Map.get(parsed, :cli_command)),
      cwd: blank_to_nil(Map.get(parsed, :cwd)),
      permission_mode: Map.get(parsed, :permission_mode, :default),
      trust: Map.get(parsed, :trust, true),
      output_format: blank_to_default(Map.get(parsed, :output_format), "stream-json"),
      stream_partial_output: Map.get(parsed, :stream_partial_output, true),
      resume: blank_to_nil(Map.get(parsed, :resume)),
      continue: Map.get(parsed, :continue, false),
      sandbox: Map.get(parsed, :sandbox),
      approve_mcps: Map.get(parsed, :approve_mcps, false),
      worktree: Map.get(parsed, :worktree),
      worktree_base: blank_to_nil(Map.get(parsed, :worktree_base)),
      skip_worktree_setup: Map.get(parsed, :skip_worktree_setup, false),
      plugin_dirs: Map.get(parsed, :plugin_dirs, []),
      headers: Map.get(parsed, :headers, []),
      timeout_ms: Map.get(parsed, :timeout_ms, Configuration.default_timeout_ms()),
      max_stderr_buffer_bytes:
        Map.get(parsed, :max_stderr_buffer_bytes, Configuration.max_stderr_buffer_size()),
      env: Map.get(parsed, :env, %{})
    }
  end

  defp blank_to_nil(value) when value in [nil, ""], do: nil
  defp blank_to_nil(value), do: value

  defp blank_to_default(value, default) when value in [nil, ""], do: default
  defp blank_to_default(value, _default), do: value
end
