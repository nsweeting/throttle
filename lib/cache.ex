defmodule Throttle.Cache do
  alias Throttle.Config
  alias Throttle.Request

  @adapter Config.get(:cache_adapter, Throttle.Cache.Redis)

  def get_count(%Request{} = request) do
    @adapter.get_count(request)
  end
end
