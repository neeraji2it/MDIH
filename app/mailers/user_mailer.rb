class UserMailer < ActionMailer::Base
  default :from => "donotreply@mail.mydateishere.com"
  
  def forgot_password(user)
		@user = user
    @site_name = SITE_NAME
    @base_url = BASE_URL
    @url =  BASE_URL+"/reset_password/#{user.password_reset_code}"
		subject = "#{SITE_NAME } : Password Reset"
    mail(:to => user.email, :subject => subject)
  end
  
  def signup_notification(user)
    @user = user
    @site_name = SITE_NAME
    @url = BASE_URL+"/users/activate/#{user.activation_code}"
    @base_url = BASE_URL
    subject = "Your account with #{SITE_NAME} has been created please validate it"
    mail(:to => user.email, :subject => subject)
  end

  def activation_notification(user)
    @user = user
    @site_name = SITE_NAME
    @url = BASE_URL
    subject = "Your account with #{SITE_NAME } has been activated"
    mail(:to => user.email, :subject => subject)
  end

  def message_notification(current_user, user, message)
    @user = user
    @url = BASE_URL
    @current_user = current_user
    @site_name = SITE_NAME
    @message = message
    subject  =  "#{current_user.full_name} sent you a message on #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end

  def message_reply_notification(current_user, user, message, reply)
    @user = user
    @url = BASE_URL
    @current_user = current_user
    @site_name = SITE_NAME
    @reply =  reply
    @message = message
    subject = "#{current_user.full_name} sent reply to your message on #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end

  def friend_request_notification(user, friend)
    @user = user
    @friend = friend
    @url = BASE_URL
    subject   = "#{user.full_name.capitalize} has sent you friend request in #{SITE_NAME }"
    mail(:to => friend.email, :subject => subject)
  end

  def confirm_or_ignore_friend_request_notification(user, friend, status)
    @user = user
    @friend = friend
    @url = BASE_URL
    @status = status
    subject  =  "#{user.full_name.capitalize} has #{status} your friend request in #{SITE_NAME }"
    mail(:to => friend.email, :subject => subject)
  end

  def deactivation_instruction(user)
    @user = user
    @site_name = SITE_NAME
    @base_url = BASE_URL
    @url = BASE_URL+"/users/deactivate/#{user.crypted_email}?email=#{user.email}"
    subject = "Account deactivation instructions in #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end

  def reactivation_instruction(user)
    @user = user
    @site_name = SITE_NAME
    @base_url = BASE_URL
    @url = BASE_URL+"/users/reactivate/#{user.crypted_email}?email=#{user.email}"
    subject = "Account reactivation instructions in #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end

  def hot_vote_notification(user, hoter)
    @user = user
    @site_name = SITE_NAME
    @url = BASE_URL
    @hoter = hoter
    subject = "#{user.full_name} voted you as hot in #{SITE_NAME }"
    mail(:to => hoter.email, :subject => subject)
  end

  def invitation(user, invited_user, message)
    @user = user
    @invited_user = invited_user
    @message = message
    @site_name = SITE_NAME
    @url = BASE_URL
    subject  =  "#{user.full_name.capitalize} has invited you to join in #{SITE_NAME }"
    mail(:to => invited_user.email, :subject => subject)
  end

  def gift_notification(current_user, user, product, sent_gift)
    @user = user
    @current_user = current_user
    @product = product
    @sent_gift = sent_gift
    @site_name = SITE_NAME
    @url = BASE_URL
    subject = "#{current_user.full_name} sent you a virtual gift on #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end

  def credits_changes_notification(user, credits, change_type, message)
    @site_name = SITE_NAME
    @url = BASE_URL
    @user = user
    @credits = credits
    @change_type = change_type
    @message = message
    subject = "Your Account credits has been changed"
    mail(:to => user.email, :subject => subject)
  end

  def birthday_whishes(user)
    @site_name = SITE_NAME
    @url = BASE_URL
    @user = user
    @birthday_credits = BIRTH_DAY_CREDITS
    subject = "Happy Birthday #{user.full_name }"
    mail(:to => user.email, :subject => subject)
  end

  def anniversary_whishes(user)
    @site_name = SITE_NAME
    @url = BASE_URL
    @user = user
    @anniversary_credits = ANNIVERSARY_CREDITS
    subject = "Happy Anniversary #{user.full_name }"
    mail(:to => user.email, :subject => subject)
  end

  def schedule_notification_one(user, dater, date_schedule)
    @site_name = SITE_NAME
    @url = BASE_URL
    @user = user
    @dater = dater
    @date_schedule = date_schedule
    subject = "Date schedule alert from #{SITE_NAME}"
    mail(:to => user.email, :subject => subject)
  end

  def new_user_notification(new_user, user)
    @new_user = new_user
    @user = user
    @url = BASE_URL
    subject   = "#{new_user.full_name.capitalize} has a new user in #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end

  def profile_notification(current_user, profile_user)
    @current_user = current_user
    @profile_user = profile_user
    @site_name = SITE_NAME
    @url = BASE_URL
    subject = "#{current_user.full_name} has seen your profile in #{SITE_NAME }"
    mail(:to =>  profile_user.email, :subject => subject)
  end

  def available_today_notification(current_user, user)
    @current_user = current_user
    @user = user
    @site_name = SITE_NAME
    @url = BASE_URL
    subject = "#{current_user.full_name} has free today in #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end
  
  def send_contact_form(full_name, email, subject, message)
    @site_name = SITE_NAME
    @url = BASE_URL
    @full_name = full_name
    @email = email
    subject = subject
    @message = message
    @admin_email = ADMIN_EMAIL
    mail(:to => ADMIN_EMAIL, :subject => subject)
  end

  def login_remainder(user)
    @user = user
    @site_name = SITE_NAME
    @url = BASE_URL
    subject = "Login remainder from #{SITE_NAME }"
    mail(:to => user.email, :subject => subject)
  end
end

