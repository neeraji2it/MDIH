class FeedbacksController < ApplicationController
  layout false
  
  def new
    @feedback = Feedback.new(:email => current_user.email)
  end
  
  def create
    
    @feedback = Feedback.new(params[:feedback])
    if @feedback.save
      FeedbackMailer.feedback(@feedback).deliver
      render :status => :created, :text => "<h3>#{I18n.t("feedback.thankyou")}</h3>"
    else
      @error_message = "#{I18n.t("feedback.error_message")} #{@feedback.subject.to_s.downcase}"
	  
	  # Returns the whole form back. This is not the most effective
      # use of AJAX as we could return the error message in JSON, but
      # it makes easier the customization of the form with error messages
      # without worrying about the javascript.
      render :action => 'new', :status => :unprocessable_entity
    end
    
    
  end
  
end
