defmodule Throttle.Control do
  alias Throttle.{Cache, Config, Request}

  @adapter Config.get(:control_adapter, Throttle.Control.Config)

  def all do
    @adapter.all
  end

  def find(name) when is_atom(name) do
    @adapter.find(name)
  end

  def to_request(control) when is_tuple(control) do
    control
    |> Request.new
    |> Cache.get_count
    |> Request.put_allowed
    |> Request.put_delay
  end
end
