class Admin::FeedbacksController < ApplicationController

  before_filter :is_admin?
  layout 'admin'

  def index
    @feedbacks = Feedback.paginate(:order => "created_at DESC", :page => params[:page], :per_page => 20)
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    if @feedback.destroy
      flash[:notice] = I18n.t('feedback.destroy.notice_feedback_delete')
    else
      flash[:error] = I18n.t('feedback.destroy.error_feedback_delete')
    end
    redirect_to admin_feedbacks_path
  end
  
end
