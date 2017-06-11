defmodule Throttle.Cache.Redis do
  @behaviour Throttle.Cache.Base

  alias RedisPool, as: Redis
  alias Throttle.Result

  def get_count(%Result{type: :interval, counter: counter, value: value}) do
    count = increment(counter)
    if count == "1", do: expire(counter, :interval, value)
    String.to_integer(count)
  end
  def get_count(%Result{type: :bucket, counter: counter, value: value}) do
    case get_bucket(counter) do
      nil -> new_bucket(counter, value)
      bucket -> update_bucket(counter, value, bucket)
    end
  end
  def get_count(%Result{type: type, counter: counter}) do
    count = increment(counter)
    expire(counter, type)
    String.to_integer(count)
  end

  defp new_bucket(counter, [rate: rate, max: max, cost: cost]) do
    total = max - cost
    set_bucket(counter, total)
    expire(counter, :leaky, round(max / rate))
    total
  end

  defp get_bucket(counter) do
    case RedisPool.query(["HMGET", counter | ["total", "time"]]) do
      {:ok, [:undefined, :undefined]} -> nil
      {:ok, [tokens, time]} -> [String.to_integer(tokens), String.to_integer(time)]
      {:error, _} -> nil
    end
  end

  defp update_bucket(counter, [rate: rate, max: max, cost: cost], [last_total, last_time]) do
    total = last_total + (System.system_time(:second) - last_time) * rate
    total = if total > max, do: max, else: total
    total = round(total - cost)

    if total < cost do
      nil
    else
      set_bucket(counter, total)
      expire(counter, :leaky, round(max / rate))
      total
    end
  end

  defp set_bucket(counter, total) do
    case RedisPool.query(["HMSET", counter | ["total", total, "time",  System.system_time(:second)]]) do
      {:ok, "OK"} -> total
      _ -> total
    end
  end

  defp increment(counter) when is_binary(counter) do
    case Redis.query(["INCR", counter]) do
      {:ok, count} -> count
      _ -> "0"
    end
  end

  defp expire(counter, :rps), do: Redis.query(["EXPIRE", counter, 1])
  defp expire(counter, :rpm), do: Redis.query(["EXPIRE", counter, 60])
  defp expire(counter, :rph), do: Redis.query(["EXPIRE", counter, 3600])
  defp expire(counter, _, value), do: Redis.query(["EXPIRE", counter, value])
end
