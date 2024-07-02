defmodule Acx.Model.ConfigFileAdapter do
  @moduledoc false

  defstruct path: nil

  def new(path) do
    %__MODULE__{path: path}
  end

  defimpl Acx.Model.ConfigAdapter, for: Acx.Model.ConfigFileAdapter do
    def load_config(%Acx.Model.ConfigFileAdapter{path: nil}) do
      {:error, "path is not set"}
    end

    def load_config(%Acx.Model.ConfigFileAdapter{path: path}) do
      File.read(path)
    end
  end
end
