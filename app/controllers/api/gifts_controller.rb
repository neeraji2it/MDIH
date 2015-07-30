class Api::GiftsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  def categories
    @pcategories = Pcategory.all
    respond_to do |format|
      format.xml { render :xml => @pcategories }
      format.json { render :json => @pcategories }
    end
  end

  def index
    @products = if params[:category_id]
      Product.find(:all, :joins => "LEFT JOIN pcategories_products ON product_id = products.id", :conditions => ["pcategory_id = ?", params[:category_id]], :order => "updated_at DESC")
    else
      Product.find(:all, :order => "updated_at DESC")
    end
    @products.collect{|product| product['photo-url'] = product.photo.url}
    respond_to do |format|
      format.xml { render :xml => @products }
      format.json { render :json => @products }
    end
  end

  def my_gifts
    @gifts_type = params[:type] || "received"
    select = "sent_gifts.*, products.id AS product_id, products.name, products.photo_file_name, products.photo_content_type, products.photo_updated_at , products.photo_file_size, products.credits, users.login, users.gender"
    @gifts = if @gifts_type == "sent"
      #      current_user.sent_gifts.all(:order => "sent_on DESC", :joins => "LEFT JOIN users ON users.id = sent_gifts.sent_to", :select => "sent_gifts.*, users.first_name, users.last_name, users.middle_name, users.login", :include => [:products])
      Product.find(:all, :joins => "LEFT JOIN sent_gifts ON sent_gifts.product_id = products.id LEFT JOIN users ON users.id = sent_gifts.sent_to", :conditions => ["sent_gifts.user_id = #{current_user.id} AND sender_status != 'deleted'"], :select => select, :order => "sent_on DESC")
    else
#      current_user.received_gifts.all(:order => "sent_on DESC", :joins => "LEFT JOIN users ON users.id = sent_gifts.user_id", :select => "sent_gifts.*, users.first_name, users.last_name, users.middle_name, users.login")
      Product.find(:all, :joins => "LEFT JOIN sent_gifts ON sent_gifts.product_id = products.id LEFT JOIN users ON users.id = sent_gifts.user_id", :conditions => ["sent_gifts.sent_to = #{current_user.id} AND receiver_status != 'deleted'"], :select => select, :order => "sent_on DESC")
    end
    @gifts.collect{|gift| gift['photo-url'] = gift.photo.url.gsub(gift.id.to_s, gift.product_id.to_s)}
    respond_to do |format|
      format.xml { render :xml => @gifts }
      format.json { render :json => @gifts }
    end
  end

  def send_to_fried
    if User.exists?(:id => params[:user_id]) and Product.exists?(:id => params[:id])
      @user = User.find(params[:user_id])
      @product = Product.find(params[:id])
      if @user.credits >= @product.credits
        @sent_gift = SentGift.new(:user_id => current_user.id, :sent_to => @user.id, :product_id => params[:id], :sent_on => Time.now, :message => params[:message][0..253])
        if @sent_gift.save and @user.update_attribute(:credits, (@user.credits - @product.credits))
          UserMailer.gift_notification(current_user, @user, @product, @sent_gift).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'gifts', :status => false)
          message = I18n.t('gift.flash_message')
          respond_to do |format|
            format.xml { render :xml => {:message => message} }
            format.json { render :json => {:message => message} }
          end
        else
          error = I18n.t('gift.flash_message1')
          respond_to do |format|
            format.xml { render :xml => {:error => error} }
            format.json { render :json => {:error => error} }
          end
        end
      else
        error = I18n.t('gift.flash_message3')
        respond_to do |format|
          format.xml { render :xml => {:error => error} }
          format.json { render :json => {:error => error} }
        end
      end
    else
      error = I18n.t('gift.invalid_user_id')
      respond_to do |format|
        format.xml { render :xml => {:error => error} }
        format.json { render :json => {:error => error} }
      end
    end
  end

  def destroy
    if SentGift.exists?(:id => params[:id])
      @sent_gift = SentGift.find(params[:id])
      if (@sent_gift.user_id == current_user.id and @sent_gift.receiver_status == "deleted") or (@sent_gift.sent_to == current_user.id and @sent_gift.sender_status == "deleted")
        @sent_gift.destroy
      elsif @sent_gift.user_id == current_user.id
        @sent_gift.update_attributes(:sender_status => "deleted")
      elsif @sent_gift.sent_to == current_user.id
        @sent_gift.update_attributes(:receiver_status => "deleted")
      else
        error = I18n.t('user.general_error')
        respond_to do |format|
          format.xml { render :xml => {:error => error} }
          format.json { render :json => {:error => error} }
        end
        return
      end
      message = I18n.t('gift.destroy.notice')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    else
      message = I18n.t('gift.invalid_id_passed')
      respond_to do |format|
        format.xml { render :xml => {:message => message} }
        format.json { render :json => {:message => message} }
      end
    end
  end
end
