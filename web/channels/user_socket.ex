defmodule Vchat.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "chat:*", Vchat.ChatChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # def connect(_params, socket) do
  #   {:ok, socket}
  # end



 def connect(%{"token" => token}, socket) do
   # max_age: 1209600 is equivalent to two weeks in seconds
   
   case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
     {:ok, current_user_id} ->
       current_user = Vchat.UserController.find_by_id(current_user_id)
      if current_user do
        
        {:ok, assign(socket, :current_user, current_user)}
      else
        :error
      end    
     {:error, reason} ->
       :error
   end
 end
 
  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Vchat.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
