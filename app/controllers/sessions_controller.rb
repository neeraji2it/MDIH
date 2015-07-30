# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  # Filter skipping the authentication for the following action, except for 'destroy' and 'change_language' actions.
  skip_before_filter :is_logged?, :except => [:destroy]
  skip_before_filter :is_valid_account?, :only => [:destroy]

  # render new.rhtml
  def new
  end

  # Check for user authentication
  def create
  logout_keeping_session!
    #    params[:login] = params[:login].to_s.gsub(/[^0-9A-Za-z-]/, '')
    deleted_user = User.find_deleted_by("login = '#{params[:login]}' AND deleted = true") if !params[:login].to_s.blank?
    if deleted_user.nil?
      user = User.authenticate(params[:login], params[:password], true)
      if user
        user.add_location({:ip_address => request.remote_ip}) #if user.user_location.nil? or user.user_location.lng.to_s.blank? or user.user_location.lat.to_s.blank?
        # Protects against session fixation attacks, causes request forgery
        # protection if user resubmits an earlier form using back
        # button. Uncomment if you understand the tradeoffs.
        # reset_session
        self.current_user = user

        new_cookie_flag = (params[:remember_me] == "1")
        user.is_online = true
        user.logged_in_from = "web"
        user.last_login = Time.now
        user.save(:validate => false)
        handle_remember_cookie! new_cookie_flag
        flash[:notice] = I18n.t('session.create.notice')
        after_login(current_user)
        render :update do |page|
          page.redirect_to  "/"
        end
      else
        @status = true
      end
    else
      @status = false
      respond_to do |format|
        format.js
      end
    end
  end

  # Kill the user session
  def destroy
    user = current_user
    current_user.update_attributes(:last_login_at => Time.now, :is_online => false)
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    after_logout(user)
    redirect_back_or_default('/')
  end

 def change_language
  if SITE_LANGUAGES.include?(params[:language])
      session[:locale] = params[:language]
     render :update do |page|
      page.reload()
     end
  else
      page.alert("#{I18n.t('session.label.invalid_language')}")
  end
 end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "'#{I18n.t('session.note_failed_signin.error')}' '#{params[:login]}'"
  end
end
