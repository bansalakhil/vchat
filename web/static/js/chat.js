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

  pushMsgToMboxContainer: function(username, msg){
    var container = Chat.getMboxContainer(username)
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
    console.log(Chat.getUser(username).find("[data-behaviour=notification]"))
    return Chat.getUser(username).find("[data-behaviour=notification]")
  },

  resetNotificationFor: function(username){
    var notificationBox = Chat.getUser(username).find("[data-behaviour=notification]");
    console.log(notificationBox)
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
    // console.log(payload)
    // console.log("[data-username="+payload.from+"]")
    // 
    // message sender name from dom using username
    var fromName = Chat.getUserFullName(payload.from)
    // prepare the message content to display
    var currentTime = new Date().toLocaleString();
    var msg = payload.msg;
    var $timestampContainer = $("<span>", {class: "grey-out small"}).html("&nbsp;"+currentTime);
    var $from = $("<span>", {class: 'bold'}).append(fromName);
    var $username = $("<div>").append($from).append($timestampContainer)
    
    var $msgContainer = $("<div>", {class: "msg-container"});
    $msgContainer.append($username)
    $msgContainer.append($("<div>", {class: "msg"}).html(msg));

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
    console.log("Message received for chatgroup: "+msgFor);

    // append in the desigred chat group
    // 
    Chat.pushMsgToMboxContainer(msgFor, $msgContainer)
   
    
  },


  setInactiveUserStatus: function(payload){
    console.log(payload)
  }

};

Chat.run();









module.exports = {
  Chat: Chat
};