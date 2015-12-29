// // $(function() {
//   $("div[data-behaviour=chat-users] a[data-behaviour=chat-user]").on('click', function(){
//     alert(this)
//   })
// // });
// // 

var Chat = {
  run: function() {
    $(function() {

      // hide all mbox and show lobby mbox  
      $("div[data-behaviour=chat-mbox] div[data-behaviour=mbox-container]").hide();
      $("div[data-behaviour=chat-mbox] div#chat-lobby-container").show(); 
      window.selected_chatgroup = $("a[data-username=chat-lobby]");


      // on click display related mbox  
      $("div[data-behaviour=chat-users] a[data-behaviour=chat-user]").on('click', function(){
        var $this = $(this);
        var username = $this.attr("data-username");
        console.log('Hiding all mbox-containers')
        $("div[data-behaviour=chat-mbox] div[data-behaviour=mbox-container]").hide();
        console.log('displayiing '+username+'-container');
        $("div[data-behaviour=chat-mbox] div#"+username+"-container").show();

        window.selected_chatgroup = $this;

        // reset notification badge
        var notificationBox = $("[data-unread-notification-for="+username+"]")
        // var count = Number(notificationBox.text());
        notificationBox.text("");

      })
    });    
  },

  displayMessage: function(payload){
    // console.log(payload)
    // console.log("[data-username="+payload.from+"]")
    // 
    // message sender name from dom using username
    var fromName = $("[data-behaviour=chat-users").find("[data-username="+payload.from+"]").attr("data-name")
    
    // prepare the message content to display
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
    var $msgFor = $("[data-behaviour=chat-mbox] #"+msgFor+"-mbox")
    $msgFor.append($msgContainer);
    $msgContainer[0].scrollIntoView();
    

    // display notification if not in focused
    
    if(window.selected_chatgroup.attr("data-username") != msgFor){
      var notificationBox = $("[data-unread-notification-for="+msgFor+"]")
      var count = Number(notificationBox.text());
      notificationBox.text(++count);
    }
  },


  userStatus: function(payload){
    console.log(payload)
  }

};

Chat.run();









module.exports = {
  Chat: Chat
};