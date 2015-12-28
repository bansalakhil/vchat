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

  def handle_in("new_msg", %{"body" => body}, socket) do
    body = body <> "          hello"
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end


end