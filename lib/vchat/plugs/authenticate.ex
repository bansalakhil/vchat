# defmodule Vchat.Plugs.Authenticate do
#   import Plug.Conn
#   # import Plug.Session
#   # import Vchat.Router.Helpers
#   import Phoenix.Controller

#   def init(default), do: default

#   def call(conn, _default) do
#     current_user_id = get_session(conn, :current_user)
#     current_user = Vchat.UserController.find_by_id(current_user_id)
#     if current_user do
#       assign(conn, :current_user, current_user)
#     else
#       conn
#         |> put_flash(:error, 'You need to be signed in to view this page')
#         |> redirect(to: conn.session_path(conn, :new))
#     end
#   end
# end

