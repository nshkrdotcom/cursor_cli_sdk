defmodule CursorCliSdk.Runtime.CLITest do
  use ExUnit.Case, async: true

  alias CliSubprocessCore.ProviderProfiles.Cursor, as: CoreCursor
  alias CursorCliSdk.{Options, Runtime.CLI}
  alias CursorCliSdk.Types.ResultEvent

  test "render_for_test/1 exposes normalized invocation details" do
    assert {:ok, rendered} =
             CLI.render_for_test(
               prompt: "Hi",
               options: %Options{
                 cli_command: "agent",
                 cwd: "/tmp/work",
                 api_key: "secret",
                 permission_mode: :bypass
               }
             )

    assert rendered.provider == :cursor
    assert rendered.cwd == "/tmp/work"
    assert rendered.env["CURSOR_API_KEY"] == "secret"
    assert "--force" in rendered.args
    refute "secret" in rendered.args
  end

  test "start_session/1 rejects untagged subscribers" do
    assert {:error, %ArgumentError{} = error} =
             CLI.start_session(
               prompt: "Hi",
               options: %Options{cli_command: "agent"},
               subscriber: self()
             )

    assert Exception.message(error) =~ "subscriber must be a tagged {pid, reference()} tuple"
  end

  test "project_event/2 maps core result events once" do
    [event] =
      ~s({"type":"result","subtype":"success","duration_ms":1,"is_error":false,"result":"OK","session_id":"s","usage":{"inputTokens":1,"outputTokens":1}})
      |> decode_core()

    {[%ResultEvent{result: "OK"}], state} = CLI.project_event(event, CLI.new_projection_state())
    assert {[], ^state} = CLI.project_event(event, state)
  end

  defp decode_core(line) do
    {events, _state} =
      CoreCursor.decode_stdout(
        line,
        CoreCursor.init_parser_state([])
      )

    events
  end
end
