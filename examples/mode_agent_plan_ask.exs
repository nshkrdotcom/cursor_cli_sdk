Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("mode_agent_plan_ask", config)

agent_args = Helper.render_args(config, [mode: :agent], "Agent mode render")
plan_args = Helper.render_args(config, [mode: :plan], "Plan mode render")
ask_args = Helper.render_args(config, [mode: :ask], "Ask mode render")

if "--mode" in agent_args do
  Mix.raise("agent mode should not render an explicit --mode flag: #{inspect(agent_args)}")
end

Helper.assert_arg_pair(plan_args, "--mode", "plan")
Helper.assert_arg_pair(ask_args, "--mode", "ask")
