prompt = "Reply with exactly: CURSOR_SDK_EXAMPLE_OK"

events =
  prompt
  |> CursorCliSdk.execute(%CursorCliSdk.Options{permission_mode: :bypass, timeout_ms: 120_000})
  |> Enum.to_list()

result =
  events
  |> Enum.find_value(fn
    %CursorCliSdk.Types.ResultEvent{result: text} when is_binary(text) -> text
    _event -> nil
  end)

IO.puts("event_count=#{length(events)}")
IO.puts("result_text=#{inspect(result)}")

unless result == "CURSOR_SDK_EXAMPLE_OK" do
  Mix.raise("simple stream result mismatch: #{inspect(result)}")
end

