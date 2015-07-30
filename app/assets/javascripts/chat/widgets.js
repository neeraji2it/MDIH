var Widgets = {}
var Widget = {}

Widget.selector = function() {
    return "#chat-widgets-container #" + this.id;
}

Widget.show = function() {
    jQuery("#chat-widgets-container #"+this.id).removeClass("hidden");
    this.scrollToBottom();

    return this;
}

Widget.hide = function() {
    jQuery(this.selector()).addClass("hidden");

    return this;
}

Widget.highlight = function() {
    jQuery(this.selector()).addClass("highlight");

    return this;
}

Widget.unHighlight = function() {
    jQuery(this.selector()).removeClass("highlight");

    return this;
}

Widget.focus = function() {
    jQuery(this.selector()).removeClass("minimized");
    jQuery(this.selector() + " .form-container textarea").focus();

    return this;
}

Widget.append = function(message) {
    if(message.text.replace(/[\s\n]/g, "").length > 0) {
        jQuery(this.selector() + " .messages").append(message.toHtml(this.lastSenderId)).gemoticon();
        this.lastSenderId = message.sender.id;

        this.scrollToBottom();
    }

    return this;
}

Widget.scrollToBottom = function() {
    var messageContainer = jQuery(this.selector() + " .messages");
    var scrollTop = messageContainer.scrollTop();
    do {
        scrollTop = scrollTop + 1000;
        messageContainer.scrollTop(scrollTop);
    } while(messageContainer.scrollTop() >= scrollTop)

    return this;
}

Widget.registerEvents = function() {
    widget = this;

    var widgetSelector = widget.selector();
    var friendId = widget.friendId;

    jQuery(widgetSelector + " .widget-min").click(function() {
        jQuery(widgetSelector).addClass("minimized");
        jQuery(widgetSelector).removeClass("highlight");
    });

    jQuery(widgetSelector + " .widget-max").click(function() {
        jQuery(widgetSelector).removeClass("minimized");
        jQuery(widgetSelector).removeClass("highlight");
    });

    jQuery(widgetSelector + " .widget-close").click(function() {
        Widgets.find(friendId).hide();
    });

    jQuery(widgetSelector + " .form-container textarea").keypress(function(event) {
        if(!event.shiftKey) {
            if(event.keyCode == 13) {
                var sender = {
                    id: Chat.thisUser.id,
                    name: "Me"
                };
                var reciever = Users.find(friendId);
                var message = Messages.create(jQuery(this).val(), sender, reciever);

                Chat.sendMessage(message)
                Widgets.find(friendId).append(message);
                jQuery(this).val("");
                return false;
            }
        }
    });

    jQuery(widgetSelector + " .form-container textarea").focus(function(event) {
        jQuery(widgetSelector).removeClass("highlight");
    });

    return widget;
}

Widgets.find = function(i) {
    if(this.objects == undefined)
        this.objects = {};
    return (this.objects[i] || false);
}

Widgets.create = function(friendId, friendName, friendAge, friendPhoto, friendGender, friendStatus) {
    //Widgets.open(friendId)
    if(Widgets.find(friendId))
        return false;

    var widget = jQuery.extend({
        id: "chat-widget-" + friendId,
        friendId: friendId,
        friendName: friendName,
        friendAge: friendAge,
        friendPhoto: friendPhoto,
        friendGender: friendGender,
        friendStatus: friendStatus
    }, Widget);
    this.objects[friendId] = widget;

    jQuery("#chat-widgets-container").append(jQuery("#widgetTemplate").tmpl(widget));
    
    widget.registerEvents();
    
    return widget;
}

Widgets.close = function(i) {
    jQuery.noSpinner = true;
    if(this.objects != undefined){
        // Ajax to delete chat user from session
        jQuery.ajax({
            url: "/chat/"+i+"/close_chat_window/",
            type: "POST",
            success: function(data) {
                // delete i from opened_chat_windows js variable
                opened_chat_windows = jQuery.grep(opened_chat_windows, function(value) {
                    return i != value;
                });
            }
        });
    }
    jQuery.noSpinner = false;
}

Widgets.open = function(i) {
    jQuery.noSpinner = true;
    // check the sender in opened_chat_windows js array variable if not there then make ajax to add sender to session
    if(jQuery.inArray(i, opened_chat_windows) == -1){
        jQuery.ajax({
            url: "/chat/"+i+"/open_chat_window/",
            type: "POST",
            success: function(data) {
                // add obj.sender_id to opened_chat_windows js variable
                opened_chat_windows.push(i)
            }
        });
    }
    jQuery.noSpinner = false;
}
