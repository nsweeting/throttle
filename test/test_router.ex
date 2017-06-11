defmodule TestRouter do
  use Plug.Router

  plug Throttle.Plug, {"mysite", 1, :rps}

  plug Throttle.Plug, {"mysite", %{rate: 2, max: 40}, :leaky}
  plug :match
  plug :dispatch

  match _ do
    send_resp(conn, 200, "hello")
  end
end