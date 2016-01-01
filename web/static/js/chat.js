// // $(function() {
//   $("div[data-behaviour=chat-users] a[data-behaviour=chat-user]").on('click', function(){
//     alert(this)
//   })
// // });
// // 

var Chat = {

  getUsers:            $("div[data-behaviour=chat-users] li[data-behaviour=chat-user]"),
  getLobbyMbox:        $("[data-behaviour=chat-mbox] [data-mbox=chat-lobby] [data-behaviour=mbox]"),
  getAllMboxContainer: $("div[data-behaviour=chat-mbox] div[data-behaviour=mbox-container]"),
  getMsgBox:           $("[data-behaviour=msg-form] textarea[data-behaviour=msg-input]"),

  getMboxContainer: function(name){ 
    return Chat.getAllMboxContainer.filter("[data-mbox="+name+"]")
  },

  pushMsgToMboxContainer: function(username, container, msg){
    // var container = Chat.getMboxContainer(username)
    container.find("[data-behaviour=mbox]").append(msg)
    // msg[0].scrollIntoView();

    Chat.displayNotification(username);
  },

  displayNotification: function(username){
    // display notification if not in focused
    if(window.selected_chatgroup.attr("data-username") != username){
      var notificationBox = Chat.getNotificationBoxFor(username)
      var count = Number(notificationBox.text());
      notificationBox.text(++count);
    }

  },

  getUserFullName: function(username){
    // console.log($("[data-behaviour=chat-users] li[data-username="+username+"]"))
    return $("[data-behaviour=chat-users] li[data-username="+username+"]").attr("data-name")
  },
  
  getUser: function(username){
    return Chat.getUsers.filter("[data-username="+username+"]")
  },

  getNotificationBoxFor: function(username){
    // console.log(Chat.getUser(username).find("[data-behaviour=notification]"))
    return Chat.getUser(username).find("[data-behaviour=notification]")
  },

  resetNotificationFor: function(username){
    var notificationBox = Chat.getUser(username).find("[data-behaviour=notification]");
    // console.log(notificationBox)
    notificationBox.text("");
  },


  run: function() {
    $(function() {

      // hide all mbox and show lobby mbox  
      Chat.getAllMboxContainer.hide()
      Chat.getMboxContainer('chat-lobby').show()
      window.selected_chatgroup = Chat.getUser("chat-lobby");


      // on click display related mbox  
      Chat.getUsers.on('click', function(){
        // console.log(this)
        // 
        var $this = $(this);
        var username = $this.attr("data-username");
        
        // console.log('Hiding all mbox-containers')
        // console.log('displayiing '+username+'-container');
        
        Chat.getAllMboxContainer.hide()
        Chat.getMboxContainer(username).show()        
        Chat.resetNotificationFor(username);

        window.selected_chatgroup = $this;
      })
    });    
  },

  displayMessage: function(payload){

    if(payload.type == 'group'){
        // its a group message
        var msgFor = payload.to;
      } 
      else{
        // its an individual chat
        if (window.current_username == payload.from){
          // message sent by me
          var msgFor = payload.to;
        }else{
          // message received by me
          var msgFor = payload.from;
        }
    }


    var currentTime = new Date();

    //mbox in which new message will be pushed
    var $mboxContainer = Chat.getMboxContainer(msgFor)
    var $newMsgContainer = $("<div>", {"data-behaviour": "msg", "data-from-username": payload.from, "data-timestamp": currentTime.getTime(), class: "msg-container"});
    // console.log("[data-username="+payload.from+"]")
    // 
    // message sender name from dom using username
    var fromName = Chat.getUserFullName(payload.from)
    // prepare the message content to display
    var msg = payload.msg;
    var $timestampContainer = $("<span>", {class: "grey-out small"}).html("&nbsp;"+currentTime.toLocaleString());
    var $from = $("<span>", {class: 'bold'}).append(fromName);

    var $username = $("<div>").append($from).append($timestampContainer)
    $newMsgContainer.append($username)
    
    $newMsgContainer.append($("<div>", {class: "msg"}).html(msg));


    console.log("Message received for chatgroup: "+msgFor);

    // append in the desigred chat group
    // 
    Chat.pushMsgToMboxContainer(msgFor, $mboxContainer, $newMsgContainer)
   
    
  },

  setUserActive: function(username){
    Chat.getUser(username).addClass("online").removeClass("offline");
  },

  setUserInactive: function(username){
    console.log(username + " offline")
    Chat.getUser(username).addClass("offline").removeClass("online");
    Chat.displayUserExited(username);
  },

  setInactiveUserStatus: function(payload){
    // console.log(payload)
    var users = Chat.getUsers
    users.addClass("online").removeClass("offline");
    
    var offline_users  = users.filter(function(){
      return payload.includes($(this).attr("data-username"))
    });
    
    offline_users.addClass("offline").removeClass("online")
  },

  displayUserExited: function(username){
    var name = Chat.getUserFullName(username);
    var $msg = $("<div>");
    var currentTime = new Date().toLocaleString();
    var msg = name + " left " 
    var $timestampContainer = $("<span>", {class: "grey-out small"}).text(currentTime);
    $msg.append(msg)
    $msg.append($timestampContainer);
    // console.log(chatLobby)
    Chat.getLobbyMbox.append($msg);
  },



};

Chat.run();









module.exports = {
  Chat: Chat
};