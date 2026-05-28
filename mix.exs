unless Code.ensure_loaded?(DependencySources) do
  Code.require_file("build_support/dependency_sources.exs", __DIR__)
end

defmodule CursorCliSdk.MixProject do
  use Mix.Project

  @app :cursor_cli_sdk
  @version "0.1.0"
  @source_url "https://github.com/nshkrdotcom/cursor_cli_sdk"
  @docs_url "https://hexdocs.pm/cursor_cli_sdk"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      docs: docs(),
      dialyzer: dialyzer(),
      name: "CursorCliSdk",
      source_url: @source_url,
      homepage_url: @docs_url
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {CursorCliSdk.Application, []}
    ]
  end

  def cli do
    [
      preferred_envs: [
        ci: :test,
        "test.live": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      DependencySources.dep(:cli_subprocess_core, __DIR__),
      {:jason, "~> 1.4"},
      {:zoi, "~> 0.17"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "Elixir SDK for the Cursor Agent CLI with streaming, governed launch, MCP helpers, and ASM integration."
  end

  defp package do
    [
      name: "cursor_cli_sdk",
      description: description(),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "HexDocs" => @docs_url,
        "Cursor CLI" => "https://cursor.com/docs/cli/overview"
      },
      maintainers: ["nshkrdotcom"],
      files:
        ~w(lib assets build_support guides examples mix.exs README.md LICENSE CHANGELOG.md .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "CursorCliSdk",
      source_ref: "main",
      source_url: @source_url,
      homepage_url: @docs_url,
      assets: %{"assets" => "assets"},
      logo: "assets/cursor_cli_sdk.svg",
      extras: [
        "README.md": [title: "Overview"],
        "guides/provider_behavior_manifest.md": [title: "Provider Behavior Manifest"],
        "CHANGELOG.md": [title: "Changelog"],
        LICENSE: [title: "License"]
      ],
      groups_for_extras: [
        "Project Overview": ["README.md"],
        Operations: ["guides/provider_behavior_manifest.md"],
        Reference: ["CHANGELOG.md", "LICENSE"]
      ],
      groups_for_modules: [
        "Public API": [
          CursorCliSdk,
          CursorCliSdk.Options,
          CursorCliSdk.Configuration,
          CursorCliSdk.CLI,
          CursorCliSdk.Command,
          CursorCliSdk.Session,
          CursorCliSdk.MCP,
          CursorCliSdk.Models
        ],
        Runtime: [
          CursorCliSdk.Stream,
          CursorCliSdk.Runtime.CLI,
          CursorCliSdk.ArgBuilder,
          CursorCliSdk.GovernedLaunch
        ],
        Types: [
          CursorCliSdk.Types,
          CursorCliSdk.Types.InitEvent,
          CursorCliSdk.Types.MessageEvent,
          CursorCliSdk.Types.ThinkingEvent,
          CursorCliSdk.Types.ToolUseEvent,
          CursorCliSdk.Types.ToolResultEvent,
          CursorCliSdk.Types.ResultEvent,
          CursorCliSdk.Types.ErrorEvent,
          CursorCliSdk.Types.Stats
        ],
        Errors: [CursorCliSdk.Error]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_core_path: "priv/plts/core",
      plt_local_path: "priv/plts"
    ]
  end

  defp aliases do
    [
      ci: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test",
        "credo --strict",
        "dialyzer"
      ],
      "test.live": ["test --include live"]
    ]
  end
end
