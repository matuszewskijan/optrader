use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :optrader, OptraderWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :optrader, Optrader.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "janm",
  password: "zaq123",
  database: "optrader_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
