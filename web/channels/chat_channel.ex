defmodule Vchat.ChatChannel do
  use Phoenix.Channel
  
  intercept ["chat:new_msg"]
  
  def join("chat:lobby", message, socket) do
    :timer.send_interval(60000, :ping)
    send(self, {:after_join, message})
    {:ok, socket}
  end
  
  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered_in_lobby", %{user: socket.assigns[:current_user].username}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "chat:user_status", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def join("chat:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("chat:new_msg", %{"msg" => msg, "type" => type, "to" => to}, socket) do
    broadcast! socket, "chat:new_msg", %{msg: msg, from: socket.assigns[:current_user].username, type: type, to: to}
    {:noreply, socket}
  end



  def handle_out("chat:new_msg", payload, socket) do
    if (payload.type == "group") || (socket.assigns[:current_user].username == payload.to) || (socket.assigns[:current_user].username == payload.from) do
      push socket, "chat:new_msg", payload
    end
    {:noreply, socket}
  end


end