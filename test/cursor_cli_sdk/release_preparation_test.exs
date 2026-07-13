defmodule CursorCliSdk.ReleasePreparationTest do
  use ExUnit.Case, async: true

  @repo_root Path.expand("../..", __DIR__)
  @forbidden_deps [
    :agent_session_manager,
    :gemini_cli_sdk,
    :claude_agent_sdk,
    :codex_sdk,
    :amp_sdk,
    :antigravity_cli_sdk,
    :inference
  ]

  test "release metadata targets Cursor CLI SDK 0.1.0 on Elixir 1.19" do
    project = Mix.Project.config()

    assert project[:version] == "0.1.0"
    assert project[:elixir] == "~> 1.19"
    assert project[:docs][:source_ref] == "v0.1.0"
    assert project[:homepage_url] == "https://hex.pm/packages/cursor_cli_sdk"
  end

  test "publish mode selects cli_subprocess_core 0.2 from Hex" do
    assert "~> 0.2.0" ==
             @repo_root
             |> DependencySources.deps(publish?: true)
             |> Keyword.fetch!(:cli_subprocess_core)
  end

  test "package metadata is complete for the first Hex release" do
    package = Mix.Project.config()[:package]

    assert package[:name] == "cursor_cli_sdk"
    assert package[:licenses] == ["MIT"]
    assert package[:maintainers] == ["nshkrdotcom"]
    assert package[:links]["GitHub"] == "https://github.com/nshkrdotcom/cursor_cli_sdk"
    assert package[:links]["Hex"] == "https://hex.pm/packages/cursor_cli_sdk"
    assert package[:links]["HexDocs"] == "https://hexdocs.pm/cursor_cli_sdk"

    for required <-
          ~w(lib assets build_support guides examples mix.exs README.md LICENSE CHANGELOG.md) do
      assert required in package[:files]
    end
  end

  test "SDK public implementation exposes no raw Execution Plane modules" do
    for path <- Path.wildcard(Path.join(@repo_root, "lib/**/*.ex")) do
      source = File.read!(path)

      refute source =~ "ExecutionPlane.",
             "raw Execution Plane reference in #{Path.relative_to(path, @repo_root)}"

      refute source =~ "System.get_env",
             "runtime OS environment read in #{Path.relative_to(path, @repo_root)}"

      refute source =~ "System.fetch_env",
             "runtime OS environment read in #{Path.relative_to(path, @repo_root)}"

      refute source =~ "String.to_atom",
             "dynamic atom creation in #{Path.relative_to(path, @repo_root)}"
    end
  end

  test "SDK-direct promotion example does not import ASM" do
    source = File.read!(Path.join(@repo_root, "examples/promotion_path/sdk_direct_cursor.exs"))

    refute source =~ "alias ASM"
    refute source =~ "import ASM"
    refute source =~ "require ASM"
    refute source =~ "ASM."
  end

  test "cursor_cli_sdk does not declare ASM or sibling provider SDK dependencies" do
    declared = Mix.Project.config()[:deps] |> Enum.map(&dep_name/1) |> MapSet.new()

    for dep <- @forbidden_deps do
      refute MapSet.member?(declared, dep),
             "cursor_cli_sdk must not declare dependency on #{inspect(dep)}"
    end
  end

  defp dep_name({name, _requirement}), do: name
  defp dep_name({name, _requirement, _opts}), do: name
end
