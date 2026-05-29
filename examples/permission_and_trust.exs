Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("permission_and_trust", config)

args =
  Helper.render_args(
    config,
    [permission_mode: :bypass, trust: false, mode: :plan],
    "Permission render"
  )

Helper.assert_arg(args, "--force")
Helper.assert_arg_pair(args, "--mode", "plan")

if "--trust" in args do
  Mix.raise("trust: false should omit --trust: #{inspect(args)}")
end

IO.puts("trust_flag_omitted=true")
