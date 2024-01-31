defmodule PhoenixBanditBaseline.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_bandit_baseline,
    adapter: Ecto.Adapters.Postgres
end
