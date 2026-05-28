prompt = "Reply with exactly: CURSOR_SDK_DIRECT_OK"

case CursorCliSdk.run(prompt, %CursorCliSdk.Options{permission_mode: :bypass, timeout_ms: 120_000}) do
  {:ok, "CURSOR_SDK_DIRECT_OK"} ->
    IO.puts("sdk_direct_text=\"CURSOR_SDK_DIRECT_OK\"")

  {:ok, other} ->
    Mix.raise("sdk direct result mismatch: #{inspect(other)}")

  {:error, error} ->
    Mix.raise("sdk direct failed: #{Exception.message(error)}")
end

