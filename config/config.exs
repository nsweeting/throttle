# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :throttle, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:throttle, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :throttle, [
  contexts: [
    example1: {"example1", :rps, 3}
  ]
]

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

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
