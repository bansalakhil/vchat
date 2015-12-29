defmodule Vchat.ChatChannel do
  use Phoenix.Channel

  def join("chat:lobby", message, socket) do
    send(self, {:after_join, message})
    {:ok, socket}
  end
  
  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered_in_lobby", %{user: socket.assigns[:current_user].username}
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
    push socket, "chat:new_msg", payload
    {:noreply, socket}
  end


end