defmodule RumblProxy.WSReverseProxy do
  @moduledoc """
  Raw websocket handler to proxy websocket requests to backend services.
  """

  @behaviour :cowboy_websocket

  alias RumblProxy.WSReverseProxy.ClientSupervisor
  alias RumblProxy.WSReverseProxy.Registry, as: WSRegistry

  require Logger

  defmodule State do
    @moduledoc false

    @enforce_keys [:ref]
    defstruct [:ref, :callback_module, :opts, initial_req: nil]

    @type t :: %__MODULE__{
            ref: reference,
            callback_module: module | nil,
            opts: keyword | nil,
            initial_req: :cowboy_req.req() | nil
          }
  end

  @opaque state :: State.t()

  @type req :: :cowboy_req.req()
  @type opts :: keyword
  @type on_init :: {:cowboy_websocket, req(), state}

  @type frame ::
          :ping
          | :pong
          | {:text | :binary | :ping | :pong, binary()}

  @type call_result :: :cowboy_websocket.call_result(state)

  @type terminate_reason :: :cowboy_websocket.terminate_reason()

  @impl :cowboy_websocket
  @spec init(req, opts) :: on_init
  def init(req, opts) do
    ref = make_ref()

    Logger.debug("new websocket request #{inspect(ref)}: #{inspect(req)}")

    {callback_module, opts} = Keyword.pop(opts, :callback_module)

    state = %State{ref: ref, callback_module: callback_module, opts: opts, initial_req: req}

    {:cowboy_websocket, req, state}
  end

  @impl :cowboy_websocket
  @spec websocket_init(state) :: call_result
  def websocket_init(state) do
    res = ClientSupervisor.start_child(state, self())
    # IO.inspect("====================")
    # IO.inspect(state)
    # IO.inspect("--------------------")
    # IO.inspect(res)
    {:ok, _} = res

    new_state = %State{ref: state.ref}

    {:ok, new_state}
  end

  @impl :cowboy_websocket
  @spec websocket_handle(frame, state) :: call_result
  def websocket_handle(frame, state)

  def websocket_handle({:text, msg}, state) do
    Logger.debug("message from websocket #{inspect(state.ref)}: #{msg}")

    case Registry.lookup(WSRegistry, state.ref) do
      [{client_pid, _}] ->
        :ok = WebSockex.send_frame(client_pid, {:text, msg})
    end

    {:ok, state}
  end

  def websocket_handle(frame, state) do
    Logger.debug("frame from websocket #{inspect(state.ref)}: #{inspect(frame)}")

    {:ok, state}
  end

  @impl :cowboy_websocket
  @spec websocket_info(term, state) :: call_result
  def websocket_info(info, state)

  def websocket_info({:proxy, {:text, msg}}, state) do
    Logger.debug("message for websocket #{inspect(state.ref)}: #{msg}")

    {:reply, {:text, msg}, state}
  end

  def websocket_info(info, state) do
    Logger.debug("Erlang message for websocket #{inspect(state.ref)}: #{inspect(info)}")

    {:ok, state}
  end

  @impl :cowboy_websocket
  @spec terminate(terminate_reason, map, state) :: :ok
  def terminate(reason, partial_req, state) do
    Logger.debug("""
    websocket #{inspect(state.ref)} terminated: #{inspect(partial_req)}
    reason: #{inspect(reason)}
    """)

    with [{client_pid, _}] <- Registry.lookup(WSRegistry, state.ref) do
      ClientSupervisor.terminate_child(client_pid)
    end

    :ok
  end
end
