defmodule RumblProxy.WSReverseProxy.CallbackModule do
  @moduledoc """
  This behavior describes how to connect to the WebSocket endpoint of a specific
  backend service.
  """

  alias RumblProxy.WSReverseProxy, as: WebSocketHandler

  @type endpoint :: String.t() | URI.t()

  @callback websocket_endpoint(initial_req :: WebSocketHandler.req(), opts :: keyword) :: endpoint
  @callback conn_options(initial_req :: WebSocketHandler.req(), opts :: keyword) ::
              WebSockex.options()

  @optional_callbacks conn_options: 2

  @doc false
  defmacro __using__(_opts) do
    quote do
      @behaviour RumblProxy.WSReverseProxy.CallbackModule

      import RumblProxy.WSReverseProxy.CallbackModule, only: [sub_scheme: 1]

      def conn_options(_req, _opts), do: []

      defoverridable conn_options: 2
    end
  end

  @spec sub_scheme(endpoint) :: URI.t()
  @doc """
  Swap `http://` and `https://` with `ws://` and `wss://`, respectively, for
  the given URL.
  ## Examples
  ```
  iex> uri = RumblProxy.WSReverseProxy.CallbackModule.sub_scheme("http://example.com/ws")
  iex> uri.scheme
  "ws"
  iex> uri = RumblProxy.WSReverseProxy.CallbackModule.sub_scheme("https://example.com/ws")
  iex> uri.scheme
  "wss"
  ```
  iex> uri = RumblProxy.WSReverseProxy.CallbackModule.sub_scheme(%URI{scheme: "http", host: "example.com", path: "ws"})
  iex> uri.scheme
  "ws"
  iex> uri = RumblProxy.WSReverseProxy.CallbackModule.sub_scheme(%URI{scheme: "https", host: "example.com", path: "ws"})
  iex> uri.scheme
  "wss"
  """
  def sub_scheme(endpoint)

  def sub_scheme(url) when is_binary(url), do: sub_scheme(URI.parse(url))
  def sub_scheme(%URI{scheme: "http"} = uri), do: %URI{uri | scheme: "ws"}
  def sub_scheme(%URI{scheme: "https"} = uri), do: %URI{uri | scheme: "wss"}
end
