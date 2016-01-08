require IEx
defmodule Vchat.ChatChannel do
  use Phoenix.Channel
  require Logger
  
  import Ecto
  import Ecto.Query

  alias Vchat.Message
  alias Vchat.User
  alias Vchat.MessageAssignment
  
  intercept ["chat:new_msg", "chat:old_messages"]
  
  def join("chat:*", message, socket) do
    :timer.send_interval(60000, :ping)
    send(self, {:after_join, message})
    {:ok, socket}
  end
    
 
  def handle_info({:after_join, msg}, socket) do
    record_last_activity(socket)
    # IEx.pry
    broadcast! socket, "user:entered_in_lobby", %{ inactive_users: get_inactive_users, user: socket.assigns[:current_user].username}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "chat:user_status", %{inactive_users: get_inactive_users, body: "ping"}
    {:noreply, socket}
  end

  def join("chat:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end


  def handle_in("chat:old_messages", %{"msg" => msg}, socket) do
    current_user = socket.assigns[:current_user]
    received_messages = get_old_messages(socket)
    broadcast! socket, "chat:old_messages", %{ received_messages: received_messages, user: current_user.username}
    {:noreply, socket}
  end  

  def handle_in("chat:new_msg", %{"msg" => msg, "type" => type, "to" => to}, socket) do
    record_last_activity(socket)
    from_user = socket.assigns[:current_user]

    "Message Received:==>  Type: #{type}, From: #{from_user.username}, To: #{to}, Message: #{msg}"
      |> Colorful.string(["green", "bright"])
      |> Logger.debug

    message_changeset = build_assoc(from_user, :sent_messages, body: msg, msg_type: type, group_name: to)
    # IEx.pry
    case Vchat.Repo.insert(message_changeset) do
      {:ok, message} ->
        if type != "group" do
          to_user = Vchat.Repo.get_by(Vchat.User, username: to)
          # IEx.pry
          insert_message_assignment(message, to_user)
          insert_message_assignment(message, from_user)
        else 
          users = Vchat.Repo.all(Vchat.User)  
          Enum.each(users, fn(to_user) ->
          insert_message_assignment(message, to_user)
          end)
        end

        broadcast! socket, "chat:new_msg", %{mid: message.id, from: from_user.username, to: to, msg: msg, seen: false, msg_type: message.msg_type, group_name: message.group_name, time: "#{Ecto.DateTime.to_string(message.inserted_at)}"}
      {:error, message_changeset} ->
        nil
    end
    {:noreply, socket}
  end  

  def handle_in("chat:record_last_activity", %{"msg" => msg}, socket) do
    # broadcast! socket, "chat:new_msg", %{msg: msg, from: socket.assigns[:current_user].username, type: type, to: to}
    # Vchat.UserController.record_last_activity(socket.assigns[:current_user])

    record_last_activity(socket)
    {:noreply, socket}
  end

  def handle_out("chat:new_msg", payload, socket) do
    if (payload.msg_type == "group") || (socket.assigns[:current_user].username == payload.to) || (socket.assigns[:current_user].username == payload.from) do
      push socket, "chat:new_msg", payload
    end
    {:noreply, socket}
  end

  def handle_out("chat:old_messages", payload, socket) do
    if (socket.assigns[:current_user].username == payload.user)  do
      push socket, "chat:old_messages", payload
    end
    {:noreply, socket}
  end  

  def terminate(reason, socket) do
    mark_offline(socket)
    broadcast! socket, "chat:user_offline", %{username: socket.assigns[:current_user].username}
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  defp record_last_activity(socket) do
    Vchat.Repo.update(Vchat.User.record_last_activity(socket.assigns[:current_user]))
  end

  defp mark_offline(socket) do
    Vchat.Repo.update(Vchat.User.mark_offline(socket.assigns[:current_user]))
  end

  defp get_inactive_users do
    users = Vchat.Repo.all(from u in Vchat.User, where: u.online == false or u.last_activity_at < datetime_add(^Ecto.DateTime.utc, -60, "second") or is_nil(u.last_activity_at)  )
    Enum.map(users, &(&1.username))
  end

  defp get_old_messages(socket) do 
    # socket.assigns[:current_user]
    user = socket.assigns[:current_user] 
    message_assignments = MessageAssignment |> where(receiver_id: ^user.id) |> limit(100) |> preload(message: :sender) |> Vchat.Repo.all
    # IEx.pry
    Enum.map(message_assignments, fn(ma) -> %{mid: ma.message.id, from: ma.message.sender.username, to: user.username, msg: ma.message.body, seen: ma.seen, msg_type: ma.message.msg_type, group_name: ma.message.group_name, time: "#{Ecto.DateTime.to_string(ma.message.inserted_at)}"}  end)
  end

  defp insert_message_assignment(message, user) do
    message_assignments_changeset = build_assoc(message, :message_assignments,  receiver_id: user.id);
    Vchat.Repo.insert(message_assignments_changeset);
  end



end