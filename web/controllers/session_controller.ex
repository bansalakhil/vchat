defmodule Vchat.SessionController do
  use Vchat.Web, :controller

  alias Vchat.User

  import Comeonin.Bcrypt, only: [checkpw: 2]

  plug :scrub_params, "user" when action in [:create]


  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) when not is_nil(email) and not is_nil(password) do
    user = Repo.get_by(User, email: email)
    user 
      |> sign_in(password, conn)
  end

  def create(conn, _) do
    failed_login(conn)
  end

  def delete(conn, _params) do
    conn
      |> delete_session(:current_user)
      |> put_flash(:info, "Signed out successfully!")
      |> redirect(to: page_path(conn, :index))
  end

  defp sign_in(user, _password, conn) when is_nil(user) do
    failed_login(conn)
  end

  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "Welcome #{user.name}")
        |> redirect(to: page_path(conn, :index))
    else
        failed_login(conn)
    end
  end

  defp failed_login(conn) do
    conn
      |> put_session(:current_user, nil)
      |> put_flash(:error, "Invalid email or password")
      |> redirect(to: session_path(conn, :new))
      |> halt()
  end


end