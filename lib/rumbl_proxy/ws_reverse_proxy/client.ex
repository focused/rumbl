defmodule RumblProxy.WSReverseProxy.Client do
  @moduledoc """
  Websocket client.
  """

  use WebSockex, restart: :temporary

  alias RumblProxy.WSReverseProxy, as: WebSocketHandler
  alias RumblProxy.WSReverseProxy.Registry, as: WSRegistry

  require Logger

  defmodule State do
    @moduledoc false

    @enforce_keys [:ref]
    defstruct [:ref]

    @type t :: %__MODULE__{ref: reference}
  end

  @opaque state :: State.t()

  @type opts :: {WebSocketHandler.state(), pid}
  @type on_start :: {:ok, pid} | {:error, term}

  @type call_result(state) ::
          {:ok, state}
          | {:reply, WebSockex.frame(), state}
          | {:close, state}
          | {:close, WebSockex.close_frame(), state}

  @spec start_link(opts) :: on_start
  def start_link(opts)

  def start_link({state, handler}) do
    %WebSocketHandler.State{
      callback_module: callback_module,
      ref: ref,
      opts: opts,
      initial_req: initial_req
    } = state

    name = {:via, Registry, {WSRegistry, ref, handler}}

    url = callback_module.websocket_endpoint(initial_req, opts)
    conn_opts = callback_module.conn_options(initial_req, opts)

    state = %State{ref: ref}
    client_opts = Keyword.merge(conn_opts, name: name)

    WebSockex.start_link(url, __MODULE__, state, client_opts)
  end

  @impl WebSockex
  @spec handle_frame(WebSockex.frame(), state) :: call_result(state)
  def handle_frame(frame, state)

  def handle_frame({:text, msg}, state) do
    Logger.debug("websocket client #{inspect(state.ref)} received text frame: #{msg}")

    case Registry.lookup(WSRegistry, state.ref) do
      [{_, handler_pid}] ->
        send(handler_pid, {:proxy, {:text, msg}})
    end

    {:ok, state}
  end
end
