defmodule Throttle.Plug do
  import Plug.Conn

  def init({keyspace, type, value}), do: {keyspace, type, value}

  def call(conn, {keyspace, type, value}) do
    keyspace = "#{keyspace}/#{ip_to_string(conn)}"

    case Throttle.allow?({keyspace, type, value}) do
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
