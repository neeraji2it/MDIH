class ContactsController < ApplicationController

  before_filter :is_my_contact, :only => [:edit, :update, :destroy]

  # Will get the contact from theire email with given username/password and stores in imported_contacts table
  def import
    if request.post?
      login = params[:email].to_s
      password = params[:password].to_s
      begin
        case params[:lib]
        when "gmail.com"
          @contacts = Contacts::Gmail.new(login, password)
        when "yahoo.com"
          @contacts = Contacts::Yahoo.new(login, password)
        when "yahoo.co.in"
          @contacts = Contacts::Yahoo.new(login, password)
        when "hotmail.com"
          @contacts =  Contacts::Hotmail.new(login+"@hotmail.com", password)
        when "aol.in"
          @contacts =  Contacts::Aol.new(login+"@aol.in", password)
        else
          @contacts = Contacts::Plaxol.new(login, password)
        end
        @contacts = @contacts.contacts

      rescue
        flash.now[:error] = I18n.t('contact.import.error')
        render :action => "index"
        return
      end
      for contact in @contacts
        email = params[:lib] == 'hotmail.com' ? contact[0].to_s.strip : contact[1].to_s.strip
        name = params[:lib] == 'hotmail.com' ? contact[1].to_s.strip : contact[0].to_s.strip
        if !ImportedContact.exists?(:email => email, :user_id => current_user.id)
          ImportedContact.new(:user_id => current_user.id, :name => name.to_s, :email => email).save
        end
      end
      redirect_to user_contacts_path(current_user)
      return
    end
    render :action => "index"
  end

  # Will display all imported contacts of current user
  def index
    conditions = params[:start_with] ? (params[:start_with] != 'other' ? ['email like ? OR name like ? ', params[:start_with]+'%', params[:start_with]+'%'] : ['email < ? ', 'a'] ) : ""
    @conatcts = current_user.imported_contacts.paginate(:conditions => conditions, :per_page => 20, :page => params[:page], :order => "created_at DESC")
    render :action => "index"
  end

  def new
    @imported_contact = ImportedContact.new
    render :partial => "form"
  end

  def create
    @imported_contact = ImportedContact.new(params[:imported_contact].merge({:user_id => current_user.id}))
    if @imported_contact.save
      flash[:notice] = I18n.t('contact.create.notice')
      render :update do |page|
        page.redirect_to user_contacts_path(current_user)
      end
    else
      render :update  do |page|
        page.replace_html 'popup_body',  render(:partial => 'form', :layout => false)
      end
    end
  end

  def edit
    render :partial => "form"
  end

  def update
    if @imported_contact.update_attributes(params[:imported_contact])
      flash[:notice] = I18n.t('contact.update.notice')
      render :update do |page|
        page.redirect_to user_contacts_path(current_user)
      end
    else
      render :update do |page|
        page.replace_html "popup_body", (render :partial => "form")
      end
    end
  end

  def destroy
    if @imported_contact.destroy
      flash[:notice] = I18n.t('contact.destroy.notice')
      if request.xhr?
        render :update do |page|
          page.reload
        end
      else
        redirect_to user_contacts_path(current_user)
      end
    end
  end

  def invite
    if params[:contact_ids] and !params[:contact_ids].empty?
      for contact_id in params[:contact_ids]
        contact = ImportedContact.find(contact_id)
        if !User.exists?(:email => contact.email)
          user = User.new(:email => contact.email)
          user.save(:validate => false)
          if user.id
            Invitation.create(:user_id => current_user.id, :invited_id => user.id, :message => params[:message].to_s)
            UserMailer.invitation(current_user, user, params[:message].to_s).deliver
          end
        end
      end
      flash[:notice] = I18n.t('contact.invite.notice')
    else
      flash[:error] = I18n.t('contact.invite.error')
    end
    redirect_to (params[:current_url] ? params[:current_url] : user_contacts_path(current_user))
  end

  private

  def is_my_contact
    @imported_contact = ImportedContact.find(params[:id])
    unless current_user.id == @imported_contact.user_id
      flash[:error] = I18n.t('user.general_error')
      if request.xhr?
        render :update do |page|
          page.redirect_to "/"
        end
      else
        redirect_to "/"
      end
      return
    end
  end
end
