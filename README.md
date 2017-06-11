# Throttle

A general throttle utility. Mainly used to throttle inbound or outbound requests.

## Installation

Add the following to your list of dependencies in mix.exs:

```elixir
def deps do
  [{:throttle, "~> 0.1.0"}]
end
```

## Setup

As of now, Throttle only provides a Redis-backed cache. To configure your Redis connection, please add the following to your configuration in `config/confix.exs`.

```elixir
config :redis_connection_pool, [
  host: "127.0.0.1",
  port: 6379,
  password: "",
  db: 0,
  reconnect: :no_reconnect,
  pool_name: :"Redis.Pool",
  pool_size: 10,
  pool_max_overflow: 1
]
```

Or use with the full_url option.

```elixir
config :redis_connection_pool, [
  full_url: "redis://127.0.0.1:6379",
  reconnect: :no_reconnect,
  pool_name: :"Redis.Pool",
  pool_size: 10,
  pool_max_overflow: 1
]
```

You can also add throttle contexts to your config. This will allow us to access them by atom only in the future.

```elixir
config :throttle, [
  contexts: [
    # This would create a throttle context keyed under "example1" that allows 3 requests per second.
    example1: {"example1", :rps, 3}
    # This would create a throttle context keyed under "example2" that allows 30 requests per minute.
    example2: {"example2", :rpm, 30}
    # This would create a throttle context keyed under "example3" that allows 300 requests per hour.
    example2: {"example3", :rph, 300}
    # This would create a throttle context keyed under "example4" that allows 1 request every 3 seconds.
    example2: {"example3", :interval, 3}
    # This would create a throttle context keyed under "example5" using a leaky bucket that adds 1 token every second (rate), 
    # to a maximum of 40 (max), with each request costing 2 tokens (cost).
    example2: {"example3", :bucket, [rate: 1, max: 40, cost: 2]}
  ]
]
```

## Usage

Throttle provides a number of ways in which to control requests. They are:

- Requests per second (rps)
- Requests per minute (rpm)
- Requests per hour (rph)
- Seconds Between Request (interval)
- Leaky Bucket (bucket)

Assuming we use one of our above contexts, we can now start using our throttles:

```elixir
case Throttle.allow?(:example2) do
  {:ok, result} -> IO.puts "OK"
  {:error, result} -> IO.puts "Error"
end
```

Using config contexts means that each request is made under the same key. In the example above, this would be "example2".

Alternatively, we can simply pass a context directly into the allow? function.

```elixir
key = "1" # This could be a user id

case Throttle.allow?({key, :rps, 3}) do
  {:ok, result} -> IO.puts "OK"
  {:error, result} -> IO.puts "Error"
end
```

In all cases, a context must be structured as follows:

```elixir
{key, type, value} = {"key", :rps, 3}
```

### Using With Plug

Throttle provides a plug that can be used for API throttling. It can be used as follows:

```elixir
defmodule MyRouter do
  use Plug.Router

  plug Throttle.Plug, {"mysite", :bucket, [rate: 1, max: 40, cost: 2]}
  plug :match
  plug :dispatch

  match _ do
    send_resp(conn, 200, "hello")
  end
end

The above would end up creating a leaky bucket throttle. The key would be a join between "mysite" and the IP address of the incoming request.

