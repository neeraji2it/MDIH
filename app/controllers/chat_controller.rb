class ChatController < ApplicationController
  skip_before_filter :is_valid_account?
  #  before_filter :is_friend?, :only => [:show]

  def initial_data
    updates_hash = {:messages => {}}
    updates_hash[:current_user] = current_user.id
    updates_hash[:messages] = current_user.intails_chats.collect(&:json_data)
    #    updates_hash[:users] = current_user.friends.collect(&:json_data)
    updates_hash[:users] = User.where("(users.id != #{current_user.id} and users.login IS NOT NULL) and users.activated_at IS NOT NULL").collect(&:json_data)
    respond_to do |format|
      format.json {render :json => updates_hash.to_json}
    end
  end

  def index
    #    sql_query = "select * from chats a where (a.reciever_id in (select reciever_id from chats where sender_id=#{current_user.id}) or a.sender_id in (select  sender_id from chats where reciever_id=#{current_user.id})) and (id in (select max(id) from chats b where a.sender_id = b.sender_id and a.reciever_id = b.reciever_id)) and (a.sender_id = #{current_user.id} or a.reciever_id = #{current_user.id}) and a.read_at IS NOT NULL order by a.created_at desc"
    sql_query = "select * from chats a where (a.sender_id in (select  sender_id from chats where reciever_id=#{current_user.id})) and (id in (select max(id) from chats b where a.sender_id = b.sender_id and a.reciever_id = b.reciever_id)) and  a.reciever_id = #{current_user.id} and a.read_at IS NOT NULL order by a.created_at desc"
    @messages = Chat.paginate_by_sql [sql_query], :per_page => 10, :page => params[:page]
    render :partial => "ajax_chat", :layout => false if request.xhr?
  end

  def new_chats
    sql_query = "select * from chats a where (a.sender_id in (select  sender_id from chats where reciever_id=#{current_user.id})) and (id in (select max(id) from chats b where a.sender_id = b.sender_id and a.reciever_id = b.reciever_id)) and a.reciever_id=#{current_user.id} and a.read_at IS NULL order by a.created_at desc"
    @messages = Chat.paginate_by_sql [sql_query], :per_page => 5, :page => params[:page]
    if params[:page].nil?
      render :partial => "new_chats", :layout => false if request.xhr?
    else
      render :partial => "ajax_new_chats", :layout => false if request.xhr?
    end
  end

  def show
    @messages = if params[:sort].to_s.blank? or params[:sort] == "all"
      Chat.paginate :conditions => ["(chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]}))"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    elsif params[:sort] == "yesterday"
      yesterday = Time.now - 1.day
      Chat.paginate :conditions => ["((chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]})) AND chats.read_at IS NOT NULL) AND (created_at >= '#{yesterday.beginning_of_day}' AND created_at <= '#{yesterday.end_of_day}')"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    elsif params[:sort] == "7days"
      Chat.paginate :conditions => ["((chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]})) AND chats.read_at IS NOT NULL) AND (created_at > '#{7.days.ago}')"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    elsif params[:sort] == "1month"
      Chat.paginate :conditions => ["((chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]})) AND chats.read_at IS NOT NULL) AND (created_at > '#{1.month.ago}')"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    elsif params[:sort] == "3months"
      Chat.paginate :conditions => ["((chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]})) AND chats.read_at IS NOT NULL) AND (created_at > '#{3.months.ago}')"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    elsif params[:sort] == "6months"
      Chat.paginate :conditions => ["((chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]})) AND chats.read_at IS NOT NULL) AND (created_at > '#{6.months.ago}')"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    elsif params[:sort] == "1year"
      Chat.paginate :conditions => ["((chats.reciever_id IN (#{current_user.id},#{params[:id]}) AND chats.sender_id IN (#{current_user.id},#{params[:id]})) AND chats.read_at IS NOT NULL) AND (created_at > '#{1.year.ago}')"], :order => "chats.created_at Desc" , :page => params[:page], :per_page => 20
    end
    for message in @messages
      if message.reciever_id == current_user.id
        message.update_attribute(:read_at, Time.now) if message.is_unread?
      end
    end
    #@messages = current_user.chats.collect(&:json_data).reverse!
    @reciever= User.find(params[:id])
    render :partial => "ajax_show", :layout => false if request.xhr?
  end
   
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
      @sent_message = messages.first
      for message in messages
        hash = {:text => message.text, :sender_name => message.sender.name, :sender_id => message.sender.id, :reciever_name => message.reciever.name, :reciever_id => message.reciever.id, :sender_age => message.sender.try(:age), :receiver_age => message.reciever.try(:age), :sender_photo => (message.sender.facebook_id.present? ? (message.sender.profile ? (message.sender.profile.avatar_file_name != "picture_type_large.jpg" ? message.sender.profile.avatar.url(:original) : message.sender.fb_big_image) : message.sender.fb_big_image) : (message.sender.profile ? message.sender.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")), :reciever_photo => (message.reciever.facebook_id.present? ? (message.reciever.profile ? (message.reciever.profile.avatar_file_name != "picture_type_large.jpg" ? message.reciever.profile.avatar.url(:original) : message.reciever.fb_big_image) : message.reciever.fb_big_image) : (message.reciever.profile ? message.reciever.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")), :sender_gender => message.sender.gender, :reciever_gender => message.reciever.gender, :sender_status => message.sender.online_status, :reciever_status => message.reciever.online_status}
        Juggernaut.publish("users:#{message.reciever.id}:#{current_user.id}", hash.to_json)
      end
    end
    
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @mess = Chat.find(params[:id])
    @mess.destroy
    render :text => true
  end

  def new_window
    @user = User.find(params[:id])
    if session[:chating_users].keys.include?(params[:id])
      session[:chating_users].delete(params[:id])
    end
    render :layout => false
  end

  def open_chat_window
    user = User.find(params[:id])
    session[:chating_users] ||= {}
    if !session[:chating_users].keys.include?(params[:id])
      session[:chating_users][params[:id]] = user.json_data
    end
    render :nothing => true
  end

  def close_chat_window
    session[:chating_users] ||= {}
    if session[:chating_users].keys.include?(params[:id])
      session[:chating_users].delete(params[:id])
    end
    render :nothing => true
  end

  #  private
  #  def is_friend?
  #    if !current_user.friends.map(&:id).include?(params[:id].to_i)
  #      redirect_to "/chat", :alert => "You are not his friend"
  #    end
  #  end
  
end
