require'opentok'
class VideoChatController < ApplicationController

  def show
    config_opentok
    opentok_session = @opentok.create_session request.remote_addr
    @tok_session_id = opentok_session.session_id
    @tok_token = @opentok.generate_token :session_id => opentok_session.session_id
    reciever = User.find(params[:id])
    vchat_url = "/video_chat/#{params[:id]}/video/?tok_session_id=#{@tok_session_id}&tok_token=#{@tok_token}"
    my_vchat_url = "/video_chat/#{current_user.id}/video/?tok_session_id=#{@tok_session_id}&tok_token=#{@tok_token}"
    text = "Initiated video chat"
    current_user.sent_chats.new(:text => text, :reciever_id => params[:id]).save
    messages = reciever.read_chats
    hash = {}
    for message in messages
      hash = {:text => message.text, :sender_name => message.sender.name, :sender_id => message.sender.id, 
        :reciever_name => message.reciever.name, :reciever_id => message.reciever.id,
        :sender_age => message.sender.try(:age), :receiver_age => message.reciever.try(:age),
        :sender_photo => (message.sender.facebook_id.present? ? (message.sender.profile ?
              (message.sender.profile.avatar_file_name != "picture_type_large.jpg" ? message.sender.profile.avatar.url(:original) : message.sender.fb_big_image) : message.sender.fb_big_image) : (message.sender.profile ? message.sender.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")), :reciever_photo => (message.reciever.facebook_id.present? ? (message.reciever.profile ? (message.reciever.profile.avatar_file_name != "picture_type_large.jpg" ? message.reciever.profile.avatar.url(:original) : message.reciever.fb_big_image) : message.reciever.fb_big_image) : (message.reciever.profile ? message.reciever.profile.avatar.url(:original)  : "/assets/default_avatar.jpg")), :sender_gender => message.sender.gender, :reciever_gender => message.reciever.gender}
      Juggernaut.publish("users:#{reciever.id}:#{current_user.id}", hash.to_json)
    end
    if !hash.empty?
      hash[:text] = my_vchat_url
      Juggernaut.publish("users:#{reciever.id}:#{current_user.id}", hash.to_json)
    end
    render :update do |page|
      page << "window.open('#{vchat_url}', '_blank', 'location=1,status=1,scrollbars=yes, width=800,height=450,left=400,top=200,screenX=500,screenY=500')"
    end
  end

  def config_opentok
    if @opentok.nil?
      @opentok = OpenTok::OpenTokSDK.new OPEN_TOK_API_KEY, OPEN_TOK_API_SECRET
    end
  end

  def video
    if !params[:tok_session_id].to_s.blank? and !params[:tok_token].to_s.blank?
      @user = User.find(params[:id])
      @tok_session_id = params[:tok_session_id]
      @tok_token = params[:tok_token]
      render :layout => false;
    end
  end

end
