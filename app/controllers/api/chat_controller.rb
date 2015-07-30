class Api::ChatController < ApplicationController
  skip_before_filter :verify_authenticity_token, :set_alert_variables, :is_valid_account?, :is_api_current_user?, :http_auth
  # skip_before_filter :is_logged?, :only => [:create, :forgot_password, :contact_us, :feedback]
  # before_filter :is_api_current_user?, :only => [:update]
  # skip_before_filter :is_valid_account?, :only => [:update]
  # skip_before_filter :verify_authenticity_token, :set_alert_variables

  # before_filter :is_api_current_user?

  def initial_data
    updates_hash = {:messages => {}}
    updates_hash[:messages] = current_user.chats.collect(&:json_data)
    updates_hash[:users] = current_user.friends.collect(&:json_data)
    updates_hash[:time] = Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")

    respond_to do |format|
      format.json {render :json => updates_hash.to_json}
    end
  end

  # def updates
  #   updates_hash = {:messages => {}}
  #   if params[:version].present?
  #     version_splits = params[:version].to_s.split('')
  #
  #     day = version_splits.shift(2).join('')
  #     month = version_splits.shift(2).join('')
  #     year = version_splits.shift(4).join('')
  #     hour = version_splits.shift(2).join('')
  #     minutes = version_splits.shift(2).join('')
  #     seconds = version_splits.shift(2).join('')
  #
  #     time = Time.zone.parse("#{day}-#{month}-#{year} #{hour}:#{minutes}:#{seconds}") rescue Time.zone.now
  #   else
  #     time = Time.zone.now
  #   end
  #
  #   # updates_hash[:messages] = current_user.read_chats.collect(&:json_data)
  #   updates_hash[:messages] = current_user.recieved_chats.since(time).collect(&:json_data)
  #   updates_hash[:users] = current_user.friends.collect(&:json_data)
  #   updates_hash[:version] = Time.zone.now.strftime("%d%m%Y%H%M%S")
  #   updates_hash[:time] = Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")
  #
  #   respond_to do |format|
  #     format.json {render :json => updates_hash.to_json}
  #   end
  # end

  def create
    reciever = User.find(params[:reciever_id])
    current_user.sent_chats.new(:text => params[:text], :reciever_id => params[:reciever_id]).save

    if !reciever.is_online?
      @offline = true
      message = Message.new(:body => params[:text], :user_id => current_user.id, :user_status => "sent", :message_type => "sent", :receiver_id => params[:reciever_id], :receiver_status => "unread")
      #      message.to_address(current_user, params[:reciever_id])
      message.save
    end

    if reciever.is_online_on_web?
      messages = reciever.read_chats
      for message in messages
        hash = {:text => message.text, :sender_name => message.sender.name, :sender_id => message.sender.id, :reciever_name => message.reciever.name, :reciever_id => message.reciever.id, :sender_age => message.sender.try(:age), :receiver_age => message.reciever.try(:age), :sender_photo => (message.sender.facebook_id.present? ? (message.sender.profile ? (message.sender.profile.avatar_file_name != "picture_type_large.jpg" ? message.sender.profile.avatar.url(:original) : message.sender.fb_big_image) : message.sender.fb_big_image) : (message.sender.profile ? message.sender.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")), :reciever_photo => (message.reciever.facebook_id.present? ? (message.reciever.profile ? (message.reciever.profile.avatar_file_name != "picture_type_large.jpg" ? message.reciever.profile.avatar.url(:original) : message.reciever.fb_big_image) : message.reciever.fb_big_image) : (message.reciever.profile ? message.reciever.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")), :sender_gender => message.sender.gender, :reciever_gender => message.reciever.gender}
        Juggernaut.publish("users:#{message.reciever.id}:#{current_user.id}", hash.to_json)
      end
    end
    
    render :json => "success"
  end

  def history
    updates_hash = {:messages => {}}
    if params[:unread_only]
      chat_scope = Chat.unread
    elsif params[:read_only]
      chat_scope = Chat.read
    else
      chat_scope = Chat
    end

    user_ids = params[:user_ids].to_s.split(",").collect(&:strip).collect(&:to_i)
    exclude_user_ids = params[:exclude_user_ids].to_s.split(",").collect(&:strip).collect(&:to_i)

    if params[:since].present?
      time = Time.zone.parse(params[:since]) rescue Time.zone.now
      chat_scope = chat_scope.since(time)
    end

    if user_ids.present?
      recieved_messages = chat_scope.to_reciever_ids([current_user.id]).from_sender_ids(user_ids)
      sent_messages = chat_scope.from_sender_ids([current_user.id]).to_reciever_ids(user_ids)
      messages = recieved_messages + sent_messages
    elsif exclude_user_ids.present?
      recieved_messages = chat_scope.to_reciever_ids([current_user.id]).exclude_sender_ids(exclude_user_ids)
      sent_messages = chat_scope.from_sender_ids([current_user.id]).exclude_reciever_ids(exclude_user_ids)
      messages = recieved_messages + sent_messages
    else
      recieved_messages = chat_scope.to_reciever_ids([current_user.id])
      sent_messages = chat_scope.from_sender_ids([current_user.id])
      messages = recieved_messages + sent_messages
    end
    messages = messages.sort{|a, b| a.created_at <=> b.created_at}

    messages.each do |chat|
      chat.read_now if chat.is_unread?
    end

    updates_hash[:messages] = messages.collect(&:json_data)
    # updates_hash[:users] = current_user.friends.collect(&:json_data)
    updates_hash[:time] = Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")
    updates_hash[:counts] = {
      :sent_messages => sent_messages.count,
      :recieved_messages => recieved_messages.count,
      :total => messages.count
    }

    respond_to do |format|
      format.json {render :json => updates_hash.to_json}
    end
  end

  def get_counts
    updates_hash = {}
    if params[:unread_only]
      chat_scope = Chat.unread
    elsif params[:read_only]
      chat_scope = Chat.read
    else
      chat_scope = Chat
    end

    user_ids = params[:user_ids].to_s.split(",").collect(&:strip).collect(&:to_i)
    exclude_user_ids = params[:exclude_user_ids].to_s.split(",").collect(&:strip).collect(&:to_i)

    if params[:since].present?
      time = Time.zone.parse(params[:since]) rescue Time.zone.now
      chat_scope = chat_scope.since(time)
    end

    if user_ids.present?
      recieved_messages = chat_scope.to_reciever_ids([current_user.id]).from_sender_ids(user_ids)
      sent_messages = chat_scope.from_sender_ids([current_user.id]).to_reciever_ids(user_ids)
      messages = recieved_messages + sent_messages
    elsif exclude_user_ids.present?
      recieved_messages = chat_scope.to_reciever_ids([current_user.id]).exclude_sender_ids(exclude_user_ids)
      sent_messages = chat_scope.from_sender_ids([current_user.id]).exclude_reciever_ids(exclude_user_ids)
      messages = recieved_messages + sent_messages
    else
      recieved_messages = chat_scope.to_reciever_ids([current_user.id])
      sent_messages = chat_scope.from_sender_ids([current_user.id])
      messages = recieved_messages + sent_messages
    end

    updates_hash[:time] = Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")
    updates_hash[:counts] = {
      :sent_messages => sent_messages.count,
      :recieved_messages => recieved_messages.count,
      :total => messages.count
    }

    respond_to do |format|
      format.json {render :json => updates_hash.to_json}
    end
  end

  def get_online_friends
    updates_hash = {}
    online_friends = current_user.friends.find_all{|f| f.online_status != "offline"}
    updates_hash[:users] = online_friends.collect(&:json_data)
    updates_hash[:time] = Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")

    respond_to do |format|
      format.json {render :json => updates_hash.to_json}
    end
  end

  # To set offline and online status
  def go_offline
    current_user.is_online = false
    current_user.save(false)

    channels = current_user.friends.collect{|u| "user-#{u.id}"}
    iphone_channels = current_user.friends.collect{|u| "iphone-user-#{u.id}"}

    begin
      Juggernaut.send_to_channels_without_sign(current_user.json_data.to_json, iphone_channels)
      render :juggernaut => {:type => :send_to_channels, :channels => channels} do |page|
        page.call("Users.find(#{current_user.id}).update(#{current_user.json_data.to_json}).updateStatus")
      end
    rescue
    end

    render :json => {:success => true, :time => Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")}
  end

  def go_online
    current_user.is_online = true
    current_user.save(false)

    channels = current_user.friends.collect{|u| "user-#{u.id}"}
    iphone_channels = current_user.friends.collect{|u| "iphone-user-#{u.id}"}

    begin
      Juggernaut.send_to_channels_without_sign(current_user.json_data.to_json, iphone_channels)
      render :juggernaut => {:type => :send_to_channels, :channels => channels} do |page|
        page.call("Users.find(#{current_user.id}).update(#{current_user.json_data.to_json}).updateStatus")
      end
    rescue
    end

    render :json => {:success => true, :time => Time.zone.now.strftime("%d-%m-%Y %H:%M:%S")}
  end
end