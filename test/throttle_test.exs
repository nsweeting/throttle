defmodule ThrottleTest do
  use ExUnit.Case
  doctest Throttle

  setup do
    RedisPool.query(["FLUSHDB"])
    :ok
  end

  test "that the throttle can handle interval contexts" do
    assert {:ok, _} = Throttle.allow?({"test", 1, :interval})
    assert {:error, _} = Throttle.allow?({"test", 1, :interval})
  end

  test "that the throttle can handle rps contexts" do
    assert {:ok, _} = Throttle.allow?({"test", 1, :rps})
    :timer.sleep(1010)
    assert {:ok, _} = Throttle.allow?({"test", 1, :rps})
    assert {:error, _} = Throttle.allow?({"test", 1, :rps})
  end
end
