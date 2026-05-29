Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("plugin_dirs_and_headers", config)

plugin_dir = Helper.tmp_dir!("cursor-plugin")

args =
  Helper.render_args(
    config,
    [plugin_dirs: [plugin_dir], headers: [{"X-Example", "cursor"}]],
    "Plugin/header render"
  )

Helper.assert_arg_pair(args, "--plugin-dir", plugin_dir)
Helper.assert_arg_pair(args, "-H", "X-Example: cursor")
