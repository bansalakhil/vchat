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
      window.selected = $("a[data-username=chat-lobby]");


      // on click display related mbox  
      $("div[data-behaviour=chat-users] a[data-behaviour=chat-user]").on('click', function(){
        var $this = $(this);
        var username = $this.attr("data-username");
        console.log('Hiding all mbox-containers')
        $("div[data-behaviour=chat-mbox] div[data-behaviour=mbox-container]").hide();
        console.log('displayiing '+username+'-container');
        $("div[data-behaviour=chat-mbox] div#"+username+"-container").show();

        window.selected = $this;



      })
    });    
  },


};

Chat.run();









module.exports = {
  Chat: Chat
};