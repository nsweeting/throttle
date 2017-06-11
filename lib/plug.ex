defmodule Throttle.Plug do
  import Plug.Conn

  def init({keyspace, value, type}), do: {keyspace, value, type}

  def call(conn, {keyspace, value, type}) do
    keyspace = "#{keyspace}/#{ip_to_string(conn)}"

    case Throttle.allow?({keyspace, value, type}) do
      {:ok, _} -> conn
      {:error, result} -> throttle_request(conn, result)
    end
  end

  defp ip_to_string(%Plug.Conn{remote_ip: remote_ip}) do
    remote_ip
    |> Tuple.to_list
    |> Enum.join
  end

  defp throttle_request(conn, %Throttle.Result{delay: delay}) do
    conn
    |> put_resp_header("retry-after", to_string(delay))
    |> send_resp(429, "Too Many Requests")
    |> halt
  end
end
