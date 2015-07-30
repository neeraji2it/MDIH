var Users = {}
var User = {}

User.selector = function() {
    return {
        id:"#chat-users-container #chat-user-" + this.id,
        class_name: ".chat-user-" + this.id
    };
}

User.update = function(user) {
    if(user.id)
        this.id = user.id;
  
    if(user.login)
        this.name = user.login;

    if(user.status)
        this.status = user.status;

    return this;
}

User.updateStatus = function() {
    jQuery(this.selector().class_name).attr("class","user " + "chat-user-" + this.id + " chat-user " + this.status);
}

Users.find = function(i) {
    if(this.objects == undefined)
        this.objects = {};

    return (this.objects[i] || false);
}

Users.create = function(user) {
    if(Users.find(user.id))
        return false;

    var user = jQuery.extend(user, User);
    this.objects[user.id] = user;

    jQuery("#chat-users-container #chat-users-body").append(jQuery("#user-template").tmpl(user));

    jQuery(user.selector().id).click(function() {
      // console.log("Clicking on user to chat!!!");
        widget = Widgets.open(user.id) || Widgets.find(user.id) || Widgets.create(user.id, user.login, user.age, user.profile_image, user.gender, user.status);
        widget.show();
        widget.focus();

        user.updateStatus();
    });

    return user;
}

jQuery(document).ready(function() {
    jQuery("#chat-users-container #chat-users-header").click(function() {
        jQuery(this).parents("#chat-users-container").toggleClass("minimized");
    });
});
