defmodule Acx.Persist.EnvAdapter do
  alias Acx.Persist.PersistAdapter

  # @callback load_policies() :: any()
  # @callback update_policy(id :: Integer.t, ptype :: String.t, v0 :: String.t, v1 :: String.t, v2 :: String.t, v3 :: String.t, v4 :: String.t, v5 :: String.t, v6 :: String.t) :: any()
  # @callback remove_policy(id :: Integrer.t) :: any()
  # @callback save_policy() :: any()

  defstruct content: nil

  def new() do
    %__MODULE__{content: nil}
  end

  def new(content) do
    %__MODULE__{content: content}
  end

  defimpl PersistAdapter, for: Acx.Persist.EnvAdapter do
    def load_policies(%Acx.Persist.EnvAdapter{content: nil}) do
      {:ok, []}
    end

    def load_policies(adapter) do
      policies =
        adapter.content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, ~r{,\s*}))

      {:ok, policies}
    end

    def load_policies(_adapter, content) do
      policies =
        content
        |> String.split("\n", trim: true)
        |> Enum.map(&String.split(&1, ~r{,\s*}))

      {:ok, policies}
    end

    def add_policy(adapter, _policy) do
      {:ok, adapter}
    end

    def save_policies(adapter, _policies) do
      {:ok, adapter}
    end

    def remove_policy(adapter, _policy) do
      {:ok, adapter}
    end

    def remove_filtered_policy(adapter, _key, _idx, _attrs) do
      {:ok, adapter}
    end

    def broadcast_policy_update(adapter, _policy, _action) do
      {:ok, adapter}
    end
  end
end
