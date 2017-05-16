defmodule Throttle do
  alias Throttle.Cache
  alias Throttle.Request

  def allow?(test) when is_tuple(test) do
    test
    |> Request.new
    |> Cache.get_count
    |> Request.put_allowed
    |> Request.put_delay
  end
end
