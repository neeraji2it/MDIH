// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require tinymce-jquery

jQuery(document).ajaxStart(function(settings){
    if(!jQuery.noSpinner)
        jQuery('#ajax_loader_big_div').show();
});
jQuery(document).ajaxStop(function(){
    jQuery('#ajax_loader_big_div').hide();
});

jQuery('#signup_step2').bind("ajax:success", function(){
    if ( $(this).data('remotipartSubmitted') ) {
}
});

function signup(){
    jQuery.ajax({
        url: "/users/new/",
        success: function(data) {
            jQuery('#popup_body3').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box3').show();
        }
    });
}

function submit_account_form(){
    if(!jQuery('form #accept').is(':checked')){
        alert('Please accept agreement');
    }else{
        jQuery('#captcha_error').html('');
        jQuery('#accept_error').html('');

        jQuery('#signup_step2').ajaxSubmit({
            beforeSubmit: function(a,f,o){
                o.dataType = 'json';
            }
        })
    }
}

function hide_popup(){
    var popups = ["", "2", "3", "4"]
    for(i=0; i<popups.length; i++){
        if(jQuery('#popup_box'+popups[i])){
            jQuery('#popup_body'+popups[i]).html("");
            jQuery('#popup_box'+popups[i]).hide();
        }
    }

    //    if(jQuery('#popup_box2')){
    //        jQuery('#popup_body2').html("");
    //        jQuery('#popup_box2').hide();
    //    }
    //    if(jQuery('#popup_box3')){
    //        jQuery('#popup_body3').html("");
    //        jQuery('#popup_box3').hide();
    //    }
    if(jQuery('#personal_message')){
        jQuery('#personal_message').hide();
    }

    if(jQuery('#overlay')){
        jQuery('#overlay').hide();
    }
}

function show_login_form(){
    if(jQuery('#login_form') && document.getElementById('login_form').style.display == "none"){
        jQuery('#user_login_form').show();
        jQuery('#forgot_password_form').hide();
        jQuery('#resend_activation_email').hide();
        jQuery('#login_flash').html("");
    //        jQuery('#login_form').show();
    //jQuery('#login_form').slideToggle('slow');
    }else{
    //jQuery('#login_form').hide();
    }
    jQuery('#login_form').slideToggle('slow');
}


function hide_login(){
    jQuery('div.user-drop').hide();
}

function hide_forgot(){
    jQuery('#user_login_form').show();
    jQuery('#forgot_password_form').hide();
    jQuery('#resend_activation_email').hide();
    jQuery('#login_flash').html("");
}

function show_forgot_password_form(){
    jQuery('#resend_activation_email').hide();
    jQuery('#forgot_password_flash').html("");
    jQuery('#email').val("");
    jQuery('#user_login_form').hide();
    jQuery('#forgot_password_form').show();

}

function show_reactivation_form(){
    jQuery('#user_login_form').hide();
    jQuery('#forgot_password_form').hide();
    jQuery('#resend_activation_flash').html("");
    jQuery('#reactivation_email').val("");
    jQuery('#resend_activation_email').show();
}

function save_search(){
    var data = jQuery("#save_search_form").html()
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
        content : data
    });
}
function validate_search_form(){
    if(jQuery("saved_search_name").value == 0){
        jQuery("name_error").innerHTML = "Name can't be blank"
        return false;
    }
}

function validate_message_form(){
    jQuery('#to_error').html('');
    jQuery('#headline_error').html('')
    if(document.getElementById('tokenize').value == 0){
        jQuery('#to_error').html('To address can not be blank');
        return false;
    }else if(document.getElementById('message_subject').value == 0){
        jQuery('#headline_error').html('Headline can not be blank');
        return false;
    }
}
function validate_draft_message_form(){
    jQuery('#headline_error').html('');

    if(document.getElementById('message_subject').value == 0){
        jQuery('#headline_error').html('Headline can not be blank');
        return false;
    }else{
        jQuery('#message_message_type').val('draft');
    }
}

function new_album(user_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/albums/new",
        success: function(data) {
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
                content : data
            });
        }
    });
}

function edit_album(user_id, album_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/albums/"+album_id+"/edit",
        success: function(data) {
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
                content : data
            });
        }
    });
}
// function used in upload photos
var photos = [1,2,3,4,5]
var reload_album = false;
function remove_photo_upload_errors(){
    for(i=1; i<=photos.length; i++){
        jQuery('#photo_'+i).html("")
    }
}

function upload_photos(){
    upload(1)
}

function upload(image){
    if(image <= photos.length){
        if( document.getElementById('image_'+image).value != 0){
            reload_album = true;
            jQuery('#photoForm'+image).ajaxSubmit({
                iframe: true,
                beforeSubmit: function(a,f,o){
                    o.dataType = 'json';
                    jQuery('#upload_photo_'+image).show();
                }
            })

        }
        else if(image <= 5){
            upload(image+1);
        }
    //        setTimeout("upload("+image+1+")",30000)
    }else if(image > 5){
        window.location.href =  window.location.href //reload( false );
    }
}


function ajax_upload(){
    jQuery("form#photoForm").each(function(index){
        var i = index + 1;
        if(jQuery("#image_"+i).val() != ""){
            jQuery('#upload_photo_'+i).show();
            jQuery(this).ajaxSubmit({
                success: function(data){
                    if(data==="true"){
                        jQuery('#upload_photo_'+i).hide();
                        jQuery('#image_'+i).hide();
                        jQuery('#photo_'+i).text("Uploaded Successfully");
                    }
                    else{
                        jQuery('#upload_photo_'+i).hide();
                        jQuery('#photo_'+i).html("<div style='color:red;'>Error uploading image.</div>");
                    }
                }
                
            });
        }
    });
}
// ------- end ---------

function expan_search_options(id, field){
    if(jQuery('#'+id+'_link').html() == '[+] '+field){
        jQuery('#'+id+'_link').html('[-] '+field)
    // jQuery('#'+id).show();
    }else{
        jQuery('#'+id+'_link').html('[+] '+field)
    // jQuery('#'+id).hide()
    }
    jQuery('#'+id).slideToggle('slow');
}

function expan_all_search_options(){
    var searc_options = ["height", "ethnicity", "personality", "languages", "marital_status",  "want_kids",
    "religion", "smoke", "drink", "drugs", "education_level", "profession", "income_level"
    ]

    //    var searc_options = ["height", "weight", "ethnicity", "skin_color", "eye_color", "hair_color",
    //    "personality", "languages", "marital_status", "has_kids",  "want_kids",
    //    "religion", "fetish", "sexual_activity", "smoke", "drink", "drugs",
    //    "zodiac_sign", "education_level", "profession", "income_level",  "favorite_music",
    //    "favorite_movies", "favorite_actors", "favorite_tv_show", "favorite_books",
    //    "favorite_authors", "role_model", "favorite_type_of_cuisine", "favorite_sports", "favorite_clubs",
    //    "favorite_resaurants", "favorite_avtivity", "ideal_places", "ideal_vacation", "interests",
    //    "body_hair", "best_feature", "political_view", "favorite_food"
    //    ]

    if(jQuery('#expand_all').html() == 'Expand all'){
        jQuery('#expand_all').html('hide all');
        for(i=0; i<searc_options.length; i++){
            var field = jQuery('#'+searc_options[i]+'_link').html().split(']')[1]
            jQuery('#'+searc_options[i]+'_link').html('[-] '+field);
            jQuery('#'+searc_options[i]).show();
        }
    }else{
        jQuery('#expand_all').html('Expand all');
        for(i=0; i<searc_options.length; i++){
            var field = jQuery('#'+searc_options[i]+'_link').html().split(']')[1]
            jQuery('#'+searc_options[i]+'_link').html('[+] '+field);
            jQuery('#'+searc_options[i]).hide();
        }
    }
}

function zip_hint(id, message){
    var hint = document.getElementById(id).value;
    if(hint==message){
        document.getElementById(id).style.color = "#000000";
        document.getElementById(id).value='';
    }
    else if(hint == 0){
        document.getElementById(id).style.color = "#CFCFCF";
        document.getElementById(id).value = message;
    }
}

function reload_with_new_param(param, value){
    var per_page_added = false;
    var url = window.location.href;
    var base_url = window.location.href.indexOf('?') > 0 ? window.location.href.split("?")[0] :  window.location.href
    var new_params = "";
    var params = window.location.href.indexOf('?') > 0 ? window.location.href.split("?")[1] : ""
    if(params != ""){
        var parts = params.indexOf('&') > 0 ? params.split("&") : new Array(params)
        for (var i = 0; i < parts.length; i++ )
        {
            if( parts[i].split("=")[0] == param){
                per_page_added = true
                new_params = new_params + (new_params == 0 ? "?"+param+"="+value : "&"+param+"="+value)
            }else{
                if(parts[i].split("=")[0] != param){
                    new_params = new_params + (new_params == 0 ? "?"+parts[i] : "&"+parts[i])
                }
            }
        }
        new_params = !per_page_added ? (new_params != 0 ? new_params+"&"+param+"="+value : "?+param+"+value ) : new_params
    }
    window.location.href = base_url + (new_params == 0 ? "?"+param+"="+value : new_params)
}

function change_schedule_status(user_id, id, status){
    jQuery.ajax({
        url: "/users/"+user_id+"/schedules/"+id+"/change_status",
        data: {
            status: status
        },
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function view_dates(){
    var from_date = jQuery('#from').val()
    var to_date = jQuery('#to').val()
    if(from_date != 0 && to_date != 0){
        window.location.href = update_param(update_param(window.location.href, 'from_date', from_date), 'to_date', to_date)
    }else{
        alert('Please select from and to dates')
    }

}

function update_param(url, param, value){
    var per_page_added = false;
    var base_url = url.indexOf('?') > 0 ? url.split("?")[0] :  url
    var new_params = "";
    var params = url.indexOf('?') > 0 ? url.split("?")[1] : ""
    if(params != ""){
        var parts = params.indexOf('&') > 0 ? params.split("&") : new Array(params)
        for (var i = 0; i < parts.length; i++ )
        {
            if( parts[i].split("=")[0] == param){
                per_page_added = true
                new_params = new_params + (new_params == 0 ? "?"+param+"="+value : "&"+param+"="+value)
            }else{
                if(parts[i].split("=")[0] != param){
                    new_params = new_params + (new_params == 0 ? "?"+parts[i] : "&"+parts[i])
                }
            }
        }
        new_params = !per_page_added ? (new_params != 0 ? new_params+"&"+param+"="+value : "?+param+"+value ) : new_params
    }
    return (base_url + (new_params == 0 ? "?"+param+"="+value : new_params));
}

function edit_profile_photo(user_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/profiles/edit_photo",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function upload_profile_photo(){
    jQuery('#profile_photo').ajaxSubmit({
        beforeSubmit: function(a,f,o){
            o.dataType = 'json';
        }
    })
}

function select_all_contacts(element, contacts_length){
    for(i=0; i<contacts_length; i++){
        if(jQuery('#contact_'+i)){
            if(element.checked){
                jQuery('#contact_'+i).attr('checked', true);
            }else{
                jQuery('#contact_'+i).attr('checked', false);
            }
        }
    }
}

function add_contact(user_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/contacts/new",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function edit_contact(user_id, contact_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/contacts/"+contact_id+"/edit",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function validate_inviters(contacts_length){
    var valid = false
    for(i=0; i<contacts_length; i++){
        if(jQuery('#contact_'+i)){
            if(jQuery('#contact_'+i).is(':checked')){
                valid = true;
            }
        }
    }
    if(!valid){
        alert('Please select atleast one contact to invite')
    }else{
        jQuery('#personal_message').show();
        jQuery('#overlay').show();
    //        jQuery('#popup_box').show();
    }
    return valid
}

function send_invitation(){
    document.getElementById('message').value = document.getElementById('invitation_message').value;
    document.invite_form.submit();
}

function select_template(user_id, send_to){
    var to = ""
    if(send_to != 0)
        to = "?send_to="+send_to
    jQuery.ajax({
        url: "/users/"+user_id+"/message_templates/select_template"+to,
        success: function(data) {
            jQuery('#popup_body2').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box2').show();
        }
    });
}

function send_quick_message(user_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/quick_messages/new",
        success: function(data) {
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
                content : data
            });
        }
    });
}


function delete_all_messages(user_id,receiver_id,current_user){
    //    var html="<div style='width:200px;height:120px;font-size:15px;'><img src='/images/close button.png' width = 40 height = 40 style = 'cursor: pointer;float:right;margin : -40px -40px;' border =0  onclick = 'hide_popup();')><a href='/users/"+user_id+"/messages/"+receiver_id+"/delete_all_messages' method='GET' data-remote='true' style='font-size:15px;'>Delete All</a><br /><br /><a href='/searches/"+receiver_id+"/block_user'  method='GET' data-remote='true' style='font-size:15px;'>Block User</a></div>";
    if (current_user == user_id){
        var html="<div class='new-message-popup'>\n\
<header class='heading'>\n\
<h3>delete messages or block this user</h3>\n\
<a href='#' class='close' id='fancybox_close'>close</a>\n\
 </header>\n\
<div style='padding:20px;'> \n\
 <a href='/users/"+user_id+"/messages/"+receiver_id+"/delete_all_messages' method='GET' data-remote='true' style='font-size:15px;'>Delete all messages with this user?</a><br /><br />\n\
<a href='/searches/"+receiver_id+"/block_user'  method='GET' data-remote='true' style='font-size:15px;'>Block this user.</a>\n\
</div>\n\
</div>"
    }else if(current_user == receiver_id){
        var html="<div class='new-message-popup'>\n\
<header class='heading'>\n\
<h3>delete messages or block this user</h3>\n\
<a href='#' class='close' id='fancybox_close'>close</a>\n\
 </header>\n\
<div style='padding:20px;'> \n\
 <a href='/users/"+user_id+"/messages/"+receiver_id+"/delete_all_messages' method='GET' data-remote='true' style='font-size:15px;'>Delete all messages with this user?</a><br /><br />\n\
<a href='/searches/"+user_id+"/block_user'  method='GET' data-remote='true' style='font-size:15px;'>Block this user.</a>\n\
</div>\n\
</div>"
    }
   
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
        content : html
    });
//    $('#popup_body').html("<div style='width:200px;height:120px;font-size:15px;'><img src='/images/close button.png' width = 40 height = 40 style = 'cursor: pointer;float:right;margin : -40px -40px;' border =0  onclick = 'hide_popup();')><a href='/users/"+user_id+"/messages/"+receiver_id+"/delete_all_messages' method='GET' data-remote='true' style='font-size:15px;'>Delete All</a><br /><br /><a href='/searches/"+receiver_id+"/block_user'  method='GET' data-remote='true' style='font-size:15px;'>Block User</a></div>");
//    $('#overlay').show();
//    $('#popup_box').show();
}

function show_recharge_credits_form(){
    jQuery.ajax({
        url: "/users/show_recharge_credits_form",
        success: function(data) {
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
                content : data
            });
        //            jQuery('#popup_body').html(data);
        //            jQuery('#overlay').show();
        //            jQuery('#popup_box').show();
        }
    });
}


function show_user_album_photo(user_id, album_id, id){
    jQuery.ajax({
        url: "/users/"+user_id+"/albums/"+album_id+"/photos/"+id+"/ajax_show",
        success: function(data) {
            jQuery('#show_photo').html(data);
        }
    });
}

function show_inappropriate_dialog(user_id, profile_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/profiles/"+profile_id+"/show_inappropriate_dialog",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function show_photo_inappropriate_form(user_id, album_id, photo_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/albums/"+album_id+"/photos/"+photo_id+"/show_photo_inappropriate_form",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function send_gifts(user_id, category_id){
    var cat = category_id != '' ? '?pcategory_id='+category_id : ''
    jQuery.ajax({
        url: "/users/"+user_id+"/gifts/ajax_send_gifts"+cat,
        success: function(data) {
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
                content : data
            });
        }
    });
}

function profile(user_id){
    jQuery.ajax({
        url: "/users/"+user_id,
        success: function(data) {
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
                content : data
            });
        }
    });
}

function clear_flash_messages_divs(user_id){
    if(jQuery('#add_my_match_status_'+user_id)){
        jQuery('#add_my_match_status_'+user_id).html("");
    }
    if(jQuery('#add_my_match_'+user_id)){
        jQuery('#add_my_match_'+user_id).html("");
    }
    if(jQuery('#blocked_error_'+user_id)){
        jQuery('#blocked_error_'+user_id).html("");
    }
    if(jQuery('#quick_message_status_'+user_id)){
        jQuery('#quick_message_status_'+user_id).html("");
    }
    if(jQuery('#send_gift_status_'+user_id)){
        jQuery('#send_gift_status_'+user_id).html("");
    }
    if(jQuery('#hot_vote_status_'+user_id)){
        jQuery('#hot_vote_status_'+user_id).html("");
    }
    if(jQuery('#add_friend_status_'+user_id)){
        jQuery('#add_friend_status_'+user_id).html("");
    }
}

function view_users(){
    var from_date = jQuery('#from').val()
    var to_date = jQuery('#to').val()
    if(from_date != 0 && to_date != 0){
        window.location.href = update_param(update_param(window.location.href, 'from_date', from_date), 'to_date', to_date)
    }else{
        alert('Please select from and to dates')
    }

}

// to move option value from one select box to another select box

function shiftRight(removeOptions,addOptions,saveFlag)
{
    var availableOptions = document.getElementById(removeOptions);
    var assignedOptions = document.getElementById(addOptions);
    var selcted_Options = new Array();
    for(i=availableOptions.options.length-1;i>=0;i--)
    {
        if(availableOptions.options[i].selected){
            var optn = document.createElement("OPTION");
            optn.text = availableOptions.options[i].text;
            optn.value = availableOptions.options[i].value;
            assignedOptions.options.add(optn);
            availableOptions.remove(i);
        }else{
            selcted_Options.push(availableOptions.options[i].value);
        }
    }

    document.getElementById('selected_Options').value = selcted_Options
}
function shiftLeft(removeOptions,addOptions,saveFlag)
{
    var availableOptions = document.getElementById(removeOptions);
    var assignedOptions = document.getElementById(addOptions);
    var selcted_Options = new Array();
    for (i=0;i<assignedOptions.options.length; i++){
        selcted_Options.push(assignedOptions.options[i].value);
    }
    for (i=0; i<availableOptions.options.length; i++){
        if (selcted_Options.indexOf(availableOptions.options[i].value) <0 && availableOptions.options[i].selected) {
            selcted_Options.push(availableOptions.options[i].value);
            var optn = document.createElement("OPTION");
            optn.text = availableOptions.options[i].text;
            optn.value = availableOptions.options[i].value;
            assignedOptions.options.add(optn);
        }
    }
    for(i=availableOptions.options.length-1;i>=0;i--)
    {
        if(availableOptions.options[i].selected)
            availableOptions.remove(i);
    }
    document.getElementById('selected_Options').value = selcted_Options;
}

function new_product_category(action){
    jQuery.ajax({
        url: "/admin/pcategories/new?from_action="+action,
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function edit_product_category(product_id){
    jQuery.ajax({
        url: "/admin/pcategories/"+product_id+"/edit",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function show_match_login_history(user_id, match_id){
    match_login_graph = findSWF("match_login_graph");
    jQuery.ajax({
        url: "/users/"+user_id+"/statistics/"+match_id+"/match_login_history",
        success: function(data) {
            match_login_graph.load(data);
        }
    });

}

function findSWF(movieName) {
    if (navigator.appName.indexOf("Microsoft")!= -1) {
        return window["ie_" + movieName];
    } else {
        return document[movieName];
    }
}

function show_email_response_by_category(){
    var country = jQuery('#country').val();
    var age_from = jQuery('#age_from').val();
    var age_to = jQuery('#age_to').val();
    if(country != '' && age_from != '' && age_to != ''){
        email_response_by_category = findSWF("email_response_by_category");
        jQuery.ajax({
            url: "/admin/statistics/email_responses_by_category?country="+country+"&age_from="+age_from+"&age_to="+age_to,
            success: function(data) {
                email_response_by_category.load(data);
            }
        });
    }

}

function change_user_credits(user_id){
    jQuery('#change_credits_status_'+user_id).html("");
    jQuery.ajax({
        url: "/admin/users/"+user_id+"/change_credits",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}


function update_profile_headline(user_id){
    jQuery.ajax({
        url: "/users/"+user_id+"/profiles/update_headline",
        success: function(data) {
            jQuery('#popup_body').html(data);
            jQuery('#overlay').show();
            jQuery('#popup_box').show();
        }
    });
}

function show_flash_messages(message){
    jQuery(function () {
        jQuery.notifyBar({
            cls: "error",
            html: message,
            delay: 1000000,
            animationSpeed: "normal",
            close: true
        });
    });
}

function expan_all_profile_options(){
    var searc_options = [
    "who_am_i", "what_is_my_passion","important_things","funny_story_when_we_meet","my_pet_peeves_are","i_am_really_good_at","favorite_books_music_movies","embarrassing_thing","anything_i_want",
    "things_i_would_never_do", "my_friends_tell_me_that_i_am", "private_about_me", "my_bucket_list", "on_a_normal_weekend_i", "most_interesting_place", "weirdest_thing_that_i_know", "i_fear_the_most", "my_best_feature_is"
    ]
    //    var searc_options = ["height", "ethnicity", "personality","languages", "marital_status", "want_children", "religion","smoke", "drink", "drugs", "pets",
    //    "education_level", "profession",  "income_level",
    //    "who_am_i", "what_is_my_passion","important_things","funny_story_when_we_meet","my_pet_peeves_are","i_am_really_good_at","favorite_books_music_movies","embarrassing_thing","anything_i_want",
    //    "things_i_would_never_do", "my_friends_tell_me_that_i_am", "private_about_me", "my_bucket_list", "on_a_normal_weekend_i", "most_interesting_place", "weirdest_thing_that_i_know", "i_fear_the_most", "my_best_feature_is"
    //    ]
    //    var searc_options = ["height", "weight", "ethnicity", "skin_color", "eye_color", "hair_color", "personality", "body_hair",
    //    "best_feature", "languages", "marital_status", "want_children",  "num_of_children", "religion", "fetish", "sexual_activity",
    //    "smoke", "drink", "drugs", "zodiac_sign", "chinese_calendar", "pets",
    //    "political_view", "i_am_a", "education_level", "profession",  "income_level",
    //    "favorite_food", "favorite_sports", "favorite_clubs", "favorite_resaurants",
    //    "favorite_music", "favorite_movies", "favorite_actors","favorite_tv_show","favorite_books", "favorite_authors", "favorite_avtivity",
    //    "favorite_type_of_cuisine", "role_model","ideal_places","ideal_vacation", "interests",
    //    "who_am_i", "what_is_my_passion", "when_i_am_not_working_i", "cannot_live_without"
    //    ]
    if(jQuery('#expand_all').html() == 'Expand all'){
        jQuery('#expand_all').html('hide all');
        for(i=0; i<searc_options.length; i++){
            var field = jQuery('#'+searc_options[i]+'_link').html().split(']')[1]
            jQuery('#'+searc_options[i]+'_link').html('[-] '+field);
            jQuery('#'+searc_options[i]).show();
        }
    }else{
        jQuery('#expand_all').html('Expand all');
        for(i=0; i<searc_options.length; i++){
            var field = jQuery('#'+searc_options[i]+'_link').html().split(']')[1]
            jQuery('#'+searc_options[i]+'_link').html('[+] '+field);
            jQuery('#'+searc_options[i]).hide();
        }
    }
}

function get_more_gifts(user_id, page){
    jQuery('#more_gifts_link').remove();
    var category_id = jQuery('#pcategory_id').val()
    var cat = category_id != '' ? '&pcategory_id='+category_id : ''
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#gift_list').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/gifts/ajax_send_gifts?page="+page+cat,
        success: function(data) {
            jQuery('#gift_list').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}


function more_inbox_messages(user_id, page){
    jQuery('#more_inbox_messages_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#inbox_messages').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/messages/display/inbox?page="+page,
        success: function(data) {
            jQuery('#inbox_messages').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function more_index_sent_messages(user_id, page){
    jQuery('#more_sent_messages_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#sent_messages').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/messages/display/sent?page="+page,
        success: function(data) {
            jQuery('#sent_messages').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function more_messages(user_id, page){
    jQuery('#more_messages_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_messages').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/messages/display/unread?page="+page,
        success: function(data) {
            jQuery('#more_messages').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function more_photos(user_id, album_id, page){
    jQuery('#more_photos_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_photos').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/albums/"+album_id+"?page="+page,
        success: function(data) {
            jQuery('#more_photos').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function more_friends(user_id, page){
    jQuery('#more_friends_link').remove();
    var sort_id = jQuery('#sort').val()
    var sort = sort_id != '' ? '&sort='+sort_id : ''
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_friends').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/friends?page="+page+sort,
        success: function(data) {
            jQuery('#more_friends').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function more_blocked_users(page){
    jQuery('#more_friends_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_friends').append($("#auto_scroll_img").show());
        },
        url: "/searches/blocked_users?page="+page,
        success: function(data) {
            jQuery('#more_friends').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}




function  more_index_received_gifts(user_id, page){
    jQuery('#more_gifts_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_gifts').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/gifts/received?page="+page,
        success: function(data) {
            jQuery('#more_gifts').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function  more_index_sent_gifts(user_id, page){
    jQuery('#more_gifts_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_gifts').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/gifts/sent?page="+page,
        success: function(data) {
            jQuery('#more_gifts').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}


function  more_sent_gifts(user_id1,user_id2, page){
    jQuery('#more_sent_gifts_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_sent_gifts').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id1+"/gifts/"+user_id2+"/sent_gifts?page="+page,
        success: function(data) {
            jQuery('#more_sent_gifts').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}


function  more_received_gifts(user_id1,user_id2, page){
    jQuery('#more_received_gifts_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_received_gifts').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id1+"/gifts/"+user_id2+"/received_gifts?page="+page,
        success: function(data) {
            jQuery('#more_received_gifts').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}


function  more_albums(user_id, page){
    jQuery('#more_albums_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_albums').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/albums?page="+page,
        success: function(data) {
            jQuery('#more_albums').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
    
}

function  more_popup_albums(user_id, page){
    jQuery('#more_popup_albums_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_popup_albums').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id+"/albums/albums_popup?page="+page,
        success: function(data) {
            jQuery('#more_popup_albums').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });

}

function  more_new_chats(page){
    jQuery('#more_new_chats_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_new_chats').append($("#auto_scroll_img").show());
        },
        url: "/chat/new_chats?page="+page,
        success: function(data) {
            jQuery('#more_new_chats').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function  more_index_chats(page){
    jQuery('#more_index_chats_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_index_chats').append($("#auto_scroll_img").show());
        },
        url: "/chat?page="+page,
        success: function(data) {
            jQuery('#more_index_chats').append(data);
            jQuery(".text-block").gemoticon();
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function  more_chats(user_id, page){
    jQuery('#more_chats_link').remove();
    var sort_id = jQuery('#sort').val()
    var sort = sort_id != '' ? '&sort='+sort_id : ''
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_chats').append($("#auto_scroll_img").show());
        },
        url: "/chat/"+user_id+"?page="+page+sort,
        success: function(data) {
            jQuery('#more_chats').append(data);
            jQuery(".message-item-holder").gemoticon();
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });
}

function   more_notifications(page){
    jQuery('#more_notifications_link').remove();
    jQuery.ajax({
        beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_notifications').append($("#auto_scroll_img").show());
        },
        url: "?page="+page,
        success: function(data) {
            jQuery('#more_notifications').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });

}

function   more_conversations(user_id1,user_id2,page){
    jQuery('#more_conversations_link').remove();
    jQuery.ajax({
          beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_conversations').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id1+"/messages/"+user_id2+"/conversation?page="+page,
        success: function(data) {
            jQuery('#more_conversations').append(data);
             jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });

}

function   more_sent_messages(user_id1,user_id2,page){
    jQuery('#more_sent_messages_link').remove();
    jQuery.ajax({
          beforeSend: function() {
            $('#ajax_loader_big_div').hide();
            jQuery('#more_messages').append($("#auto_scroll_img").show());
        },
        url: "/users/"+user_id1+"/messages/"+user_id2+"/sent_messages?page="+page,
        success: function(data) {
            jQuery('#more_sent_messages').append(data);
            jQuery("#auto_scroll_img").remove();
        //jQuery('#templates').animate({scrollTop: jQuery('#templates')[0].scrollHeight});
        }
    });

}


//chat message delete

function delete_chat_message(chat_message_id){
    if(confirm("Are you sure?")){
        jQuery.ajax({
            url: "/chat/"+chat_message_id,
            type: "DELETE",
            success:  function(data){
                alert("Message was successfully deleted.");
                jQuery("#message_"+chat_message_id).hide();
                return false;
            }
        });
   
    } else {
        return false;
    }
}


//delete messages

function delete_message(user_id,message_id){
    if(confirm("Are you sure?")){
        jQuery.ajax({
            url: "/users/"+user_id+"/messages/"+message_id,
            type: "DELETE",
            success:  function(data){
                alert("Message was successfully deleted.");
                jQuery("#message_"+message_id).hide();
                return false;
            }
        });

    } else {
        return false;
    }
}

//delete messages

function delete_gift(user_id,gift_id){
    if(confirm("Are you sure?")){
        jQuery.ajax({
            url: "/users/"+user_id+"/gifts/"+gift_id,
            type: "DELETE",
            success:  function(data){
                alert("Gift was successfully deleted.");
                jQuery("#message_"+gift_id).hide();
                return false;
            }
        });

    } else {
        return false;
    }
}

// this is pagination js

$(function() {
    $(".pagination a").live("click", function() {
        $.getScript(this.href);
        return false;
    });
});


function update_user_status(){
    jQuery.noSpinner = true
    jQuery.ajax({
        url: "/users/change_online_status",
        type: "POST"
    });
    jQuery.noSpinner = false
}

//show message templates
function show_templates(){
    if(jQuery('#message_templates') && document.getElementById('message_templates').style.display == "none"){
        jQuery('#templates-bg').show();
    }else{

    }
    jQuery('#message_templates').slideToggle('slow');
}

//show smilies
function show_smilies(){
    if(jQuery('#message_smilies') && document.getElementById('message_smilies').style.display == "none"){
        jQuery('#smilies-bg').show();
    }else{

    }
    jQuery('#message_smilies').slideToggle('slow');
}

//Display Emotions
jQuery(document).ready(function(){
    $(".gifts-message-holder").gemoticon();
    $(".message-item-holder").gemoticon();
    $(".text-block").gemoticon();
});

//Insert Emotions into append textarea value based on cursor position
jQuery.fn.extend({
    insertAtCaret: function(emotionsValue){
        return this.each(function(i) {
            if (document.selection) {
                //For browsers like Internet Explorer
                this.focus();
                sel = document.selection.createRange();
                sel.text = emotionsValue;
                this.focus();
            }
            else if (this.selectionStart || this.selectionStart == '0') {
                //For browsers like Firefox and Webkit based
                var startPos = this.selectionStart;
                var endPos = this.selectionEnd;
                var scrollTop = this.scrollTop;
                this.value = this.value.substring(0, startPos)+emotionsValue+this.value.substring(endPos,this.value.length);
                this.focus();
                this.selectionStart = startPos + emotionsValue.length;
                this.selectionEnd = startPos + emotionsValue.length;
                this.scrollTop = scrollTop;
            } else {
                this.value += emotionsValue;
                this.focus();
            }
        })
    }
});
