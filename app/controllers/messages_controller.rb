class MessagesController < ApplicationController
  layout 'user'
  #  uses_tiny_mce
  # GET /messages
  # GET /messages.xml
  def index
    @message_type = params[:message_type] || "inbox"
    if @message_type == "inbox"
      sql_query = "select * from messages a where  a.user_id in ( select user_id from messages where receiver_id=#{current_user.id}) and id in ( select max(id) from messages b where a.user_id =b.user_id
               and a.receiver_id=b.receiver_id and b.receiver_status != 'deleted' ) and a.receiver_id = #{current_user.id} order by a.created_at desc"
      @messages = Message.paginate_by_sql [sql_query], :per_page => 10, :page => params[:page]
    elsif @message_type == "sent"
      sql_query = "select * from messages a where  a.receiver_id in ( select receiver_id from messages where user_id=#{current_user.id}) and id in ( select max(id) from messages b where a.user_id =b.user_id
               and a.receiver_id=b.receiver_id and b.user_status != 'deleted' ) and a.user_id = #{current_user.id} order by a.created_at desc"
      @messages = Message.paginate_by_sql [sql_query], :per_page => 10, :page => params[:page]
    elsif @message_type == "unread"
      sql_query = "select * from messages a where  a.user_id in ( select user_id from messages where receiver_id=#{current_user.id}) and id in ( select max(id) from messages b where a.user_id =b.user_id
               and a.receiver_id=b.receiver_id and a.receiver_status = 'unread' )  and a.receiver_id = #{current_user.id} order by a.created_at desc"
      @messages = Message.paginate_by_sql [sql_query], :per_page => 5, :page => params[:page]
    end
    respond_to do |format|
      if @message_type == "unread"
        if params[:page].nil?
          format.html {render :partial => "messages", :layout => false if request.xhr?}
          format.xml  { render :xml => @messages }
          format.js {render :partial => "messages", :layout => false if request.xhr?}
        else
          format.html {render :partial => "ajax_messages", :layout => false if request.xhr?}
          format.xml  { render :xml => @messages }
          format.js {render :partial => "ajax_messages", :layout => false if request.xhr?}
        end
      elsif @message_type == "inbox"
        format.html {render :partial => "inbox", :layout => false if request.xhr?}
        format.xml  { render :xml => @messages }
        format.js {render :partial => "inbox", :layout => false if request.xhr?}
      elsif @message_type == "sent"
        format.html {render :partial => "sent", :layout => false if request.xhr?}
        format.xml  { render :xml => @messages }
        format.js {render :partial => "sent", :layout => false if request.xhr?}
      else
        format.html 
        format.xml  { render :xml => @messages }
      end
    end
  end

  def conversation
    @messages_reply = Message.new
    @message_templates = current_user.message_templates.paginate(:page => params[:template_page], :per_page => 10)
    @user = User.find(params[:id])
    @messages = Message.paginate :conditions => ["((messages.user_id = #{current_user.id} and messages.receiver_id = #{params[:id]}) and messages.user_status != 'deleted') or ((messages.receiver_id = #{current_user.id} and messages.user_id = #{params[:id]}) and messages.receiver_status != 'deleted')"], :order => "created_at Desc" , :page => params[:page], :per_page => 20
    for message in @messages
      if message.receiver_id == current_user.id
        message.update_attribute(:receiver_status, "read") if message.receiver_status == "unread"
      end
    end
    if request.xhr?
      respond_to do |format|
        if params[:page].present?
         format.html{ render :partial => "ajax_conversation", :layout => false }
        elsif params[:template_page].present?
         format.html{ render :partial => "/quick_messages/templates", :layout => false}
        else
          format.html {render :partial => "ajax_conversation", :layout => false}
        end
        format.js
      end
    else
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @messages_reply }
      end
    end
  end

  def sent_messages
    @user = User.find(params[:id])
    @messages = Message.paginate :conditions => ["(messages.user_id = #{current_user.id} and messages.receiver_id = #{@user.id}) and messages.user_status != 'deleted'"], :order => "created_at Desc" , :page => params[:page], :per_page => 20
    render :partial => "ajax_sent_messages", :layout => false if request.xhr?
  end


  def make_delete
    params[:messages].to_a.each do |message_id|
      message = Message.find(message_id)
      message.make_deleted(current_user.id)
    end
    flash[:notice] = I18n.t('message.make_delete.notice')
    redirect_to messages_box_path(current_user, params[:message_type])
  end

  def destroy
    message = Message.find(params[:id])
    message.make_deleted(current_user.id)
    #    flash[:notice] = "Message was successfully deleted."
    render :text => true
  end

  def reply
    @user = User.find(params[:id])
    @messages_reply = Message.new(params[:messages_reply].merge({:receiver_id => @user.id, :user_id => current_user.id, :receiver_status => "unread", :user_status => "sent", :message_type => "sent"}))
    if @messages_reply.save
      UserMailer.message_notification(current_user, @user, @messages_reply).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'messages', :status => false)
      flash[:notice] = I18n.t('message.reply.notice')
    else
      flash[:error] = I18n.t('message.reply.error')
    end
    redirect_to conversation_user_message_path(current_user, @user.id)
  end

  def block_user
    if !BlockedUser.exists?(:user_id => current_user.id, :blocked_user_id => params[:id])
      @blocked_user = BlockedUser.new(:user_id => current_user.id, :blocked_user_id => params[:id])
      @user = User.find(params[:id])
      if @blocked_user.save
        render :update do |page|
          page.remove "block_user_"+params[:id]
          page.call 'alert', "#{@user.full_name} #{I18n.t('message.block_user.alert1')}"
        end
      else
        render :update do |page|
          page.page.call 'alert', I18n.t('user.please_try')
        end
      end
    else
      render :update do |page|
        page.page.call 'alert', I18n.t('message.block_user.alert2')
      end
    end
  end
  
  def delete_all_messages
    @messages = Message.where("user_id = '#{params[:id]}' and receiver_id = '#{params[:user_id]}'")
    @messages.each do |message|
      message.make_deleted(current_user.id)
    end
    render :update do |page|
      if current_user.id == params[:user_id]
        page.redirect_to messages_box_path(current_user, 'inbox')
      else
        page.redirect_to messages_box_path(current_user, 'sent')
      end
    end
  end

  def recall
    @message = Message.find(params[:id])
    @recall_message =  Message.new(:user_id => @message.user_id, :message_type => "recalled",:user_status => "sent",:receiver_id => @message.receiver_id, :receiver_status => "unread", :body => @message.body)
    if @recall_message.save
      flash[:notice] = "Successfully Resend the message."
    else
      flash[:notice] = "Failed to Resend the message."
    end
    render :update do |page|
      page.reload
    end
  end
end
