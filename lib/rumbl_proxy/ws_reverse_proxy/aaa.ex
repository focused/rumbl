defmodule RumblProxy.WSReverseProxy.AAA do
  @moduledoc """
  Callback module to proxy WebSocket connections to the AAA microservice.
  """

  use RumblProxy.WSReverseProxy.CallbackModule

  # alias RumblProxy.Config

  @impl RumblProxy.WSReverseProxy.CallbackModule
  def websocket_endpoint(_req, _opts) do
    "http://localhost:4000"
    |> sub_scheme()
    |> URI.merge("/socket/websocket")

    # "http://192.168.1.64:8080"
    # |> sub_scheme()
    # |> URI.merge("/guacamole/websocket-tunnel")
  end

  @impl RumblProxy.WSReverseProxy.CallbackModule
  def conn_options(req, _opts) do
    case :cowboy_req.header("cookie", req) do
      :undefined ->
        []

      cookie ->
        [extra_headers: [{"cookie", cookie}]]
    end
  end
end
