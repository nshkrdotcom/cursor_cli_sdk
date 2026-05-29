Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("sync_run", config)

Helper.assert_exact_text(
  CursorCliSdk.run("Reply with exactly: CURSOR_SDK_RUN_OK", Helper.options(config)),
  "CURSOR_SDK_RUN_OK",
  "run_text"
)
