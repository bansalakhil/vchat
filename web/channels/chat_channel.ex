defmodule Vchat.ChatChannel do
  use Phoenix.Channel
  import Ecto.Query

  intercept ["chat:new_msg"]
  
  def join("chat:lobby", message, socket) do
    :timer.send_interval(300000, :ping)
    send(self, {:after_join, message})
    {:ok, socket}
  end
  
  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered_in_lobby", %{user: socket.assigns[:current_user].username}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
# from u in User,
#   where: u.reset_password_sent_at > datetime_add(^Ecto.DateTime.utc, -5, "minute")  
    users = Vchat.Repo.all(from u in Vchat.User, where: u.last_activity_at < datetime_add(^Ecto.DateTime.utc, -15, "second") or is_nil(u.last_activity_at)  )
    users = Enum.map(users, &(&1.username))
    push socket, "chat:user_status", %{inactive_users: users, body: "ping"}
    {:noreply, socket}
  end

  def join("chat:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("chat:new_msg", %{"msg" => msg, "type" => type, "to" => to}, socket) do
    broadcast! socket, "chat:new_msg", %{msg: msg, from: socket.assigns[:current_user].username, type: type, to: to}
    {:noreply, socket}
  end  

  def handle_in("chat:record_last_activity", %{"msg" => msg}, socket) do
    # broadcast! socket, "chat:new_msg", %{msg: msg, from: socket.assigns[:current_user].username, type: type, to: to}
    # Vchat.UserController.record_last_activity(socket.assigns[:current_user])

# from u in User,
#   where: u.reset_password_sent_at > datetime_add(^Ecto.DateTime.utc, -5, "minute")
    Vchat.Repo.update(Vchat.User.record_last_activity(socket.assigns[:current_user]))
    {:noreply, socket}
  end



  def handle_out("chat:new_msg", payload, socket) do
    if (payload.type == "group") || (socket.assigns[:current_user].username == payload.to) || (socket.assigns[:current_user].username == payload.from) do
      push socket, "chat:new_msg", payload
    end
    {:noreply, socket}
  end


end