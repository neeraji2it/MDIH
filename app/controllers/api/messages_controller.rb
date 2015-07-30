class Api::MessagesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth
  #  before_filter :has_view_permission, :only => [:show, :replies, :reply, :destroy]

  # curl -u username:password http://localhost.com/api/messages.json -X POST -d 'send_to=34' -d 'body=Api call'
  def create
    @user = User.find(params[:send_to]) if params[:send_to].present?
    @message = Message.new(({:body => params[:body] ,:user_id => current_user.id, :user_status => "sent", :message_type => 'sent', :receiver_id => @user.id, :receiver_status => "unread"}))
    if @message.save
      UserMailer.message_notification(current_user, @user, @message).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'messages', :status => false)
      response_message = {:message => "Message was successfully sent."}
    else
      response_message = !@message.errors.empty? ? @message.errors : {:errors => "Message sending faild. Please try again."}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # curl -u username:password http://localhost.com/api/messages/display/inbox.json
  # curl -u username:password http://localhost.com/api/messages/display/sent.json
  def index
    @message_type = params[:message_type] || "inbox"
    if @message_type == "inbox"
      sql_query = "select * from messages a where  a.user_id in ( select user_id from messages where receiver_id=#{current_user.id}) and id in ( select max(id) from messages b where a.user_id =b.user_id
               and a.receiver_id=b.receiver_id and b.receiver_status != 'deleted' ) and a.receiver_id = #{current_user.id} order by a.created_at desc"
      @messages = Message.find_by_sql [sql_query]
    elsif @message_type == "sent"
      sql_query = "select * from messages a where  a.receiver_id in ( select receiver_id from messages where user_id=#{current_user.id}) and id in ( select max(id) from messages b where a.user_id =b.user_id
               and a.receiver_id=b.receiver_id and b.user_status != 'deleted' ) and a.user_id = #{current_user.id} order by a.created_at desc"
      @messages =  Message.find_by_sql [sql_query]
    end
    respond_to do |format|
      format.xml { render :xml => @messages }
      format.json { render :json => @messages }
    end
  end

  # curl -u username:password http://localhost.com/api/messages/34/reply.json -X POST -d 'body=reply Api call'
  def reply
    @user = User.find(params[:id])
    @messages_reply = Message.new(:body => params[:body], :user_id => current_user.id, :user_status => "sent", :message_type => 'sent', :receiver_id => @user.id, :receiver_status => "unread")
    if @messages_reply.save
      UserMailer.message_notification(current_user, @user, @messages_reply).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'messages', :status => false)
      response_message = {:message => 'Message was successfully sent.'}
    else
      response_message = !@messages_reply.errors.empty? ? @messages_reply.errors : {:errors => 'Sending message failed.'}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  # curl -u username:password http://localhost.com/api/messages/34/conversation.json -X GET
  def conversation
    @user = User.find(params[:id])
    @messages = Message.find(:all, :conditions => ["((messages.user_id = #{current_user.id} and messages.receiver_id = #{params[:id]}) and messages.user_status != 'deleted') or ((messages.receiver_id = #{current_user.id} and messages.user_id = #{params[:id]}) and messages.receiver_status != 'deleted')"], :order => "created_at Desc")
    for message in @messages
      if message.receiver_id == current_user.id
        message.update_attribute(:receiver_status, "read") if message.receiver_status == "unread"
      end
    end
    respond_to do |format|
      format.xml { render :xml => @messages }
      format.json { render :json => @messages }
    end
  end

  # curl -u username:password http://localhost.com/api/messages/34/sent_messages.json -X GET
  def sent_messages
    @user = User.find(params[:id])
    @messages = Message.find(:all, :conditions => ["(messages.user_id = #{current_user.id} and messages.receiver_id = #{@user.id}) and messages.user_status != 'deleted'"], :order => "created_at Desc")
    respond_to do |format|
      format.xml { render :xml => @messages }
      format.json { render :json => @messages }
    end
  end

  # curl -u username:password http://localhost.com/api/messages/100.json -X DELETE
  def destroy
    @message = Message.find(params[:id])
    @message.make_deleted(current_user.id)
    response_message = {:message => 'Message deleted successfully.'}
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

end
