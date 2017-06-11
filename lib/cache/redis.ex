defmodule Throttle.Cache.Redis do
  @behaviour Throttle.Cache.Base

  alias RedisPool, as: Redis
  alias Throttle.Result

  def get_count(%Result{counter: counter, value: value, type: :interval}) do
    count = increment(counter)
    if count == "1", do: expire(counter, :interval, value)
    String.to_integer(count)
  end
  def get_count(%Result{counter: counter, type: type}) do
    count = increment(counter)
    expire(counter, type)
    String.to_integer(count)
  end

  defp increment(counter) when is_binary(counter) do
    case Redis.query(["INCR", counter]) do
      {:ok, count} -> count
      _ -> "0"
    end
  end

  def expire(counter, :interval, value) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, value])
  end

  def expire(counter, :rps) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, 1])
  end

  def expire(counter, :rpm) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, 60])
  end

  def expire(counter, :rph) when is_binary(counter) do
    Redis.query(["EXPIRE", counter, 3600])
  end
end
