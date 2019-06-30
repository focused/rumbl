defmodule RumblWeb.PageControllerTest do
  use RumblWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Rumbl.io!"
  end
end
