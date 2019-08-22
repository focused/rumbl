# Rumbl

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix


## Using

1. Register: `http://localhost:4000/users/new`
2. Create video: `http://localhost:4000/manage/videos/new`
3. Watch and annotate: `http://localhost:4000/watch/1-slug`
4. Try proxy: `http://localhost:4100/...`


## Other stuff

1. ReverseProxyPlugA:

WebSocket connection to 'ws://localhost:4100/socket/websocket?token=...' failed: Invalid frame header

2. ReverseProxyPlug:

426 Upgrade Required


3. PlugProxy on 4100:

[info] CONNECTED TO RumblWeb.UserSocket in 187µs
  Transport: :websocket
  Serializer: Phoenix.Socket.V2.JSONSerializer
  Connect Info: %{}
  Parameters: %{"token" => "SFMyNTY.g3QAAAACZAAEZGF0YWECZAAGc2lnbmVkbgYAeY6GuGwB.2y9rflVquECh3j4soO_9VhMZ4INexl6oKEZb1qLou5Y", "vsn" => "2.0.0"}
[error] #PID<0.800.0> running RumblProxy.Endpoint (connection #PID<0.799.0>, stream id 1) terminated
Server: 192.168.1.66:4100 (http)
Request: GET /socket/websocket?token=SFMyNTY.g3QAAAACZAAEZGF0YWECZAAGc2lnbmVkbgYAeY6GuGwB.2y9rflVquECh3j4soO_9VhMZ4INexl6oKEZb1qLou5Y&vsn=2.0.0
** (exit) an exception was raised:
    ** (PlugProxy.GatewayTimeoutError) gateway timeout: read
        (plug_proxy) lib/plug_proxy/response.ex:83: PlugProxy.Response.reply/2
        (plug) lib/plug/router/utils.ex:92: Plug.Router.Utils.forward/4
        (rumbl) lib/plug/router.ex:259: RumblProxy.Endpoint.dispatch/2
        (rumbl) lib/rumbl_proxy/endpoint.ex:1: RumblProxy.Endpoint.plug_builder_call/2
        (plug_cowboy) lib/plug/cowboy/handler.ex:12: Plug.Cowboy.Handler.init/2
        (cowboy) /Users/owl/Dev/rumbl/deps/cowboy/src/cowboy_handler.erl:41: :cowboy_handler.execute/2
        (cowboy) /Users/owl/Dev/rumbl/deps/cowboy/src/cowboy_stream_h.erl:296: :cowboy_stream_h.execute/3
        (cowboy) /Users/owl/Dev/rumbl/deps/cowboy/src/cowboy_stream_h.erl:274: :cowboy_stream_h.request_process/3
        (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3