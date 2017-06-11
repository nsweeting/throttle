defmodule Throttle.Context do
  alias Throttle.{Config, Context}

  defstruct [
    :keyspace,
    :type,
    :value
  ]

  @adapter Config.get(:context_adapter, Throttle.Context.Config)

  def all do
    @adapter.all
  end

  def find(name) when is_atom(name) do
    @adapter.find(name)
  end

  def new(nil), do: nil
  def new({keyspace, type, value}) do
    %Context{
      keyspace: keyspace,
      type: type,
      value: value,
    }
  end
end
