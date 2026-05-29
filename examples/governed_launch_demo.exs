alias CursorCliSdk.{GovernedLaunch, Options}

authority = [
  authority_ref: "authority://cursor/example",
  credential_lease_ref: "lease://cursor/example",
  connector_instance_ref: "connector-instance://cursor/example",
  connector_binding_ref: "connector-binding://cursor/example",
  provider_account_ref: "provider-account://cursor/example",
  native_auth_assertion_ref: "native-auth://cursor/example",
  target_ref: "target://cursor/example",
  operation_policy_ref: "operation-policy://cursor/example",
  command: "/authority/bin/agent",
  cwd: "/workspace",
  env: %{"CURSOR_API_KEY" => "materialized"},
  clear_env?: true
]

options = Options.new!(governed_authority: authority)

{:ok, invocation} = GovernedLaunch.invocation(["--version"], options)
IO.puts("governed_command=#{invocation.command}")
IO.puts("governed_cwd=#{invocation.cwd}")
IO.puts("governed_clear_env=#{inspect(invocation.clear_env?)}")

case Options.new(governed_authority: authority, cli_command: "agent") do
  {:error, error} -> IO.puts("smuggling_rejected=#{Exception.message(error)}")
  {:ok, _options} -> Mix.raise("expected governed cli_command smuggling rejection")
end
