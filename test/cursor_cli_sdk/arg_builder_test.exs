defmodule CursorCliSdk.ArgBuilderTest do
  use ExUnit.Case, async: true

  alias CliSubprocessCore.ProviderProfiles.Cursor, as: CoreCursor
  alias CursorCliSdk.{ArgBuilder, Options}

  test "build_args/2 matches the core Cursor provider profile argv contract" do
    opts =
      %Options{
        model: "composer-2.5-fast",
        mode: :ask,
        cwd: "/tmp/work",
        permission_mode: :bypass,
        sandbox: "enabled",
        approve_mcps: true,
        worktree: "feature-x",
        worktree_base: "main",
        skip_worktree_setup: true,
        plugin_dirs: ["plugins/a", "plugins/b"],
        headers: [{"X-Test", "1"}]
      }
      |> Options.validate!()

    prompt = "Reply exactly once"

    assert {:ok, core_invocation} =
             CoreCursor.build_invocation(
               prompt: prompt,
               cli_path: "agent",
               model: opts.model,
               mode: opts.mode,
               cwd: opts.cwd,
               permission_mode: opts.permission_mode,
               sandbox: opts.sandbox,
               approve_mcps: opts.approve_mcps,
               worktree: opts.worktree,
               worktree_base: opts.worktree_base,
               skip_worktree_setup: opts.skip_worktree_setup,
               plugin_dirs: opts.plugin_dirs,
               headers: opts.headers
             )

    assert ArgBuilder.build_args(opts, prompt) == core_invocation.args
  end

  test "does not put api keys on argv" do
    opts = Options.validate!(%Options{api_key: "secret"})
    args = ArgBuilder.build_args(opts, "Hi")

    refute "secret" in args
    assert List.last(args) == "Hi"
  end
end
