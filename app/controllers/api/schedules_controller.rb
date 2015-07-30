class Api::SchedulesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth
  #  before_filter :has_view_permission, :only => [:show, :replies]

  def index
    from_date = DATE_FORMAT.match(params[:from_date]) ? params[:from_date].to_time : Time.now
    to_date = DATE_FORMAT.match(params[:to_date]) ? " AND date_on < '#{params[:to_date].to_time.strftime('%Y-%m-%d')}'" : ""
    @date_schedules = current_user.requested_date_schedules.all(:conditions =>["(dater_status != 'deleted' and dater_status != 'accepted' #{view_condition}) AND (date_on > '#{from_date.strftime('%Y-%m-%d').to_s}' #{to_date.to_s})"], :include =>[:user]).paginate(:per_page => 10, :page => params[:page]) #and proposed_date_on >= '#{Date.today.strftime("%Y-%m-%d ")+Time.now.strftime("%H:%M")}'
    respond_to do |format|
      format.xml { render :xml => @date_schedules }
      format.json { render :json => @date_schedules }
    end
  end
  
end
