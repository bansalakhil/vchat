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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Vchat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    
    resources "/users", UserController 
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    
    get "users/activate/:t", UserController, :activate
  end


  # Fetch the current user from the session and add it to `conn.assigns`. This
  # will allow you to have access to the current user in your views with
  # `@current_user`.
  defp assign_current_user(conn, _) do
    user_id = get_session(conn, :current_user)
    assign(conn, :current_user, Vchat.UserController.find_by_id(user_id))
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vchat do
  #   pipe_through :api
  # end
end
