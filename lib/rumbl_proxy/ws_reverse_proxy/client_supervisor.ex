defmodule RumblProxy.WSReverseProxy.ClientSupervisor do
  @moduledoc """
  Dynamic supervisor to handle clients for proxied websocket connections.
  """

  use DynamicSupervisor

  alias RumblProxy.WSReverseProxy, as: WebSocketHandler
  alias RumblProxy.WSReverseProxy.Client

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_child(WebSocketHandler.state(), pid) :: DynamicSupervisor.on_start_child()
  def start_child(state, handler) do
    init_arg = {state, handler}

    DynamicSupervisor.start_child(__MODULE__, {Client, init_arg})
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
