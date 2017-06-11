defmodule Throttle.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts TestRouter.init([])

  setup do
    RedisPool.query(["FLUSHDB"])
    :ok
  end

  test "test that the throttle plug will return a 429" do
    normal_request()
    throttle_request()
  end

  test "test that the throttle does not throttle correct request timing" do
    normal_request()
    :timer.sleep(1010)
    normal_request()
    :timer.sleep(100)
    throttle_request()
  end

  test "test that the throttle provides a retry-after header" do
    normal_request()
    conn = throttle_request()
    assert Enum.find(conn.resp_headers, fn {header, _} -> header == "retry-after" end)
  end

  defp new_conn do
    # Create a test connection
    conn = conn(:get, "/")
    # Invoke the plug
    conn = TestRouter.call(conn, @opts)
  end

  defp normal_request do
    conn = new_conn()
    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hello"
    conn
  end

  defp throttle_request do
    conn = new_conn()
    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == "Too Many Requests"
    conn
  end
end
