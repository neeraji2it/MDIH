class MessageTemplatesController < ApplicationController
   before_filter :is_my_template?, :only => [:edit, :update, :destroy, :show]


  def index
    @message_templates = current_user.message_templates.paginate(:per_page => 20, :page => params[:page])
  end

  def new
    @message_template = MessageTemplate.new
    render :action => "template"
  end

  def create
    @message_template = MessageTemplate.new(params[:message_template].merge({:user_id => current_user.id}))
    if @message_template.save
      flash[:notice] = I18n.t('message_template.create.notice')
      if !params[:send_to].blank?
        redirect_to new_user_message_path(current_user, :send_to => params[:send_to], :template_id => @message_template.id)
      else
        redirect_to user_message_templates_path(current_user)
      end
    else
      flash.now[:notice] = I18n.t('message_template.create.notice1')
      render :action => "template"
    end
  end

  def show
    render :action => "template"
  end

  def edit
    render :action => "template"
  end

  def update
    if @message_template.update_attributes(params[:message_template])
      flash[:notice] = I18n.t('message_template.update.notice')
      redirect_to user_message_templates_path(current_user)
    else
      flash.now[:notice] = I18n.t('message_template.update.notice1')
      render :action => "template"
    end
  end

  def select_template
    @message_templates = current_user.message_templates
    render :action => "select_template", :layout => false
  end

  def destroy
    if @message_template.destroy
      flash[:notice] = I18n.t('message_template.destroy.notice')
      redirect_to user_message_templates_path(current_user)
    else
      flash.now[:error] = I18n.t('message_template.destroy.error')
      render :action => "template"
      #      redirect_to edit_user_message_template_path(current_user)
    end
  end

  def destroy_templates
    deleted = false
    not_deleted = false
    params[:messages].to_a.each do |message_id|
      message = MessageTemplate.find_by_id(message_id)
      if message and message.user_id == current_user.id
        if message.destroy
          deleted = true
        else
          not_deleted = true
        end
      else
        not_deleted = true
      end
    end
    if params[:messages].to_a.empty?
      flash[:error] = I18n.t('message_template.destroy_template.error')
    elsif deleted and not_deleted
      flash[:notice] = I18n.t('message_template.destroy_template.notice')
    else
      if deleted
        flash[:notice] = I18n.t('message_template.destroy_template.notice1')
      elsif not_deleted
        flash[:error] = I18n.t('message_template.destroy_template.error1')
      end
    end
    redirect_to user_message_templates_path(current_user)
  end

  private

  def is_my_template?
    @message_template = MessageTemplate.find_by_id(params[:id])
    unless !@message_template.nil? and  @message_template.user_id == current_user.id
      flash[:error] = I18n.t('user.general_error')
      redirect_to "/"
      return
    end
  end
end
