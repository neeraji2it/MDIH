jQuery(document).ready(function(){
    UserNav.init();
    PhotoNav.init();
    GiftNav.init();
    MessageNav.init();
    ChatNav.init();
    SearchNav.init();
    FavoritesNav.init();
});

var UserNav = function(){

    var init = function(){
        jQuery("#account_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#account_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/users/"+account_id,
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }else{
                //                jQuery("#fancybox-wrap").fadeOut('slow');
                //                          jQuery.fancybox.close();
            }
        });

        jQuery("#fancybox_close").live('click', function(event){
            //           jQuery("#fancybox-content").hide();
//            jQuery("#fancybox-wrap").fadeOut('slow');
                               jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();

var PhotoNav = function(){

    var init = function(){
        jQuery("#photo_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#photo_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/users/"+account_id+"/albums/albums_popup",
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }else{
                jQuery.fancybox.close();
            }
        });

        $("#fancybox_close").live('click', function(event){
            jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();

var GiftNav = function(){

    var init = function(){
        jQuery("#gift_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#gift_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/users/"+account_id+"/gifts/gifts_popup",
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }else{
                jQuery.fancybox.close();
            }
        });

        $("#fancybox_close").live('click', function(event){
            jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();

var MessageNav = function(){

    var init = function(){
        jQuery("#message_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#message_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/users/"+account_id+"/messages/display/unread",
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }else{
                jQuery.fancybox.close();
            }
        });

        $("#fancybox_close").live('click', function(event){
            jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();

var ChatNav = function(){

    var init = function(){
        jQuery("#chat_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#chat_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                //                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/chat/new_chats",
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }else{
                jQuery.fancybox.close();
            }
        });

        $("#fancybox_close").live('click', function(event){
            jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();

var SearchNav = function(){

    var init = function(){
        jQuery("#search_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#search_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                //                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/searches/near_by",
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }else{
                jQuery.fancybox.close();
            }
        });

        $("#fancybox_close").live('click', function(event){
            jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();

var FavoritesNav = function(){

    var init = function(){
        jQuery("#favorite_profile").click(function(event){
            window.location.href = $(event.href);
        });

        jQuery("#favorite_profile").bind("mousestop", function(event){
            if(event.type == "mousestop"){
                var account_id = $(this).data("account_id");
                $.ajax({
                    url: "/users/"+account_id+"/friends/online_friends",
                    type: 'get',
                    success: function(resp){
                        jQuery.fancybox({
                            padding: 15,
                            cyclic: false,
                            overlayShow: true,
                            transitionIn:'elastic',
                            transitionOut:'elastic',
                            speedIn:600,
                            speedOut:600,
                            overlayOpacity:0,
                            titlePosition: 'inside',
                            content : resp
                        });
                    }
                });
            }
        });
        
        $("#fancybox_close").live('click', function(event){
            jQuery.fancybox.close();
            event.preventDefault();
        })
    }


    return {
        init :init
    }
}();




