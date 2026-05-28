defmodule CursorCliSdk.ModelsTest do
  use ExUnit.Case, async: true

  alias CursorCliSdk.Models

  test "parse/1 handles default marker and labels" do
    assert [
             %Models.Model{id: "composer-2.5-fast", default?: true},
             %Models.Model{id: "gpt-5", label: "GPT 5"}
           ] = Models.parse("* composer-2.5-fast Composer\n  gpt-5 GPT 5\n")
  end
end
