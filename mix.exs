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
      {:zoi, "~> 0.18"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
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
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
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
        "guides/getting-started.md": [title: "Getting Started"],
        "guides/options.md": [title: "Options"],
        "guides/models.md": [title: "Models"],
        "guides/configuration.md": [title: "Configuration"],
        "guides/authentication.md": [title: "Authentication"],
        "guides/streaming.md": [title: "Streaming"],
        "guides/synchronous.md": [title: "Synchronous Runs"],
        "guides/sessions.md": [title: "Sessions"],
        "guides/error-handling.md": [title: "Error Handling"],
        "guides/architecture.md": [title: "Architecture"],
        "guides/governed-launch.md": [title: "Governed Launch"],
        "guides/asm-integration.md": [title: "ASM Integration"],
        "guides/mcp.md": [title: "MCP"],
        "guides/testing.md": [title: "Testing"],
        "guides/provider_behavior_manifest.md": [title: "Provider Behavior Manifest"],
        "examples/README.md": [title: "Examples", filename: "examples"],
        "CHANGELOG.md": [title: "Changelog"],
        LICENSE: [title: "License"]
      ],
      groups_for_extras: [
        "Project Overview": ["README.md"],
        Foundations: [
          "guides/getting-started.md",
          "guides/options.md",
          "guides/models.md",
          "guides/configuration.md",
          "guides/authentication.md"
        ],
        Runtime: [
          "guides/streaming.md",
          "guides/synchronous.md",
          "guides/sessions.md",
          "guides/error-handling.md"
        ],
        "Stack Integration": [
          "guides/architecture.md",
          "guides/governed-launch.md",
          "guides/asm-integration.md",
          "guides/mcp.md"
        ],
        Operations: [
          "guides/provider_behavior_manifest.md",
          "guides/testing.md"
        ],
        Examples: ["examples/README.md"],
        Reference: ["CHANGELOG.md", "LICENSE"]
      ],
      groups_for_modules: [
        "Public API": [
          CursorCliSdk
        ],
        Configuration: [
          CursorCliSdk.Options,
          CursorCliSdk.Configuration,
          CursorCliSdk.CLI,
          CursorCliSdk.ArgBuilder,
          CursorCliSdk.Models
        ],
        "Commands & Sessions": [
          CursorCliSdk.Command,
          CursorCliSdk.Session,
          CursorCliSdk.MCP
        ],
        "Governed & Runtime": [
          CursorCliSdk.GovernedLaunch,
          CursorCliSdk.Stream,
          CursorCliSdk.Runtime.CLI
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
        Errors: [CursorCliSdk.Error],
        Internals: [
          CursorCliSdk.Schema,
          CursorCliSdk.Schema.Options,
          CursorCliSdk.Application
        ]
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
      "examples.all": ["cmd bash examples/run_all.sh"],
      "test.live": ["test --include live"]
    ]
  end
end
