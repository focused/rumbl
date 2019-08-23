# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Rumbl.Repo.insert!(%Rumbl.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Rumbl.{Accounts, Multimedia}

Accounts.register_user(%{
  name: "Test#1",
  username: "test1",
  credential: %{email: "test1@test", password: "123123"}
})

for category <- ~w(Action Drama Romance Comedy Sci-fi) do
  Multimedia.create_category(category)
end

user = Accounts.get_user_by_email("test1@test")

Multimedia.create_video(user, %{
  description: "desc",
  title: "skyrim modded",
  url: "https://www.youtube.com/watch?v=0Ty3WgXuyB4"
})
