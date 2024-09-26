defmodule Acx.Model.ConfigEnvAdapter do
  @moduledoc false

  defstruct content: nil

  def new(model_as_string) do
    %__MODULE__{content: model_as_string}
  end

  defimpl Acx.Model.ConfigAdapter, for: Acx.Model.ConfigEnvAdapter do
    def load_config(%Acx.Model.ConfigEnvAdapter{content: nil}) do
      {:error, "content is not set"}
    end

    def load_config(%Acx.Model.ConfigEnvAdapter{content: content}) do
      {:ok, content}
    end
  end
end
