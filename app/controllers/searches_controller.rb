class SearchesController < ApplicationController

  skip_before_filter :is_logged?, :only => [:simple_results]
  
  # Will display simple search
  def index

  end

  # Will search for users by given username or option selected
  def simple_results
    @saved_search = SavedSearch.new
    #    puts request.fullpath
    get_simple_search_results(true, params)
    #    @users = @users - [current_user]
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      render :action => "index"
    end
  end

  def keyword_search_results
    @saved_search = SavedSearch.new
    #    puts request.fullpath
    get_simple_search_results(true, params)
    #    @users = @users - [current_user]
    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
  end

  def new
    @saved_search = SavedSearch.new
    render :partial => 'new', :layout => false
  end
  
  def create
    @saved_search = current_user.saved_searches.build(params[:saved_search])
    respond_to do |format|
      format.js
    end
  end

  def advance
    render :action => "index"
  end

  def advance_results
    get_advance_search_results(true, params)
    #    @users = User.paginate :page => params[:page], :per_page => 3
    #    render :action => "advance_results"
  end

  def block_user
    if !BlockedUser.exists?(:user_id => current_user.id, :blocked_user_id => params[:id])
      @blocked_user = BlockedUser.new(:user_id => current_user.id, :blocked_user_id => params[:id])
      if @blocked_user.save
        render :update do |page|
          #        page.replace_html "user_"+params[:id], ""
          page.reload
        end
      else
        render :update do |page|
          page.replace_html "blocked_error_"+params[:id],I18n.t('user.please_try')
        end
      end
    else
      flash[:error] =  I18n.t('search.block_user.error')
      render :update do |page|
        page.reload
      end
    end
  end

  def blocked_users
    @users = current_user.blocked_users.paginate(:per_page => 10, :page => params[:page])
  end

  def unblock_user
    @blocked_user = BlockedUser.find(:first, :conditions =>["user_id = ? AND blocked_user_id = ?", current_user.id, params[:id]])
    if @blocked_user and @blocked_user.destroy
      #      render :update do |page|
      #        page.replace_html "user_"+params[:id], ""
      #      end
      flash[:notice] = I18n.t('search.unblock_user.notice')
    else
      #      render :update do |page|
      #        page.replace_html "blocked_error_"+params[:id], "Error. Please try again"
      #      end
      flash[:error] = @blocked_user ? I18n.t('user.please_try') : I18n.t('user.general_error')
    end
    if request.xhr?
      render :update do |page|
        page.redirect_to blocked_users_searches_path
      end
    else
      redirect_to blocked_users_searches_path
    end
    
  end

  def near_by
    if (current_user and current_user.user_location and !current_user.user_location.lat.to_s.blank? and !current_user.user_location.lat.to_s.blank?)
      @user_ids = UserLocation.get_nearby_locations(current_user.user_location.lat, current_user.user_location.lng).map{|location| location.user_id}.uniq
      @users = if !@user_ids.empty?
        User.find(:all, :conditions => ["users.id IN (#{@user_ids.join(',')}) and users.id != #{current_user.id}"], :include => [:profile], :order => "profiles.avatar_updated_at DESC, last_accessed_at DESC")
      else
        []
      end
    else
      @users = []
    end
    render :partial => "near_by", :layout => false if request.xhr?
  end

  #private

  #  def basic_search_conditions
  #    i_am_a = params[:i_am_a] || 'Male'
  #    looking_for = params[:looking_for] || 'Female'
  #    role_id = Role.find_by_name('user').id
  #    cond = ["role_id = #{role_id}"]
  #    if i_am_a == 'Male'
  #      cond << if looking_for == 'Male'
  #        "(gender = 'Male' AND (orientation = 'Gay' OR orientation = 'Bisexual'))"
  #      elsif looking_for == 'Bisexual'
  #        "((gender = 'Male' AND orientation = 'Gay') OR (gender = 'Female' AND orientation = 'Straight') OR ((gender = 'Male' OR gender = 'Female') AND orientation = 'Bisexual'))"
  #      elsif looking_for == 'Transgender'
  #        "((gender = 'Male' OR gender = 'Female') AND orientation = 'Transgender')"
  #      else
  #        "(gender = 'Female' AND orientation = 'Straight')"
  #      end
  #    elsif i_am_a == 'Female'
  #      cond << if looking_for == 'Female'
  #        "(gender = 'Female' AND orientation = 'Lesbian')"
  #      elsif looking_for == 'Bisexual'
  #        "((gender = 'Female' AND orientation = 'Lesbian') OR (gender = 'Male' AND orientation = 'Straight') OR ((gender = 'Male' OR gender = 'Female') AND orientation = 'Bisexual'))"
  #      elsif looking_for == 'Transgender'
  #        "((gender = 'Male' OR gender = 'Female') AND orientation = 'Transgender')"
  #      else
  #        "(gender = 'Male' AND orientation = 'Straight')"
  #      end
  #    end
  #    !params[:age_from].to_s.blank? ? cond << "date_of_birth  <= '#{Date.today - (364 * params[:age_from].to_i)}'" : ""
  #    !params[:age_to].to_s.blank? ? cond <<  "date_of_birth  >= '#{Date.today - (364 * params[:age_to].to_i)}'" : ""
  #    if params[:distanse] != '' and params[:zip_code] != 'Unlimited' and params[:zip_code] != '' and params[:zip_code] != 'Zip/postal code'
  #      zip_codes = ZipCode.get_zip_codes(params[:distance], params[:zip_code])
  #      cond << "zip IN (#{zip_codes.join(', ')})" if !zip_codes.empty?
  #    end
  #    if current_user
  #      cond << "(0 = (select count(id) from blocked_users where user_id = #{current_user.id} and blocked_user_id = users.id) AND 0=(select count(id) from blocked_users where user_id = users.id and blocked_user_id = #{current_user.id}))"
  #    end
  #    if params[:online_only]
  #      cond << "is_online = true"
  #    end
  #    if params[:new_members]
  #      from = (Date.today-14).to_time.strftime('%Y-%m-%d 00:00:00')
  #      to = Date.today.to_time.strftime('%Y-%m-%d 00:00:00')
  #      cond << "(activated_at >= '#{from}' AND activated_at <= '#{to}')"
  #    end
  #    return cond
  #  end
end
