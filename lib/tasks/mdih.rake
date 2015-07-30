namespace :mdih do

  desc "Install My date is here Application"
	task :install => :environment do
    #    p "Installing required gems"
    #    Rake::Task['gems:install'].invoke
    puts "Creating Database"
		Rake::Task['db:create'].invoke
    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    Rake::Task['mdih:roles'].invoke
    Rake::Task['mdih:create_admin_users'].invoke
    p "Installed  My date is here Application Sucessfully."

	end

	desc "creating My date is here admin user"
	task :create_admin_users => :environment do
    if !User.exists?(:login => 'boss')
      puts "adding boss user with login as 'boss' and password as 'bangalore'"
      if @role = Role.first
        @user = User.new(:login => "boss", :email => "boss@mdih.com", :first_name =>"Mdih", :last_name => "Boss", :password => "bangalore", :password_confirmation => "bangalore", :role_id => @role.id, :status => true, :orientation => "Straight", :gender => "Male", :date_of_birth => "1981-03-13", :zip => 2222222)
        @user.save
      else
        Rake::Task['mdih:roles'].invoke
        Rake::Task['mdih:create_admin_users'].invoke
      end
    end
	end

  desc "creating sample data"
	task :roles => :environment do
    Role.create(:name => "admin", :description => "Administrators of the project") if !Role.exists?(:name => "admin")
    Role.create(:name => "user", :description => "Subscribers of the project") if !Role.exists?(:name => "user")
  end

  desc "Send email notification of date schedule before 24 hours"
	task :schedule_notification_one => :environment do
    from_time = (Time.now+(24*(60*60))).strftime('%Y-%m-%d %H:00')
    to_time = (Time.now+(24*((60*60))+(60*60))).strftime('%Y-%m-%d %H:00')
    @schedules = DateSchedule.find(:all, :conditions =>["(user_status = 'accepted' AND dater_status = 'accepted') AND (date_on >= '#{from_time}' AND date_on < '#{to_time}')"])
    for schedule in @schedules
      UserMailer.schedule_notification_one(schedule.user, schedule.dater, schedule).deliver
      UserMailer.schedule_notification_one(schedule.dater, schedule.user, schedule).deliver
    end
  end

  desc "Send email notification of date schedule before 2 hours"
	task :schedule_notification_two => :environment do
    from_time = (Time.now+(2*(60*60))).strftime('%Y-%m-%d %H:00')
    to_time = (Time.now+(2*((60*60))+(60*60))).strftime('%Y-%m-%d %H:00')
    @schedules = DateSchedule.find(:all, :conditions =>["(user_status = 'accepted' AND dater_status = 'accepted') AND (date_on >= '#{from_time}' AND date_on < '#{to_time}')"])
    for schedule in @schedules
      UserMailer.schedule_notification_one(schedule.user, schedule.dater, schedule).deliver
      UserMailer.schedule_notification_one(schedule.dater, schedule.user, schedule).deliver
    end
  end

  desc "Will send 20 invitations every time run this task "
	task :send_invitationss => :environment do
    invitations = Invitation.all(:conditions => ["emailed_invitation = ?", false], :limit => 20)
    for invitation in invitations
      if UserMailer.invitation(invitation.user, invitation.invited_user, invitation.message).deliver
        invitation.update_attributes(:emailed_invitation => true)
      end
    end
  end

  desc "Populate login column with facebook_id for facebook users"
  task :create_login_for_facebook_users => :environment do
    users = User.find(:all, :conditions => ["facebook_id IS NOT NULL AND login IS NULL"])
    for user in users
      #      user.login = user.facebook_id.to_s
      #      user.save(false)
      user.update_attributes(:login => user.facebook_id.to_s)
    end
  end

  desc "Assign category to products which are not categorized"
	task :assign_category_to_products => :environment do
    if !Pcategory.exists?(:name => "General")
      general_category = Pcategory.new(:name => "General")
      general_category.save
    else
      general_category = Pcategory.find_by_name("General")
    end
    for product in Product.all
      if product.pcategories_products.count == 0
        PcategoriesProduct.create(:pcategory_id => general_category.id, :product_id => product.id)
      end
    end
  end

  desc "Store all uploaded files to amazon s3 storage"
	task :store_uploaded_files_to_s3 => :environment do
    photos = Photo.find(:all, :conditions => ["image_file_name IS NOT NULL"] )
    for photo in photos
      if File.exists?("#{Rails.root}/public/uploaded_files/photo/#{photo.id}/original/#{photo.image_file_name}")
        photo.image = File.new("#{Rails.root}/public/uploaded_files/photo/#{photo.id}/original/#{photo.image_file_name}")
        photo.save
      end
    end

    products = Product.find(:all, :conditions => ["photo_file_name IS NOT NULL"])
    for product in products
      if File.exists?("#{Rails.root}/public/uploaded_files/product/#{product.id}/original/#{product.photo_file_name}")
        product.photo = File.new("#{Rails.root}/public/uploaded_files/product/#{product.id}/original/#{product.photo_file_name}")
        product.save
      end
    end

    profiles = Profile.find(:all, :conditions => ["avatar_file_name IS NOT NULL"])
    for profile in profiles
      if !profile.avatar_file_name.to_s.blank? and File.exists?("#{Rails.root}/public/uploaded_files/profile/#{profile.id}/original/#{profile.avatar_file_name}")
        profile.avatar = File.new("#{Rails.root}/public/uploaded_files/profile/#{profile.id}/original/#{profile.avatar_file_name}")
        profile.save
      end
    end
  end

  desc "Send birthday wishes and give credits"
	task :add_birthday_credits => :environment do
    users = User.find(:all, :conditions => ["EXTRACT(DAY FROM date_of_birth)  = #{Date.today.day} AND EXTRACT(MONTH FROM date_of_birth) = #{Date.today.month}"])
    for user in users
      user.update_attribute(:credits, user.credits.to_i+BIRTH_DAY_CREDITS)
      UserMailer.birthday_whishes(user).deliver
    end
  end

  desc "Send anniversary wishes and give credits"
	task :add_anniversary_credits => :environment do
    users = User.find(:all, :conditions => ["EXTRACT(DAY FROM activated_at)  = #{Date.today.day} AND EXTRACT(MONTH FROM activated_at) = #{Date.today.month}"])
    for user in users
      UserMailer.anniversary_whishes(user).deliver
    end
  end

  desc "Start juggernaut server if stoped "
	task :start_juggernaut_if_not_running => :environment do
    a = %x[ps aux | grep juggernaut]
    if !a.to_s.include?("juggernaut -c juggern")
      #  b = %x[cd #{Rails.root}; juggernaut -c juggernaut.yml -d]
        b = %x[/bin/bash -l -c 'cd #{Rails.root}; juggernaut -c juggernaut.yml -d']
    end
  end

  desc "Send email reminder to user who log into the site for 30 days"
  task :log_into_the_site => :environment do
    users = User.find(:all, :conditions => ["(last_login_at + #{30*24*60*60}) < #{Time.now.strftime('%Y-%m-%d')}" ])
     for user in users
      UserMailer.login_remainder(user).deliver
    end
  end

end

