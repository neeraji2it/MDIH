class Admin::UsersController < ApplicationController

  # Filter to authenticate for a admin to access the actions
  before_filter :is_admin?
  layout 'admin'

  def index
    conditions = []
    conditions << (!DATE_FORMAT.match(params[:from_date]).nil? ? "created_at >= '#{params[:from_date].to_time.strftime("%Y-%m-%d 00:00:00")}'": nil)
    conditions << (!DATE_FORMAT.match(params[:to_date]).nil? ? "created_at <= '#{params[:to_date].to_time.strftime("%Y-%m-%d 00:00:00")}'" : nil)
    @users = User.paginate(:conditions => ["#{conditions.compact.join(' AND ')}"], :per_page => 20, :page => params[:page], :order => "created_at DESC")
    @active_users = User.count(:conditions => ["#{(conditions.to_a+["activated_at IS NULL"]).compact.join(' AND ')}"])
    @inactive_users = User.count(:conditions => ["#{(conditions.to_a+["activated_at IS NOT NULL"]).compact.join(' AND ')}"])
    @registred_from_facebook = User.count(:conditions => ["#{(conditions.to_a+["facebook_id IS NOT NULL"]).compact.join(' AND ')}"])
  end

  def users_search
    @hours_list = %w(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24)
    profile_conditions = []
    user_conditions = []
    if !params[:interval_from].to_s.blank? && !params[:interval_to].to_s.blank? && (params[:interval_to] != "-" || params[:interval_from] != "-" )
      user_conditions << "HOUR(last_login_at) between #{params[:interval_from]} and #{params[:interval_to]}"
    end
    if !params[:online_only].to_s.blank?
      user_conditions << "is_online = true"
    end
    if !params[:all_xx_days].to_s.blank?
      user_conditions << "created_at > date_sub(curdate(), INTERVAL #{params[:all_xx_days]} DAY)"
    end
    if !params[:gender].to_s.blank?
      if params[:gender] == "All"
      else
        user_conditions << "gender = '#{params[:gender]}'"
      end
    end
    if !params[:orientation].to_s.blank? && params[:orientation] != "All"
      user_conditions << "orientation = '#{params[:orientation]}'"
    end
    if !params[:ethnicity].to_s.blank?
      profile_conditions << "ethnicity IN (#{params[:ethnicity].map{|e|"'#{e}'"}.join(',')})"
    end
    if !params[:income_level].to_s.blank?
      profile_conditions << "#{I18n.t("user.income_level")} = '#{params[:income_level]}'"
    end
    !params[:age_from].to_s.blank? ? user_conditions << "date_of_birth  <= '#{Date.today - (364 * params[:age_from].to_i)}'" : ""
    !params[:age_to].to_s.blank? ? user_conditions <<  "date_of_birth  >= '#{Date.today - (364 * params[:age_to].to_i)}'" : ""

    if !profile_conditions.empty?
      @profile_ids = Profile.find(:all, :select => 'id').map{|profile| profile.id}
      @users = [].paginate
      if !@profile_ids.empty?
        profile_conditions << (!@profile_ids.empty? ? ["id IN (#{@profile_ids.join(', ')})"] : [])

        @user_ids = (Profile.find(:all, :conditions =>[profile_conditions.join(" AND ")], :select => ["user_id"]).map{|profile| profile.user_id})
        user_conditions = !@user_ids.empty? ? ["users.id IN (#{@user_ids.join(', ')})"] : []
        @users = if !@user_ids.empty?
          if true #pagination
            User.find(:all, :conditions => [user_conditions.join(" AND ")], :include => [:profile]).paginate(:per_page => 10, :page => params[:page])
          else
            User.find(:all, :conditions => [user_conditions.join(" AND ")], :include => [:profile])
          end
        else
          [].paginate
        end
      end
    else
      @users = User.find(:all, :conditions => [user_conditions.join(" AND ")], :include => [:profile], :order => 'created_at DESC').paginate(:per_page => 10, :page => params[:page])
    end
  end

  def change_status
    @user = User.find(params[:id])
    @user.status = @user.status ? false : true
    @status = @user.save(:validate => false)
  end

  def blocked_users
    @users = User.all_blocked_users.paginate(:per_page => 20, :page => params[:page])
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = I18n.t('user.destroy.notice')
    else
      flash[:error] = I18n.t('user.destroy.error')
    end
    redirect_to admin_users_path
  end

  def users_credits
    @users = User.paginate(:order =>"login DESC", :per_page => 20, :page => params[:page])
  end

  def change_credits
    @user = User.find(params[:id])
    if request.get?
      params[:send_email] = 'yes'
      render :partial => "change_credits", :layout => false
    else
      @status = params[:credits].to_i != 0 && @user.update_attribute(:credits, (params[:credit_type] == 'decrease' ? (@user.credits - params[:credits].to_i) : (@user.credits + params[:credits].to_i)))
    end
  end

  def resend_activation_email
    user = User.find(:first, :conditions => ["activated_at IS NULL AND id = ?", params[:id]])
    render :update do |page|
      if user and UserMailer.signup_notification(user).deliver
        page.alert("#{I18n.t('user.label.resent_activation_mail')} #{user.display_name}")
      else
        page.alert("#{I18n.t('user.label.user_already_active')}")
      end
    end
  end
end
