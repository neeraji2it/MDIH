class QuickMessagesController < ApplicationController

  before_filter :get_user

  # GET /quick_messages
  # GET /quick_messages.xml
  def index
    @quick_message = Message.new
    render :action => "new"
  end
  #  def index
  #    @user = User.find(params[:user_id])
  #    @quick_messages =  if current_user.id == @user.id
  #      current_user.quick_messages.paginate(:per_page => 10, :page => params[:page])
  #    else
  #      QuickMessage.find(:all, :conditions => ["from_id = ? AND to_id = ?", current_user.id, params[:user_id]], :order => "sent_on DESC").paginate(:per_page => 10, :page => params[:page])
  #    end
  #    respond_to do |format|
  #      format.html # index.html.erb
  #      format.xml  { render :xml => @quick_messages }
  #    end
  #  end

  # GET /quick_messages/new
  # GET /quick_messages/new.xml
  def new
    @message_templates = current_user.message_templates.paginate(:page => params[:template_page], :per_page => 10)
    @quick_message = Message.new
    if request.xhr?
      respond_to do |format|
        if params[:page].nil?
          format.html {render :partial => "ajax_new", :layout => false}
        else
          format.html {render :partial => "templates", :layout => false}
          format.js
        end
      end
    else
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @quick_message }
        format.js
      end
    end
  end

  # POST /quick_messages
  # POST /quick_messages.xml
  #  def create
  #    flash_message = ""
  #    @quick_message = QuickMessage.new(params[:quick_message].merge({:from_id => current_user.id, :to_id => params[:user_id], :sent_on => Time.now}))
  #    if @quick_message.save
  #      flash_message = 'QuickMessage was successfully sent.'
  #    end
  #    if request.xhr?
  #      render :update do |page|
  #        if !flash_message.blank?
  #          page.replace_html "quick_message_status_"+params[:user_id], "<span style='color:green'>"+ flash_message+"</span>"
  #          page.hide "overlay"
  #          page.replace_html "popup_body", ""
  #          page.hide "popup_box"
  #        else
  #          page.replace_html "popup_body", (render :partial => "ajax_new", :layout => false)
  #        end
  #      end
  ##      render :action => "new", :layout => false
  #    else
  #      respond_to do |format|
  #        if @quick_message.save
  #
  #          format.html { redirect_to user_path(params[:user_id]) }
  #          format.xml  { render :xml => @quick_message, :status => :created, :location => @quick_message }
  #        else
  #          format.html { render :action => "new" }
  #          format.xml  { render :xml => @quick_message.errors, :status => :unprocessable_entity }
  #        end
  #      end
  #    end
  #  end

  def create
    @message_templates = current_user.message_templates.paginate(:page => params[:template_page], :per_page => 10)
    @flash_message = ""
    @saved = false
    if !(current_user.all_blocked_user_ids.include?(@user.id))
      @quick_message = Message.new(params[:quick_mesage].merge({:user_id => current_user.id, :user_status => "sent", :message_type => 'sent', :receiver_id => @user.id, :receiver_status => "unread"}))
      #      user_id = @user.id if @user
      #      @quick_message.to_address(current_user, "#{user_id}")
      #    @quick_message = QuickMessage.new(params[:quick_message].merge({:from_id => current_user.id, :to_id => params[:user_id], :sent_on => Time.now}))
      if @quick_message.save
        UserMailer.message_notification(current_user, @user, @quick_message).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'messages', :status => false)
        @saved = true
        @flash_message = ("<div style='color:green;'>#{I18n.t("quick_message.create.message_sent")}</div>").html_safe
      else
        @flash_message = ("<div style='color:red;'>#{I18n.t("quick_message.create.error")} </div>").html_safe
      end
    else
      @quick_message = Message.new
      @flash_message = ("<div style='color:red;'>#{I18n.t("quick_message.create.no_permission_to_send")}</div>").html_safe
    end

    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        if @saved
          flash[:notice] = @flash_message
          format.html { redirect_to my_gifts_path(params[:user_id], "received") }
          format.xml  { render :xml => @quick_message, :status => :created, :location => @quick_message }
        else
          flash[:error] = @flash_message
          format.html { redirect_to my_gifts_path(params[:user_id], "received") }
          format.xml  { render :xml => @quick_message.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /quick_messages/1
  # DELETE /quick_messages/1.xml
  #  def destroy
  #    if (@quick_message = QuickMessage.find(params[:id])) && @quick_message.to_id == current_user.id
  #      @quick_message.destroy
  #      flash[:notice] = "Quick message was deleted successfully."
  #    else
  #      flash[:error] = "Permission denied."
  #    end
  #    respond_to do |format|
  #      format.html { redirect_to(user_quick_messages_path(current_user)) }
  #      format.xml  { head :ok }
  #    end
  #  end

  private

  def get_user
    if !(@user = User.find(params[:user_id]))
      flash[:error] = I18n.t("quick_message.get_user.no_user")
      redirect_to "/"
    end
  end
end
