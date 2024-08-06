defmodule Acx.Persist.RedisAdapter do
  @moduledoc """
  This module defines an adapter for persisting the list of policies
  to a redis.
  """

  @default_casbin_rule_prefix "casbin:policies:"

  defstruct conn: nil, casbin_rule_prefix: @default_casbin_rule_prefix

  @type t :: %__MODULE__{
          conn: Redix.connection(),
          casbin_rule_prefix: String.t()
        }

  def new(conn, casbin_rule_prefix \\ @default_casbin_rule_prefix) do
    %__MODULE__{conn: conn, casbin_rule_prefix: casbin_rule_prefix}
  end

  defimpl Acx.Persist.PersistAdapter, for: Acx.Persist.RedisAdapter do
    alias Acx.Persist.RedisAdapter

    @doc """
    Queries the list of policy rules from the redis and returns them
    as a list of strings.

    ## Examples

        iex> PersistAdapter.load_policies(%Acx.Persist.RedisAdapter{conn: nil})
        ...> {:error, "conn is not set"}
    """
    @spec load_policies(RedisAdapter.t()) :: {:ok, [Acx.Model.Policy.t()]} | {:error, String.t()}
    def load_policies(%RedisAdapter{conn: nil}) do
      {:error, "conn is not set"}
    end

    def load_policies(%RedisAdapter{conn: conn, casbin_rule_prefix: casbin_rule_prefix}) do
      case Redix.command(conn, ["KEYS", "casbin:policies:*"]) do
        {:ok, policies} ->
          policies
          |> Enum.map(&String.replace_prefix(&1, casbin_rule_prefix, ""))
          |> Enum.map(&String.split(&1, ":"))
          |> then(&{:ok, &1})

        {:error, msg} ->
          {:error, "Error loading policies: #{inspect(msg)}"}
      end
    end

    @doc """
    Uses the configured conn to insert a Policy into the casbin_rule table.

    Returns an error if conn is not set.

    ## Examples

        iex> PersistAdapter.RedisAdapter(
        ...>    %Acx.Persist.EctoAdapter{},
        ...>    {:p, ["user", "file", "read"]})
        ...> {:error, "conn is not set"}
    """
    def add_policy(%RedisAdapter{conn: nil}, _) do
      {:error, "conn is not set"}
    end

    def add_policy(
          %RedisAdapter{conn: conn, casbin_rule_prefix: casbin_rule_prefix} = adapter,
          {ptype, attrs} = _policy
        ) do
      {attrs, value} =
        if Keyword.keyword?(attrs) do
          {eft, attrs} = Keyword.pop(attrs, :eft, "allow")
          attrs = Keyword.values(attrs)
          value = if eft == "allow", do: "1", else: "0"
          {attrs, value}
        else
          {attrs, "1"}
        end

      rule = Enum.join([ptype | attrs], ":")
      key = "#{casbin_rule_prefix}#{rule}"

      case Redix.command(conn, ["SET", key, value]) do
        {:ok, _} -> {:ok, adapter}
        {:error, msg} -> {:error, "Error adding policy: #{inspect(msg)}"}
      end
    end

    @doc """
    Removes all rules matching the provided attributes. If a subset of attributes
    are provided it will remove all matching records, i.e. if only a subj is provided
    all records including that subject will be removed from storage

    Returns an error if conn is not set.

    ## Examples

        iex> PersistAdapter.remove_policy(
        ...>    %Acx.Persist.RedisAdapter{},
        ...>    {:p, ["user", "file", "read"]})
        ...> {:error, "conn is not set"}
    """
    def remove_policy(%RedisAdapter{conn: nil}, _) do
      {:error, "conn is not set"}
    end

    def remove_policy(
          %RedisAdapter{conn: conn, casbin_rule_prefix: casbin_rule_prefix} = adapter,
          {ptype, attrs} = _policy
        ) do
      rule = Enum.join([ptype | attrs], ":")
      key = "#{casbin_rule_prefix}#{rule}"

      case Redix.command(conn, ["DEL", key]) do
        {:error, msg} -> {:error, "Error removing policy: #{inspect(msg)}"}
        _ -> {:ok, adapter}
      end
    end

    def remove_filtered_policy(
          %RedisAdapter{conn: conn, casbin_rule_prefix: casbin_rule_prefix} = adapter,
          key,
          idx,
          attrs
        ) do
      rule =
        attrs
        |> Enum.slice(idx, Enum.count(attrs))
        |> Enum.join(":")

      key = "#{casbin_rule_prefix}#{key}:*:#{rule}"

      case Redix.command(conn, ["DEL", key]) do
        {:error, msg} -> {:error, "Error removing policy: #{inspect(msg)}"}
        _ -> {:ok, adapter}
      end
    end

    @doc """
    Truncates the table and inserts the provided policies.

    Returns an error if conn is not set.

    ## Examples

        iex> PersistAdapter.save_policies(
        ...>    %Acx.Persist.RedisAdapter{},
        ...>    [])
        ...> {:error, "conn is not set"}
    """
    def save_policies(%RedisAdapter{conn: nil}, _) do
      {:error, "conn is not set"}
    end

    def save_policies(
          %RedisAdapter{} = adapter,
          policies
        ) do
      Enum.each(policies, fn %{key: key, attrs: attrs} ->
        add_policy(adapter, {key, attrs})
      end)

      adapter
    end
  end
end
