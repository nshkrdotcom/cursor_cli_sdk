Code.require_file("../support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("promotion_path/sdk_direct_cursor", config)

Helper.assert_exact_text(
  CursorCliSdk.run("Reply with exactly: CURSOR_SDK_DIRECT_OK", Helper.options(config)),
  "CURSOR_SDK_DIRECT_OK",
  "sdk_direct_text"
)
