defmodule Acx.Model.ConfigEctoAdapter do
  @moduledoc false

  defstruct repo: nil, name: nil

  defmodule Model do
    use Ecto.Schema

    @primary_key false
    schema "model" do
      field(:owner, :string)
      field(:name, :string)
      field(:created_time, :string)
      field(:display_name, :string)
      field(:description, :string)
      field(:model_text, :string)
    end
  end

  def new(repo) do
    %__MODULE__{repo: repo}
  end

  defimpl Acx.Model.ConfigAdapter, for: Acx.Model.ConfigEctoAdapter do
    import Ecto.Query

    def load_config(%Acx.Model.ConfigEctoAdapter{repo: nil}) do
      {:error, "repo is not set"}
    end

    def load_config(%Acx.Model.ConfigEctoAdapter{name: nil}) do
      {:error, "name is not set"}
    end

    def load_config(%Acx.Model.ConfigEctoAdapter{repo: repo, name: name}) do
      try do
        config =
          Model
          |> from()
          |> where([c], c.name == ^name)
          |> repo.one()

        case config do
          %{model_text: config} -> {:ok, config}
          _ -> {:error, "config not found"}
        end
      rescue
        e ->
          {:error, "error loading config from model: #{inspect(e)}"}
      end
    end
  end
end
