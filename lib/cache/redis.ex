defmodule Throttle.Cache.Redis do
  @behaviour Throttle.Cache.Base

  alias RedisPool, as: Redis
  alias Throttle.Request

  def get_count(%Request{counter: counter, window: window} = request) do
    {:ok, count} = increment(counter)
    expire(counter, window)
    Request.put_count(request, String.to_integer(count))
  end

  defp increment(counter) when is_binary(counter) do
    Redis.query(["INCR", counter])
  end

  def expire(counter, :second) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, 1])
  end

  def expire(counter, :minute) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, 60])
  end

  def expire(counter, :hour) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, 3600])
  end
end
