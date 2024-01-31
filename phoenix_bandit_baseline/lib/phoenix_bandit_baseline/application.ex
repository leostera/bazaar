defmodule PhoenixBanditBaseline.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixBanditBaselineWeb.Telemetry,
      # PhoenixBanditBaseline.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_bandit_baseline, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixBanditBaseline.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixBanditBaseline.Finch},
      # Start a worker by calling: PhoenixBanditBaseline.Worker.start_link(arg)
      # {PhoenixBanditBaseline.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixBanditBaselineWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixBanditBaseline.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixBanditBaselineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
