defmodule Throttle.Result do
  alias Throttle.{Cache, Config, Context, Result}

  defstruct [
    :started_at,
    :namespace,
    :keyspace,
    :timespace,
    :counter,
    :count,
    :value,
    :type,
    :delay,
    :delay_until,
    allowed: true
  ]

  def new(%Context{keyspace: keyspace, type: type, value: value}) do
    %Result{}
    |> put_started_at
    |> put_namespace
    |> put_keyspace(keyspace)
    |> put_type(type)
    |> put_value(value)
    |> put_timespace
    |> put_counter
  end

  def put_started_at(%Result{} = result) do
    %{result | started_at: System.system_time(:second)}
  end

  def put_namespace(%Result{} = result) do
    %{result | namespace: Config.get(:namespace, "throttle")}
  end

  def put_keyspace(%Result{} = result, key) do
    %{result | keyspace: key}
  end

  def put_type(%Result{} = result, :rps), do: %{result | type: :rps}
  def put_type(%Result{} = result, :rpm), do: %{result | type: :rpm}
  def put_type(%Result{} = result, :rph), do: %{result | type: :rph}
  def put_type(%Result{} = result, :bucket), do: %{result | type: :bucket}
  def put_type(%Result{} = result, :interval), do: %{result | type: :interval}

  def put_value(%Result{} = result, value) when is_integer(value) do
    %{result | value: value}
  end
  def put_value(%Result{} = result, value) when is_list(value) do
    %{result | value: value}
  end

  def put_timespace(%Result{type: :interval} = result) do
    %{result | timespace: ""}
  end
  def put_timespace(%Result{type: :bucket} = result) do
    %{result | timespace: ""}
  end
  def put_timespace(%Result{type: :rps} = result) do
    %{result | timespace: System.system_time(:second)}
  end
  def put_timespace(%Result{type: :rpm} = result) do
    %{result | timespace: Time.utc_now.minute}
  end
  def put_timespace(%Result{type: :rph} = result) do
    %{result | timespace: Time.utc_now.hour}
  end

  def put_counter(%Result{namespace: ns, keyspace: ks, timespace: ts} = result) do
    %{result | counter: "#{ns}/#{ks}/#{ts}"}
  end

  def put_count(%Result{} = result) do
    %{result | count: Cache.get_count(result)}
  end

  def put_allowed(%Result{count: count, type: :interval} = result) do
    %{result | allowed: count <= 1}
  end
  def put_allowed(%Result{count: count, type: :bucket} = result) do
    %{result | allowed: count != nil}
  end
  def put_allowed(%Result{count: count, value: value} = result) do
    %{result | allowed: count <= value}
  end

  def put_delay(%Result{allowed: true} = result), do: result
  def put_delay(%Result{type: :interval, started_at: time, value: value} = result) do
    %{result | delay: value, delay_until: time + value }
  end
  def put_delay(%Result{type: :bucket, started_at: time, value: [rate: rate, max: _, cost: cost]} = result) do
    delay = round(cost / rate)
    %{result | delay: delay, delay_until: time + delay }
  end
  def put_delay(%Result{type: :rps, started_at: time} = result) do
    %{result | delay: 1, delay_until: time + 1 }
  end
  def put_delay(%Result{started_at: time, type: type} = result) do
    next_window = time
    |> DateTime.from_unix!
    |> modify_datetime(type)
    |> DateTime.to_unix

    %{result | delay: next_window - time , delay_until: next_window }
  end

  defp modify_datetime(datetime, :rpm) do
    %{datetime | minute: datetime.minute + 1, second: 0}
  end
  defp modify_datetime(datetime, :rph) do
    %{datetime | hour: datetime.hour + 1, minute: 0}
  end
end
