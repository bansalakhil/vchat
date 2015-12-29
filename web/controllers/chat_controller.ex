defmodule Vchat.ChatController do
  use Vchat.Web, :controller

  alias Vchat.User

  # plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    # users = Repo.all(from u in User, where: u.id != ^current_user.id)
    users = Repo.all(User)

    render(conn, "index.html", users: users)
  end



end
