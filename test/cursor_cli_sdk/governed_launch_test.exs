defmodule CursorCliSdk.GovernedLaunchTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.{GovernedLaunch, Options}

  defp authority do
    [
      authority_ref: "authority://cli/cursor",
      credential_lease_ref: "lease://cursor/1",
      connector_instance_ref: "connector-instance://cursor/1",
      connector_binding_ref: "connector-binding://cursor/1",
      provider_account_ref: "provider-account://cursor/1",
      native_auth_assertion_ref: "native-auth-assertion://cursor/1",
      target_ref: "target://local/1",
      operation_policy_ref: "operation-policy://cursor/1",
      command: "/authority/bin/agent",
      cwd: "/workspace",
      env: %{"CURSOR_API_KEY" => "materialized"},
      clear_env?: true
    ]
  end

  test "invocation uses only authority launch material" do
    opts = Options.validate!(%Options{governed_authority: authority()})

    assert {:ok, invocation} = GovernedLaunch.invocation(["-p", "Hi"], opts)
    assert invocation.command == "/authority/bin/agent"
    assert invocation.cwd == "/workspace"
    assert invocation.env == %{"CURSOR_API_KEY" => "materialized"}
    assert invocation.clear_env? == true
  end

  test "governed options reject command and execution-surface smuggling" do
    assert_raise ArgumentError, ~r/:cli_command/, fn ->
      Options.validate!(%Options{governed_authority: authority(), cli_command: "agent"})
    end

    assert_raise ArgumentError, ~r/:execution_surface/, fn ->
      Options.validate!(%Options{
        governed_authority: authority(),
        execution_surface: CliSubprocessCore.ExecutionSurface.new!(surface_kind: :ssh_exec)
      })
    end
  end

  test "governed command options reject api key smuggling" do
    assert {:error, {:governed_launch_smuggling, :api_key}} =
             GovernedLaunch.validate_command_options(
               governed_authority: authority(),
               api_key: "secret"
             )
  end
end
