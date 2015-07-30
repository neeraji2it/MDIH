var Chat = {}

jQuery(document).ready(function() {
    Chat.thisUser = thisUser;
    Chat.authenticityToken = jQuery("#authenticity-token").val();
    Chat.loadInitialData();
});

Chat.loadInitialData = function() {
    jQuery.noSpinner = true;

    jQuery.post('/chat/initial_data.json',{
        authenticity_token: Chat.authenticityToken
    },
    function(response){
        Chat.processResponse(response);
    }, 'json');

    jQuery.noSpinner = false;
}

Chat.clearTimeout = function() {
    window.clearTimeout(this.getUpdatesTimer);
}

Chat.setTimeout = function() {
    this.getUpdatesTimer = window.setTimeout(Chat.getUpdates, 60000);
}

Chat.resetTimeout = function() {
    Chat.clearTimeout();
    Chat.setTimeout();
}

Chat.getUpdates = function() {
    Chat.clearTimeout();
    jQuery.noSpinner = true;

    jQuery.post('/chat/updates.json',
    {
        authenticity_token: Chat.authenticityToken
    },
    function(response){
        Chat.processResponse(response);
        Chat.resetTimeout();
    }, 'json');

    jQuery.noSpinner = false;
}

Chat.sendMessage = function(message) {
    jQuery.noSpinner = true;

    jQuery.post('/chat.json',
    {
        authenticity_token: Chat.authenticityToken,
        reciever_id: message.reciever.id,
        text: message.text
    },
    function(response){
        Chat.processResponse(response);
    }, 'json');

    jQuery.noSpinner = false;
}

Chat.processResponse = function(response) {
    Chat.updateMessages(response.messages);
    Chat.updateUsers(response.users, response.current_user);
}

Chat.updateUsers = function(users, current_user) {
    for(var i=0; i<users.length; i++) {
        var u = users[i];
        user = Users.find(u.id)
        if(user)
            user.update(u);
        else
            user = Users.create(u);

        user.updateStatus();
    }
    Chat.initSocketConnection(users, current_user);
    Chat.listenForLogin(users)
}

Chat.initSocketConnection = function(users, current_user){
    var jug =new Juggernaut;
    for(var i=0; i<users.length; i++) {
        var u = users[i];
        var user = Users.find(u.id)
        jug.subscribe("users:"+current_user+":"+user.id, function(data){
            var obj = JSON.parse(data);
//            console.log("text :"+obj.text +" sender_name :"+obj.sender_name +" Sender id :"+ obj.sender_id + " reciever name :"+obj.reciever_name+"reciever id: "+obj.reciever_id+"sender gender:"+obj.sender_gender+"reciver gender:"+obj.reciever_gender);
//            console.log("Sender Status: " +obj.sender_status+ "Receiver Status: " +obj.reciever_status  );
            Chat.newMessage(obj.text, obj.sender_name, obj.sender_id, obj.sender_age, obj.sender_photo ,obj.sender_gender ,obj.sender_status , obj.reciever_name, obj.reciever_id, obj.reciever_age,obj.reciever_photo,obj.reciever_gender, obj.reciever_status);
            // check the sender in opened_chat_windows js array variable if not there then make ajax to add sender to session
            if(jQuery.inArray(obj.sender_id, opened_chat_windows) == -1){
                Widgets.open(obj.sender_id)
            }
            $.titleAlert(obj.sender_name+" is saying "+obj.text, {
                requireBlur:true,
                stopOnFocus:true,
                interval:600
            });
        });
    }
}

Chat.listenForLogin = function(users){
    var jug =  new Juggernaut;
    for(var i=0; i < users.length; i++){
        var u = users[i];
        var user = Users.find(u.id);
        jug.subscribe("login:"+user.id, function(data){
            var Obj = JSON.parse(data);
            Users.find(Obj.id).update(Obj).updateStatus();
        });
    }
}


Chat.updateMessages = function(messages) {
    for(var i=0; i<messages.length; i++) {
        var sender = Users.find(messages[i].senderId) || {
            id: messages[i].senderId,
            name: messages[i].senderName,
            age: messages[i].senderAge,
            photo: messages[i].senderPhoto,
            gen: messages[i].senderGender,
            status: messages[i].senderGender
        };
        var reciever = Users.find(messages[i].recieverId) || {
            id: messages[i].recieverId,
            name: messages[i].recieverName,
            age: messages[i].recieverAge,
            photo: messages[i].recieverPhoto,
            gen: messages[i].recieverGender,
            status: messages[i].recieverGender
        };
       
        var friend = Chat.thisUser.id == sender.id ? reciever : sender;

        var message = Messages.create(messages[i].text, sender, reciever);

        var widget = Widgets.find(friend.id) || Widgets.create(friend.id, friend.name, friend.age, friend.photo, friend.gen, friend.status);
        
        widget.append(message);
    }
}

Chat.newMessage = function(messageText, senderName, senderId, senderAge, senderPhoto, senderGender,senderStatus, recieverName, recieverId, recieverAge, recieverPhoto, recieverGender, recieverStatus) {

    var sender =  {
        id: senderId,
        name: senderName,
        age: senderAge,
        photo: senderPhoto,
        gen: senderGender,
        status: senderStatus
    };
    var reciever =  {
        id: recieverId,
        name: recieverName,
        age: recieverAge,
        photo: recieverPhoto,
        gen: recieverGender,
        status: recieverStatus
    };
    var friend = Chat.thisUser.id == sender.id ? reciever : sender;
    
    var message = Messages.create(messageText, sender, reciever);

    var widget = Widgets.find(friend.id) || Widgets.create(friend.id, friend.name, friend.age, friend.photo, friend.gen, friend.status);

    if(Chat.openVideoChatWindow(messageText)){
        widget.append(message);
    }
    
    widget.show();
    
    return widget;
}

Chat.openVideoChatWindow = function(messageText){
    ///video/?tok_session_id
    var vchat_url_reg = /^\/video_chat\/\d+\/video\/\?tok_session_id=(\w+|\-|\_|=)+\&tok_token=(\w+|\-|\_|=)+$/;
    var vchat_url = vchat_url_reg.exec(messageText)
    if(vchat_url != null && vchat_url[0] != null){
        window.open(vchat_url[0], '_blank', 'location=1,status=1,scrollbars=yes, width=800,height=450,left=400,top=200,screenX=500,screenY=500')
        return false
    }
    return true
}

//chat smilies
Chat.insertEmotions = function(user,emotions){
    var emotions_val = emotions.alt
    jQuery("#chat-widget-"+user+" .form-container textarea").insertAtCaret(emotions_val);
}