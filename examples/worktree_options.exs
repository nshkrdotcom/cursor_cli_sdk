Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("worktree_options", config)

repo = Helper.tmp_dir!("cursor-worktree")
{_, 0} = System.cmd("git", ["init"], cd: repo, stderr_to_stdout: true)

args =
  Helper.render_args(
    %{config | cwd: config.cwd || repo},
    [worktree: "example-branch", worktree_base: "main", skip_worktree_setup: true],
    "Worktree render"
  )

Helper.assert_arg_pair(args, "--worktree", "example-branch")
Helper.assert_arg_pair(args, "--worktree-base", "main")
Helper.assert_arg(args, "--skip-worktree-setup")
