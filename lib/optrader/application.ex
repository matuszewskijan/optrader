defmodule Optrader.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Optrader.Repo, []),
      # Start the endpoint when the application starts
      supervisor(OptraderWeb.Endpoint, []),
      # Start your own worker by calling: Optrader.Worker.start_link(arg1, arg2, arg3)
      # worker(Optrader.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Optrader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OptraderWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def unix_timestamp_to_date(timestamp) do
    Integer.parse(timestamp)
    |> case do {integer, _} -> integer end
    |> DateTime.from_unix
    |> case do { _, date} -> date end
  end

end
