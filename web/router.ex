defmodule Vchat.Router do
  use Vchat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :auth do
    plug :authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Vchat do
    pipe_through :browser # Use the default browser stack

    # get "/", PageController, :index
    
    resources "/users", UserController, only: [:index, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    
    get "users/activate/:t", UserController, :activate
  end

  scope "/", Vchat do
    pipe_through [:browser, :auth]  # Use the default browser stack

    get "/", PageController, :index
    
  end



  # Fetch the current user from the session and add it to `conn.assigns`. This
  # will allow you to have access to the current user in your views with
  # `@current_user`.
  defp assign_current_user(conn, _) do
    user_id = get_session(conn, :current_user)
    assign(conn, :current_user, Vchat.UserController.find_by_id(user_id))
  end

  defp authenticate(conn, _) do
    current_user_id = get_session(conn, :current_user)
    current_user = Vchat.UserController.find_by_id(current_user_id)
    if current_user do
      assign(conn, :current_user, current_user)
    else
      conn
        |> put_flash(:error, 'You need to be signed in to view this page')
        |> redirect(to: "/sessions/new")
        |> halt()
    end    
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vchat do
  #   pipe_through :api
  # end
end
