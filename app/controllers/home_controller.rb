class HomeController < ApplicationController

  # Filter skipping the authentication for the following action.
  skip_before_filter :is_logged?, :only => [:index, :error, :about_us, :contact_us, :privacy, :terms_of_use]
  skip_before_filter :is_valid_account?, :only => [:index, :error, :about_us, :contact_us, :privacy, :terms_of_use]
   layout :get_layout
  include Authentication
  # This is for both logged-in users home page and site general home page. If user logged in then it will show his home page or site general home page
  def index
    if params[:auth_token] and params[:next]
      redirect_to facebook_path
      return
    end
    if current_user.nil?
      if params[:fb_sig_app_id]
        render :template => "facebook/home", :layout => false
      else
        render :action => "general_home"
      end

    else
      #      @quick_messages = current_user.quick_messages.all(:limit => 5)
      @profile_viewers = current_user.profile_viewed_by.all(:select => "users.*, profile_viewers.viewed_at")
      @profile_visitors = current_user.profile_viewed.all(:select => "users.*, profile_viewers.viewed_at")
      @available_users = User.where("users.id != #{current_user.id} and users.available_today = true")
      @notifications = User.recent_notifications(current_user).paginate(:per_page => 5, :page => params[:page])
      render :partial => "ajax_recent_notifications", :layout => false if request.xhr?
    end
  end

  def contact_us
    unless request.get?
      params[:full_name_error] = I18n.t('home.contact_us.fullname_error') if params[:full_name].to_s.blank?
      email_error = params[:email].to_s.blank? ? [I18n.t('home.contact_us.email_error')] : []
      email_error << (!Authentication.email_regex.match(params[:email]) ? I18n.t('home.contact_us.email_error1') : nil)
      params[:email_error] = email_error.to_a.compact.join(' and ') if !email_error.empty?
      params[:subject_error] = I18n.t('home.contact_us.subject_error') if params[:subject].to_s.blank?
      params[:message_error] = I18n.t('home.contact_us.message_error') if params[:message].to_s.blank?
      if !params[:full_name].to_s.blank? and !email_error.empty? and !params[:subject].to_s.blank? and !params[:message].to_s.blank?
        if UserMailer.send_contact_form(params[:full_name], params[:email], params[:subject], params[:message]).deliver
          flash[:notice] = I18n.t('home.contact_us.notice')
          params[:full_name] = params[:email] = params[:subject] = params[:message] = ""
        else
          flash[:error] = I18n.t('home.contact_us.error')
        end
      end
    end
  end

  def all_notifications
    render :action => "index"
  end

  def start_search
    result = %x[rake ts:rebuild RAILS_ENV=#{RAILS_ENV}]
    logger.info ">>>>>>>>>>>>>>>>>>>>>>>"
    logger.info result
    render :update do |page|
      if result.to_s.include?("Started successfully")
        page.alert(I18n.t('home.start_search.alert1'))
      else
        page.alert(I18n.t('home.start_search.alert2'))
      end
    end
  end

end
