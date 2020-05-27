# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :optrader,
  ecto_repos: [Optrader.Repo]

# Configures the endpoint
config :optrader, OptraderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Pm+yzFeHXCwD5UeIuD97eLMwXJFmKLonWGi+tppM+zFZbIhcVNgq+B+HT8mhUbFn",
  render_errors: [view: OptraderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Optrader.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :phoenix, :json_library, Poison
config :hound,
  driver: "chrome_driver",
  browser: "chrome_headless",
  host: "http://localhost",
  port: 9515,
  path_prefix: "wd/hub/",
  chromeOptions: %{
    "prefs" => %{
      "loggingPrefs" => %{
        "browser" => 'ALL',
        "driver" => 'ALL',
        "performance" => 'ALL'
      }
    }
  }
