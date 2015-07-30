module UsersHelper

  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %>
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to user's page ('users/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of user.login', escaped with
  #   the standard h() function.
  # * :content_method => :user_instance_method_to_call_for_content_text
  # * :title_method => :user_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_user @user
  #   # => <a href="/users/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_user user, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, user.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/users/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_user @user, :content_text => 'Your user page'
  #   # => <a href="/users/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_user(user, options={})
    raise I18n.t('helper.invalid_user') unless user
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= user.send(options.delete(:content_method))
    options[:title] ||= user.send(options.delete(:title_method))
    link_to h(content_text), user_path(user), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_user) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={})
    if current_user
      link_to_user current_user, options
    else
      content_text = options.delete(:content_text) || I18n.t('helper.content_text')
      # kill ignored options from link_to_user
      [:content_method, :title_method].each{|opt| options.delete(opt)}
      link_to_login_with_IP content_text, options
    end
  end

  def can_display_profile_personal_info?(profile)
    if !profile.height.to_s.blank?  or !profile.ethnicity.to_s.blank?  or !profile.body_type.to_s.blank?  or !profile.languages_spoken.to_s.blank? or !profile.marital_status.to_s.blank? or
        !profile.want_children.to_s.blank? or !profile.religion.to_s.blank? or !profile.smoke.to_s.blank? or !profile.drink.to_s.blank? or !profile.drugs.to_s.blank? or !profile.pets.to_s.blank? #or !profile.chinese_zodiac_sign.to_s.blank?
        return true
    end
    return false
  end

  def can_display_profile_professional_info?(profile)
    if !profile.education_level.to_s.blank? or !profile.profession.to_s.blank? or !profile.income_level.to_s.blank?
      return true
    end
    return false
  end
  
  def can_display_profile_quations_info?(profile)
    if !profile.who_am_i.to_s.blank? or !profile.what_is_my_passion.to_s.blank? or !profile.important_things.to_s.blank? or
        !profile.funny_story_when_we_meet.to_s.blank? or !profile.my_pet_peeves_are.to_s.blank? or !profile.i_am_really_good_at.to_s.blank? or
        !profile.favorite_books_music_movies.to_s.blank? or !profile.embarrassing_thing.to_s.blank? or !profile.anything_i_want.to_s.blank? or
        !profile.things_i_would_never_do.to_s.blank? or !profile.my_friends_tell_me_that_i_am.to_s.blank? or !profile.private_about_me.to_s.blank? or
        !profile.my_bucket_list.to_s.blank? or !profile.on_a_normal_weekend_i.to_s.blank? or !profile.most_interesting_place.to_s.blank? or
        !profile.weirdest_thing_that_i_know.to_s.blank? or !profile.i_fear_the_most.to_s.blank? or !profile.my_best_feature_is.to_s.blank?
      return true
    end
    return false
  end

end
