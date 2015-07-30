# This controller handles the login/logout function of the site.
class Api::SessionsController < ApplicationController

  # Filter skipping the authentication for the following action, except for 'destroy' and 'change_language' actions.
  skip_before_filter :is_logged?, :except => [:destroy]
  skip_before_filter :is_valid_account?, :only => [:destroy]

  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth


  # Check for user authentication
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password], true)
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      user.add_location({:lat => params[:lat], :lng => params[:lng]}) if !params[:lat].to_s.blank? and !params[:lng].to_s.blank?
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      user.is_online = true
      user.logged_in_from = (params[:logged_in_from] ? params[:logged_in_from] : "iphone")
      user.last_login = Time.now
      user.save(:validate => false)
      handle_remember_cookie! new_cookie_flag
      #      redirect_back_or_default('/')
      #      flash[:notice] = "Logged in successfully"
      session[:user_id] = user.id
      after_login(user)
#      message = "Requested user is authorized"
      respond_to do |format|
#        format.xml { render :xml => {:message => message} }
#        format.json { render :json => {:message => message} }
        format.xml { render :xml => user }
        format.json { render :json => user }
      end
    else
      error = I18n.t('session.not_authorized')
      respond_to do |format|
        format.xml { render :xml => {:error => error} }
        format.json { render :json => {:error => error} }
      end
    end
  end

  # Kill the user session
  def destroy
    user = current_user

    current_user.update_attributes(:last_login_at => Time.now, :is_online => false, :logged_in_from => nil)
    logout_killing_session!
    self.current_user = nil
    #    flash[:notice] = "You have been logged out."

    after_logout(user)

    respond_to do |format|
      format.xml   { head :ok }
      format.json  { head :ok }
    end
  end

end
