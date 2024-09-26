# defmodule Acx.Model.ConfigEctoAdapter do
#  @moduledoc false
#
#  defstruct repo: nil, model_table_name: nil, model_name: nil
#
#  defmodule Model do
#    use Ecto.Schema
#
#    @default_model_table_name "model"
#
#    @primary_key false
#    schema @default_model_table_name do
#      field(:owner, :string)
#      field(:name, :string)
#      field(:created_time, :string)
#      field(:display_name, :string)
#      field(:description, :string)
#      field(:model_text, :string)
#    end
#
#    @spec get_default_model_table_name() :: String.t()
#    def get_default_model_table_name() do
#      @default_model_table_name
#    end
#  end
#
#  def new(repo) do
#    %__MODULE__{repo: repo}
#  end
#
#  defimpl Acx.Model.ConfigAdapter, for: Acx.Model.ConfigEctoAdapter do
#    import Ecto.Query
#
#    alias Acx.Model.ConfigEctoAdapter
#
#    def load_config(%ConfigEctoAdapter{repo: nil}) do
#      {:error, "repo is not set"}
#    end
#
#    def load_config(%ConfigEctoAdapter{model_name: nil}) do
#      {:error, "model_name is not set"}
#    end
#
#    def load_config(%ConfigEctoAdapter{
#          repo: repo,
#          model_name: name,
#          model_table_name: model_table_name
#        }) do
#      model_table_name = model_table_name || Model.get_default_model_table_name()
#
#      query =
#        from(m in {model_table_name, Model},
#          select: m,
#          where: m.name == ^name
#        )
#
#      try do
#        case repo.one(query) do
#          %{model_text: config} -> {:ok, config}
#          _ -> {:error, "config not found"}
#        end
#      rescue
#        e ->
#          IO.inspect(e)
#          {:error, "error loading config from model: #{inspect(e)}"}
#      end
#    end
#  end
# end
