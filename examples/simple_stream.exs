Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("simple_stream", config)

prompt = "Reply with exactly: CURSOR_SDK_EXAMPLE_OK"

events =
  prompt
  |> CursorCliSdk.execute(Helper.options(config))
  |> Enum.to_list()

IO.puts("event_count=#{length(events)}")
Helper.assert_result_text(events, "CURSOR_SDK_EXAMPLE_OK", "result_text")
