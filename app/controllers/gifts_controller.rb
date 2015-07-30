class GiftsController < ApplicationController

  def index
    @user = User.find(:first, :conditions =>["login = ? OR id = ?", params[:user_id], params[:user_id]])
    @gifts_type = params[:type] || "received"
    @gifts = if @gifts_type == "sent"
      sql_query = "select * from sent_gifts a where  a.sent_to in ( select sent_to from sent_gifts where user_id=#{current_user.id}) and id in ( select max(id) from sent_gifts b where a.user_id =b.user_id
               and a.sent_to=b.sent_to and b.sender_status != 'deleted' ) and a.user_id = #{current_user.id} order by a.sent_on DESC"
      SentGift.paginate_by_sql [sql_query], :per_page => 10, :page => params[:page]
    elsif @gifts_type == "received"
      sql_query = "select * from sent_gifts a where  a.user_id in ( select user_id from sent_gifts where sent_to=#{current_user.id}) and id in ( select max(id) from sent_gifts b where a.user_id =b.user_id
               and a.sent_to=b.sent_to and b.receiver_status != 'deleted' ) and a.sent_to = #{current_user.id} order by a.sent_on DESC"
      session[:viewed_received_gifts] = true
      SentGift.paginate_by_sql [sql_query], :per_page => 10, :page => params[:page]
    end
    render :partial => "ajax_gifts", :layout => false if request.xhr?
  end

  def gifts_popup
    session[:viewed_received_gifts] = true
    @gifts = if current_user.last_login_at.present?
      current_user.received_gifts.where(["sent_to = #{current_user.id} AND sent_on > '#{current_user.last_login_at.strftime('%Y-%m-%d %H:%M:%S')}' AND receiver_status != 'deleted'"]).order("sent_on DESC")
    else
      {}
    end
    render :partial => "gifts_popup", :layout => false if request.xhr?
  end

  def send_gifts
    @user = User.find(params[:user_id])
    if params[:pcategory_id] and Pcategory.exists?(:id => params[:pcategory_id])
      @products = Pcategory.find(params[:pcategory_id]).products.paginate(:order => "updated_at DESC", :per_page => 9, :page => params[:page])
    else
      @products = Product.all(:order => "updated_at DESC").paginate(:per_page => 9, :page => params[:page])
    end

    render :action => "index"
  end

  def received_gifts
    @user = User.find(params[:id])
    @message_templates = current_user.message_templates
    @gifts = SentGift.paginate :conditions => ["((sent_gifts.user_id = #{@user.id} and sent_gifts.sent_to = #{current_user.id}) and sent_gifts.receiver_status != 'deleted')"], :order => "sent_gifts.sent_on Desc" , :page => params[:page], :per_page => 20
    render :partial => "ajax_received_gifts", :layout => false if request.xhr?
  end

  def sent_gifts
    @user = User.find(params[:id])
    @gifts = SentGift.paginate :conditions => ["((sent_gifts.user_id = #{current_user.id} and sent_gifts.sent_to = #{@user.id}) and (sent_gifts.sender_status != 'deleted' and sent_gifts.sender_status != 'pending'))"], :order => "sent_gifts.sent_on Desc" , :page => params[:page], :per_page => 20
    render :partial => "ajax_sent_gifts", :layout => false if request.xhr?
  end

  def ajax_send_gifts
    @user = User.find(:first, :conditions =>["login = ? OR id = ?", params[:user_id], params[:user_id]])
    if params[:pcategory_id] and Pcategory.exists?(:id => params[:pcategory_id])
      @products = Pcategory.find(params[:pcategory_id]).products.paginate(:order => "updated_at DESC", :per_page => 6, :page => params[:page])
    else
      @products = Product.paginate(:order => "updated_at DESC", :per_page => 3, :page => params[:page])
    end
    if params[:page].nil?
      render :partial => "ajax_send_gifts", :layout => false
    else
      render :partial => "gift_list", :layout => false
    end
  end

  def send_gift
    @user = User.find(params[:user_id])
    @product = Product.find(params[:id])
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      render :action => "index"
    end
  end

  def send_to_friend
    @user = User.find(params[:user_id])
    @product = Product.find(params[:id])
    @sent_gift = SentGift.new(:user_id => current_user.id, :sent_to => @user.id, :product_id => params[:id], :sent_on => Time.now, :message => params[:message])
    @sent = false
    @flash_message = ""
    if current_user.credits >= @product.credits
      if @sent_gift.save
        @sent = true
        UserMailer.gift_notification(current_user, @user, @product, @sent_gift).deliver if !@user.email.to_s.blank? and !EmailSetting.exists?(:user_id => @user.id, :alert_type => 'gifts', :status => false)
        current_user.credits = current_user.credits - @product.credits
        current_user.save
        @flash_message = ("<span style='color:green'>#{I18n.t('gift.flash_message')}</span>").html_safe
      else
        @flash_message = ("<span style='color:red'>#{I18n.t('gift.flash_message1')}</span>").html_safe
      end
    else
      @flash_message = ("<span style='color:red'>#{I18n.t('gift.flash_message2')}</span>").html_safe
    end
    if request.xhr?
      respond_to do |format|
        format.js
      end
    else
      if sent
        flash[:notice] = @flash_message
        redirect_to send_gifts_user_gifts_path(@user)
      else
        flash[:error] = @flash_message
        render :action => "index"
      end
    end
  end
  
  def destroy
    @sent_gift = SentGift.find(params[:id])
    if (@sent_gift.user_id == current_user.id and @sent_gift.receiver_status == "deleted") or (@sent_gift.sent_to == current_user.id and @sent_gift.sender_status == "deleted")
      @sent_gift.destroy
    elsif @sent_gift.user_id == current_user.id
      @sent_gift.update_attribute(:sender_status, "deleted")
    elsif @sent_gift.sent_to == current_user.id
      @sent_gift.update_attribute(:receiver_status, "deleted")
    else
      flash[:error] = I18n.t('user.general_error')
      redirect_to "/"
      return
    end
    render :text => true
  end

end
