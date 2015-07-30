class FacebookerPublisher < Facebooker::Rails::Publisher
  helper :application
  
  def notification(to,from,message)
    send_as :notification
    self.recipients(to)
    self.from(from)
    fbml message
  end

  def publish_action_template
    one_line_story_template "{*actor*} {*message*}"
  end

  def publish_action(user,message)
    send_as :user_action
    from user
    data :message=>message
  end

end