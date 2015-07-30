# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_to_chat(title, user, options={})
    link_to_function title, "(Widgets.open(#{user.id})) || (Widgets.find(#{user.id}) || Widgets.create(#{user.id}, '#{user.display_name}','#{user.age}', '#{(user.facebook_id.present? ? (user.profile ? (user.profile.avatar_file_name != "picture_type_large.jpg" ? user.profile.avatar.url(:original) : user.fb_big_image) : user.fb_big_image) : (user.profile ? user.profile.avatar.url(:original)  : "/assets/default_avatar.jpg"))}', '#{user.gender}', '#{user.online_status}')).show().focus();", options
  end

  def get_chat_link(user, link_title=I18n.t('helper.link_title'), link_options={})
    if current_user and user.id != current_user.id and user.is_online?
      link_to_chat(link_title, user, link_options)
    end
  end

  # Display validation error with red color
  def validation_errors(message)
    if message.class.to_s == "Array"
      message = message.join(", ")
    end
    return !message.to_s.blank? ? ("<div style='color: red;'>"+message.to_s+"</div>").html_safe : ""
  end

  def validation_error(message)
    if message.class.to_s == "Array"
      message = message.first
    end
    return !message.to_s.blank? ? ("<div style='color: red;'>"+message.to_s+"</div>").html_safe : ""
  end

  def pending_friends_link
    requested_friends = current_user.requested_friends.count
    link_text = I18n.t('helper.link_text')+ " " +requested_friends.to_s + " "
    if requested_friends > 1
      link_text += I18n.t('helper.link_text1')
    else
      link_text += I18n.t('helper.link_text2')
    end
    return link_to "<blink>#{link_text} request</blink>".html_safe, requested_friends_user_friends_path(current_user), :style => "color:#258216;text-decoration:none;"
  end

  def pending_date_link
    #    requested_date = current_user.date_schedules
    #    requested_date_nos = requested_date.count
    #    requested_date.each do |d|
    #      if d.user_status == "proposed"
    #        link_text = "You have "+requested_date_nos.to_s
    #        return link_to "<blink>"+link_text+" date request(s)</blink>" , user_schedules_path(current_user), :style => "color:#258216;text-decoration:none;"
    #      elsif d.dater_status == "proposed"
    #        link_text = "You have "+requested_date_nos.to_s
    #        return link_to "<blink>"+link_text+" date request(s)</blink>" , whom_i_requested_user_schedules_path(current_user), :style => "color:#258216;text-decoration:none;"
    #      end
    #    end
    new_date_requests = DateSchedule.count(:conditions => ["(dater_id = #{current_user.id} AND user_status = 'proposed' AND dater_status = 'pending')"])
    change_date_requests = DateSchedule.count(:conditions => ["(user_id = #{current_user.id} AND dater_status = 'proposed' AND user_status = 'pending')"])
    date_links = []
    if new_date_requests != 0
      link_text = "#{I18n.t('helper.link_text')} " +  new_date_requests.to_s  +  " #{I18n.t('helper.new_date')}"
      date_links << (link_to "<blink>#{link_text} </blink>".html_safe , user_schedules_path(current_user, :no_date => true, :view => 'pending'), :style => "color:#258216;text-decoration:none;")
    end
    if change_date_requests != 0
      link_text = "#{I18n.t('helper.link_text')} " +  change_date_requests.to_s  +  " #{I18n.t('helper.change_date')}"
      date_links << (link_to "<blink>#{link_text} </blink>".html_safe , whom_i_requested_user_schedules_path(current_user, :no_date => true, :view => 'pending'), :style => "color:#258216;text-decoration:none;")
    end
    return !date_links.empty? ? date_links.join('<br /><br />').html_safe : nil
  end

#  def message_link_text(status)
#    unread_count = status == 'draft' ? Message.count(:conditions => ["user_id = #{current_user.id} and message_type = 'draft'"]) : Message.unread_count(current_user.id)
#    if unread_count > 0
#      message_link_txt = unread_count.to_s
#    else
#      message_link_txt = 0
#    end
#    return message_link_txt
#  end

  def humanized_gender(gender)
    return ['Male', 'male'].include?(gender) ? "Man" : "Women"
  end

  def user_online_status_image(user)
    if user.is_online?
      return  "<span class='status_online'>online</span>".html_safe
    else
      return  "<span class='status_online'>offline</span>".html_safe
    end
  end

  def received_gifts_link_alert(received_gifts_count)
    link_text = I18n.t('helper.link_text3')+received_gifts_count.to_s+I18n.t('helper.link_text4')+ " "
    if received_gifts_count > 1
      link_text +=  I18n.t('helper.link_text5')
    else
      link_text +=  I18n.t('helper.link_text6')
    end
    return link_to "<blink>#{link_text} </blink>".html_safe , my_gifts_path(current_user, 'received'), :style => "color:#258216;text-decoration:none;"
  end
  
end
