defmodule PhoenixBanditBaselineWeb.PageController do
  use PhoenixBanditBaselineWeb, :controller

  def hello_world(conn, _params) do
    conn |> send_resp(200, "hello world!")
  end

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
