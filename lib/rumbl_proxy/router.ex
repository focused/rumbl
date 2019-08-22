defmodule RumblProxy.Router do
  use RumblProxy, :router

  # forward "/guacamole", Plugs.ReverseProxy, base_url: "http://192.168.1.64:8080"
  forward "/", Plugs.ReverseProxy, base_url: "http://localhost:4000"
  # forward "/", Plugs.ReverseProxy, base_url: {AppConfig, :get_base_url}
end
