class FeedbackMailer < ActionMailer::Base
  default :from => "donotreply@mail.mydateishere.com"

  def feedback(feedback)
    @sent_on     = Time.now
    @feedback = feedback
    subject    = "[Feedback for #{SITE_NAME}] #{feedback.subject}"
    mail(:to => FEEDBACK_EMAIL, :subject => subject)
  end
  
end
