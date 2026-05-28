defmodule CursorCliSdk.TestSupport do
  @moduledoc false

  def tmp_dir!(prefix) do
    dir =
      Path.join(
        System.tmp_dir!(),
        prefix <> "-" <> Integer.to_string(System.unique_integer([:positive]))
      )

    File.mkdir_p!(dir)
    dir
  end

  def fixture_path(name) do
    Path.expand("fixtures/#{name}", __DIR__)
  end

  def executable_script!(body) when is_binary(body) do
    dir = tmp_dir!("cursor-cli-sdk-script")
    path = Path.join(dir, "agent")
    File.write!(path, "#!/usr/bin/env bash\nset -euo pipefail\n" <> body)
    File.chmod!(path, 0o755)
    path
  end
end
