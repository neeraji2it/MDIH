class Api::MessageTemplatesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth
  before_filter :is_my_template?, :only => [:update, :destroy, :send_to_friends]
  
  def index
    @message_templates = current_user.message_templates
    respond_to do |format|
      format.xml { render :xml => @message_templates }
      format.json { render :json => @message_templates }
    end
  end

  def create
    params[:message_template] = {} if !params[:message_template]
    @message_template = MessageTemplate.new(params[:message_template].merge({:user_id => current_user.id}))
    if @message_template.save
      response_message = {:message => I18n.t('message_template.create.notice')}
    else
      response_message = @message_template.errors
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  def update
    params[:message_template] = {:subject => "", :body => ""} if !params[:message_template]
    if @message_template.update_attributes(params[:message_template])
      response_message = {:message => I18n.t('message_template.update.notice')}
    else
      response_message = @message_template.errors
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  def destroy
    if @message_template.destroy
      response_message = {:message => I18n.t('message_template.destroy.notice')}
    else
      response_message = {:message => I18n.t('message_template.destroy.error')}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end

  def send_to_friends
    params[:message] = {:subject => @message_template.subject, :body => @message_template.body}
    send_api_message_to_friends(params)
  end

  private

  def is_my_template?
    @message_template = MessageTemplate.find_by_id(params[:id])
    unless !@message_template.nil? and  @message_template.user_id == current_user.id
      response_message = {:error => I18n.t('user.general_error')}
      respond_to do |format|
        format.xml { render :xml => response_message }
        format.json { render :json => response_message }
      end
      return
    end
  end
end
