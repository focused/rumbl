defmodule RumblProxy.WSReverseProxy.AAA do
  @moduledoc """
  Callback module to proxy WebSocket connections to the AAA microservice.
  """

  use RumblProxy.WSReverseProxy.CallbackModule

  # alias RumblProxy.Config

  @impl RumblProxy.WSReverseProxy.CallbackModule
  def websocket_endpoint(req, _opts) do
    "http://localhost:4000"
    |> sub_scheme()
    |> URI.merge(%URI{path: "/socket/websocket", query: req.qs})
  end
end
