defmodule CursorCliSdkTest do
  use ExUnit.Case
  doctest CursorCliSdk

  test "loads the application namespace" do
    assert Code.ensure_loaded?(CursorCliSdk)
    assert Code.ensure_loaded?(CursorCliSdk.Application)
  end
end
