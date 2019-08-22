defmodule Plugs.ReverseProxy do
  @moduledoc """
  Proxy external requests to backend services.
  ## Example
  ```
  forward "/api", Plugs.ReverseProxy, base_url: {AppConfig, :get_base_url}
  ```
  """

  @behaviour Plug

  import Plug.Conn

  alias Plug.Conn

  require Logger

  defmodule Opts do
    @moduledoc false

    @enforce_keys [:base_url]
    defstruct [:base_url]

    @type t :: %__MODULE__{
            base_url: String.t() | {module(), atom()}
          }

    @spec base_url(t()) :: String.t()
    def base_url(%__MODULE__{base_url: base_url})
        when is_binary(base_url) do
      base_url
    end

    def base_url(%__MODULE__{base_url: {mod, fun}})
        when is_atom(mod) and is_atom(fun) do
      apply(mod, fun, [])
    end
  end

  @typep request :: {
           Tesla.Env.method(),
           Tesla.Env.url(),
           Tesla.Env.headers(),
           Tesla.Env.body()
         }
  @typep read_body_result :: {:ok, binary(), Conn.t()} | {:more, binary(), Conn.t()}

  @impl Plug
  @spec init(Plug.opts()) :: Opts.t()
  def init(opts) when is_list(opts) do
    {:ok, base_url} = Keyword.fetch(opts, :base_url)

    %Opts{base_url: base_url}
  end

  @impl Plug
  @spec call(Conn.t(), Opts.t()) :: Conn.t()
  def call(conn, opts) do
    conn
    |> prepare_request(opts)
    |> perform_request()
    |> handle_response(conn)
  end

  @spec prepare_request(Conn.t(), Opts.t()) :: request()
  defp prepare_request(conn, opts) do
    %Conn{
      method: method,
      request_path: path,
      query_string: query
    } = conn

    method = tesla_method(method)

    url =
      opts
      |> Opts.base_url()
      |> build_proxy_url(path, query)

    headers = prepare_request_headers(conn)

    body =
      conn
      |> read_body()
      |> maybe_stream_body()

    {method, url, headers, body}
  end

  @spec tesla_method(Conn.method()) :: Tesla.Env.method()
  for tesla_method <- ~w[head get delete trace options post put patch]a do
    plug_method = tesla_method |> Atom.to_string() |> String.upcase()

    defp tesla_method(unquote(plug_method)), do: unquote(tesla_method)
  end

  @spec build_proxy_url(String.t(), String.t(), String.t()) :: String.t()
  defp build_proxy_url(base_url, path, query) do
    query = normalize_query(query)

    base_url
    |> URI.merge(%URI{path: path, query: query})
    |> URI.to_string()
  end

  @spec normalize_query(String.t()) :: String.t() | nil
  defp normalize_query(""), do: nil
  defp normalize_query(query), do: query

  @spec prepare_request_headers(Conn.t()) :: Conn.headers()
  defp prepare_request_headers(conn) do
    conn
    |> delete_req_header("transfer-encoding")
    |> delete_req_header("host")
    |> Map.get(:req_headers)
  end

  @spec maybe_stream_body(read_body_result()) :: Tesla.Env.body()
  defp maybe_stream_body({:ok, body, _conn}), do: body

  defp maybe_stream_body({:more, body, conn}) do
    Stream.resource(
      fn -> {body, conn} end,
      fn
        # Initial chunk
        {body, conn} ->
          {[body], conn}

        # After the last chunk is read
        nil ->
          {:halt, nil}

        # Process the next chunk
        conn ->
          case read_body(conn) do
            {:ok, body, _conn} ->
              # Signal the last chunk is read
              {[body], nil}

            {:more, body, conn} ->
              {[body], conn}
          end
      end,
      fn _acc -> nil end
    )
  end

  @spec perform_request(request()) :: Tesla.Env.result()
  defp perform_request({method, url, headers, body}) do
    # Logger.debug(fn ->
    #   payload =
    #     inspect(method: method, url: url, header: headers, body: inspect(body, limit: 256))

    #   "reverse proxy request: #{payload}"
    # end)

    Tesla.request(method: method, url: url, body: body, headers: headers)
  end

  @spec handle_response(Tesla.Env.result(), Conn.t()) :: Conn.t()
  defp handle_response({:ok, %Tesla.Env{status: status, headers: headers, body: body}}, conn) do
    headers
    |> Enum.reduce(
      conn,
      fn {header, value}, conn ->
        put_resp_header(conn, header, value)
      end
    )
    |> delete_resp_header("transfer-encoding")
    |> send_resp(status, body)
  end

  defp handle_response({:error, error}, conn) do
    report_error(error)

    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(503, "")
  end

  defp report_error(error) do
    error =
      error
      |> :file.format_error()
      |> case do
        'unknown POSIX error' -> inspect(error)
        error -> to_string(error)
      end

    # Bugsnag.report(error, severity: "error", context: "reverse proxy")

    Logger.error("reverse proxy request failure: #{error}")
  end

  @proxy_module (quote do
                   @moduledoc false

                   @behaviour Plug

                   @impl Plug
                   defdelegate init(opts), to: Plugs.ReverseProxy

                   @impl Plug
                   defdelegate call(plug, opts), to: Plugs.ReverseProxy
                 end)

  # HACK(smaximov):
  #   we cannot forward to a single plug multiple times inside a router; this is
  #   a Phoenix router limitation https://github.com/phoenixframework/phoenix/pull/1419
  @doc false
  def define_proxy_module(module) when is_atom(module),
    do: Module.create(module, @proxy_module, __ENV__)
end

Plugs.ReverseProxy.define_proxy_module(Plugs.ReverseProxy.AAA)
# Plugs.ReverseProxy.define_proxy_module(Plugs.ReverseProxy.Payments)
# Plugs.ReverseProxy.define_proxy_module(Plugs.ReverseProxy.Reviews)
