defmodule Throttle.Request do
  alias Throttle.Config
  alias Throttle.Request

  defstruct [
    :started_at,
    :namespace,
    :keyspace,
    :timespace,
    :counter,
    :count,
    :limit,
    :window,
    :delay,
    :delay_until,
    allowed: true
  ]

  def new({key, limit, window}) do
    %Request{}
    |> put_started_at
    |> put_namespace
    |> put_keyspace(key)
    |> put_window(window)
    |> put_limit(limit)
    |> put_timespace
    |> put_counter
  end

  def put_namespace(%Request{} = request) do
    %{request | namespace: Config.get(:namespace, "throttle")}
  end

  def put_keyspace(%Request{} = request, key) do
    %{request | keyspace: key}
  end

  def put_started_at(%Request{} = request) do
    %{request | started_at: :os.system_time(:seconds)}
  end

  def put_window(%Request{} = request, :second) do
    %{request | window: :second}
  end
  def put_window(%Request{} = request, :minute) do
    %{request | window: :minute}
  end
  def put_window(%Request{} = request, :hour) do
    %{request | window: :hour}
  end

  def put_limit(%Request{} = request, limit) when is_integer(limit) do
    %{request | limit: limit}
  end

  def put_timespace(%Request{window: :second} = request) do
    %{request | timespace: System.system_time(:second)}
  end
  def put_timespace(%Request{window: :minute} = request) do
    %{request | timespace: Time.utc_now.minute}
  end
  def put_timespace(%Request{window: :hour} = request) do
    %{request | timespace: Time.utc_now.hour}
  end

  def put_counter(%Request{namespace: ns, keyspace: ks, timespace: ts} = request) do
    %{request | counter: "#{ns}/#{ks}/#{ts}"}
  end

  def put_count(%Request{} = request, count) do
    %{request | count: count}
  end

  def put_allowed(%Request{count: count, limit: limit} = request) do
    %{request | allowed: count <= limit}
  end

  def put_delay(%Request{allowed: true} = request), do: request
  def put_delay(%Request{started_at: time, window: :second} = request) do
    %{request | delay: 1, delay_until: time + 1 }
  end
  def put_delay(%Request{started_at: time, window: window} = request) do
    next_window = time 
    |> DateTime.from_unix! 
    |> modify_datetime(window)
    |> DateTime.to_unix

    %{request | delay: next_window - time , delay_until: next_window }
  end

  defp modify_datetime(datetime, :minute) do
    %{datetime | minute: datetime.minute + 1, second: 0}
  end
  defp modify_datetime(datetime, :hour) do
    %{datetime | hour: datetime.min + 1, minute: 0}
  end
end
