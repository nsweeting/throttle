defmodule Throttle.Cache do
  alias Throttle.{Config, Result}
  alias Throttle.Result

  @adapter Config.get(:cache_adapter, Throttle.Cache.Redis)

  def get_count(%Result{} = result) do
    @adapter.get_count(result)
  end
end
