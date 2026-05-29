Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("session_resume_continue", config)

resume_args = Helper.render_args(config, [resume: "cursor-session-example"], "Resume render")
continue_args = Helper.render_args(config, [continue: true], "Continue render")

Helper.assert_arg_pair(resume_args, "--resume", "cursor-session-example")
Helper.assert_arg(continue_args, "--continue")

case CursorCliSdk.Session.list_sessions(Helper.command_opts(config)) do
  {:ok, sessions} -> IO.puts("listed_sessions=#{length(sessions)}")
  {:error, error} -> Mix.raise("list_sessions failed: #{Exception.message(error)}")
end
