defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Accounts,
    Multimedia
  }

  def user_fixture(attrs \\ %{}) do
    username = "user#{System.unique_integer([:positive])}"

    some_user = %{
      name: "Some User",
      username: username,
      credential: %{
        email: attrs[:email] || "#{username}@example.com",
        password: attrs[:password] || "supersecret"
      }
    }

    {:ok, user} =
      attrs
      |> Enum.into(some_user)
      |> Accounts.register_user()

    user
  end

  def video_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "A Title",
        url: "http://example.com",
        description: "a description"
      })

    {:ok, video} = Multimedia.create_video(user, attrs)

    video
  end
end
