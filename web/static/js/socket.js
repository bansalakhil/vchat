// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "deps/phoenix/web/static/js/phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("chat:lobby", {})
let chatLobby = $("div#chat-lobby-container div#chat-lobby-mbox")

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })






channel.on("user:entered_in_lobby", payload => {
  var name = $("[data-behaviour=chat-users").find("[data-username="+payload.user+"]").attr("data-name")
  var $joinedMsg = $("<div>");
  var currentTime = new Date().toLocaleString();
  var msg = name + " joined " 
  var $timestampContainer = $("<span>", {class: "grey-out small"}).text(currentTime);
  $joinedMsg.append(msg)
  $joinedMsg.append($timestampContainer);
  chatLobby.append($joinedMsg);

})



channel.on("chat:new_msg", payload => {
  console.log("[data-username="+payload.from+"]")
  var fromName = $("[data-behaviour=chat-users").find("[data-username="+payload.from+"]").attr("data-name")
  
  var $msgContainer = $("<div>", {class: "msg-container"});
  var currentTime = new Date().toLocaleString();
  var msg = payload.msg;
  var $timestampContainer = $("<span>", {class: "grey-out small"}).html("&nbsp;"+currentTime);
  var $from = $("<span>", {class: 'bold'}).append(fromName);
  var $username = $("<div>").append($from).append($timestampContainer)
  
  $msgContainer.append($username)
  $msgContainer.append($("<div>", {class: "msg"}).html(msg));

  if(payload.type == 'group'){
      // its a group message
      var $msgFor = $("[data-behaviour=chat-mbox] #"+payload.to+"-mbox")
    } 
    else{
      // its an individual chat
      if (window.current_username == payload.from){
        // message sent by me
        var $msgFor = $("[data-behaviour=chat-mbox] #"+payload.to+"-mbox");
      }else{
        // message received by me
        var $msgFor = $("[data-behaviour=chat-mbox] #"+payload.from+"-mbox");
      }
  }
    
  $msgFor.append($msgContainer);
  
})




var $msgBox = $("[data-behaviour=msg-form] textarea[data-behaviour=msg-input]")
$msgBox.keydown(function(e){
    if (e.keyCode == 13 && !e.shiftKey)
    {
        channel.push("chat:new_msg", {msg: $msgBox.val(), to: window.selected.attr("data-username"), type: window.selected.attr("data-chat-type")})
        $msgBox.val("")
        e.preventDefault();
    }
});



export default socket
