Code.require_file("support/example_helper.exs", __DIR__)

alias CursorCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("model_selection", config)

{:ok, models} = CursorCliSdk.Models.list(Helper.command_opts(config))
default_model = Enum.find_value(models, fn model -> if model.default?, do: model.id end)
selected_model = config.model || default_model || "auto"

IO.puts("model_count=#{length(models)}")
IO.puts("requested_model=#{selected_model}")

options = Helper.options(config, model: selected_model)

:ok = CursorCliSdk.Models.validate_model(selected_model, Helper.command_opts(config))

if options.model != selected_model do
  :ok = CursorCliSdk.Models.validate_model(options.model, Helper.command_opts(config))
end

{:ok, rendered} =
  CursorCliSdk.Runtime.CLI.render_for_test(
    prompt: "Model selection render",
    options: options
  )

IO.puts("effective_model=#{options.model}")
Helper.assert_arg_pair(rendered.args, "--model", options.model)
