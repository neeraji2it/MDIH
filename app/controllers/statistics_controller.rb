class StatisticsController < ApplicationController
  def index
    
    @email_responses_graph = open_flash_chart_object(400,400,"/users/#{@user.login}/statistics/email_responses")
    @best_time_to_get_response_graph = open_flash_chart_object(500,400,"/users/#{@user.login}/statistics/best_time_to_get_response")
    if current_user.id == @user.id and (@matches = current_user.my_matches(:select => "login, id")) and !@matches.empty?
    
      @highest_percentage_match_login_graph = open_flash_chart_object(500,400, "/users/#{@user.login}/statistics/#{@matches.first.login}/match_login_history", "match_login_graph")
    end
    #    @test = open_flash_chart_object(500,400,"/users/#{@user.login}/statistics/test")
  end

  def email_responses
    title = Title.new(I18n.t('statistic.email_response.title'))
    @total_received_people = Message.count(:select => "distinct(messages_users.to_id)", :joins => "left join messages_users ON messages_users.message_id = messages.id", :conditions => ["messages.user_id = #{@user.id} and messages_users.to_id IS NOT NULL"])
    @total_replied_people = Message.count(:select => "distinct(messages_users.to_id)", :joins => "left join messages_users ON messages_users.message_id = messages.id left join messages_replies ON messages_replies.message_id = messages.id", :conditions => ["messages.user_id = #{@user.id} and (messages_users.to_id IS NOT NULL AND messages_replies.user_id = messages_users.to_id)"])
    @total_non_replied_people = (@total_received_people - @total_replied_people)
    pie = Pie.new
    pie.start_angle = 0
    pie.animate = true
    pie.tooltip = '#val# of #total#<br>#percent# of 100%'
    pie.colours = ["#d01f3c", "#356aa0"]  #["#d01f3c", "#356aa0", "#C79810"]
    pie.values  = [PieValue.new(@total_non_replied_people,I18n.t('statistic.non_responded')), PieValue.new(@total_replied_people,I18n.t('statistic.responded'))] #[@total_non_replied_people, @total_replied_people]

    chart = OpenFlashChart.new
    chart.bg_colour='#EAE5E1'
    chart.title = title
    chart.add_element(pie)
    chart.x_axis = nil
    render :text => chart.to_s
  end

  def best_time_to_get_response
    @total_replies = MessagesReply.find(:all, :joins => "left join messages on messages.id = messages_replies.message_id", :conditions => ["messages.user_id = #{@user.id}"])
    @reply_details = {}
    
    #hashing multiple time entries for the day
    @total_replies.each do |reply|
      if @reply_details.has_key?(reply.created_at.strftime("%H"))
        if @reply_details[reply.created_at.strftime("%H")].has_key?("counter")
          @reply_details[reply.created_at.strftime("%H")]["counter"] += 1
        else
          @reply_details[reply.created_at.strftime("%H")]["counter"] += 1
        end
      else
        @reply_details[reply.created_at.strftime("%H")] = {"counter" => 1 }
      end
    end
    @hours_day = []
    maxi_replies = 0
    @total_reply = []

    @reply_details.sort.each do |reply_counter|
      @hours_day << convert_24_to_12(reply_counter[0])
      @total_reply << reply_counter[1]["counter"]
      maxi_replies = maxi_replies < reply_counter[1]["counter"] ? reply_counter[1]["counter"] : maxi_replies
    end
    #    maxi_replies += 10 if maxi_replies > 100

    #        @hours_day = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", " 9 AM", "10 AM", "11 AM", "12 PM",
    #          "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    #        @total_reply = [100, 150, 200, 140,  130,  240, 200, 102, 120, 101, 222, 213, 123, 134, 145, 165, 145, 100, 178, 190, 200, 150, 140, 170]
    #        maxi_replies = 250
    

    x_legend = XLegend.new("Hours")
    x_legend.set_style('{font-size: 14px; color: #000000}')

    y_legend = YLegend.new("Replies")
    y_legend.set_style('{font-size: 14px; color: #000000}')

    y = YAxis.new
    y.set_range(0,maxi_replies.to_i,(maxi_replies)/10)

    x_labels = XAxisLabels.new
    x_labels.set_vertical()
    x_labels.labels = @hours_day
    x = XAxis.new
    x.set_labels(x_labels)

    title = Title.new(I18n.t('statistic.best_time'))

    bar = Bar.new
    bar.values  = @total_reply
    bar.tooltip = "Replies: #val# "
    bar.colour  = '#356aa0'


    t = Tooltip.new
    t.set_shadow
    t.stroke = 2
    t.colour = '#6E604F'
    t.set_background_colour("#EAE5E1")
    t.set_title_style("{font-size: 14px; color: #000000;}")
    t.set_body_style("{font-size: 10px; font-weight: bold; color: #d01f3c;}")

    chart = OpenFlashChart.new
    chart.title = title
    chart.add_element(bar)
    chart.set_tooltip(t)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.x_axis = x
    chart.y_axis = y
    chart.bg_colour = '#EAE5E1'
    render :text => chart.to_s

  end

  def match_login_history
    @match = User.find(:first, :conditions => ["login = ?", params[:id]])
    @hours_day = []
    @total_logins = []
    maxi_logins = 0
    @login_details = {}
    if @match
      login_histories = LoginHistory.find(:all, :conditions => ["user_id = #{@match.id}"])
      login_histories.each do |login_history|
        if @login_details.has_key?(login_history.logged_at.strftime("%H"))
          if @login_details[login_history.logged_at.strftime("%H")].has_key?("counter")
            @login_details[login_history.logged_at.strftime("%H")]["counter"] += 1
          else
            @login_details[login_history.logged_at.strftime("%H")]["counter"] += 1
          end
        else
          @login_details[login_history.logged_at.strftime("%H")] = {"counter" => 1 }
        end
      end
      @login_details.sort.each do |login_counter|
        @hours_day << convert_24_to_12(login_counter[0])
        @total_logins << login_counter[1]["counter"]
        maxi_logins = maxi_logins < login_counter[1]["counter"] ? login_counter[1]["counter"] : maxi_logins
      end
    end

    #    if params[:id] == "rnagarjuna"
    #      @hours_day = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", " 9 AM", "10 AM", "11 AM", "12 PM",
    #        "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    #      @total_reply = [100, 150, 200, 140,  130,  240, 200, 102, 120, 101, 222, 213, 123, 134, 145, 165, 145, 100, 178, 190, 200, 150, 140, 170]
    #      maxi_replies = 250
    #    else
    #      @hours_day = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", " 9 AM", "10 AM", "11 AM", "12 PM"]
    #      @total_reply = [100, 150, 200, 140,  130,  240, 200, 102, 120, 101, 220, 213, 123]
    #      maxi_replies = 240
    #    end

    x_legend = XLegend.new("Hours")
    x_legend.set_style('{font-size: 14px; color: #000000}')

    y_legend = YLegend.new("No. of times logged in")
    y_legend.set_style('{font-size: 14px; color: #000000}')

    y = YAxis.new
    y.set_range(0, maxi_logins.to_i,(maxi_logins)/10)

    x_labels = XAxisLabels.new
    x_labels.set_vertical()
    x_labels.labels = @hours_day
    x = XAxis.new
    x.set_labels(x_labels)

    title = Title.new(I18n.t('statistic.online_history'))

    bar = Bar.new
    bar.values  = @total_logins
    bar.tooltip = "#{I18n.t('statistic.no_of_time')} #val# "
    bar.colour  = '#356aa0'


    t = Tooltip.new
    t.set_shadow
    t.stroke = 2
    t.colour = '#6E604F'
    t.set_background_colour("#EAE5E1")
    t.set_title_style("{font-size: 14px; color: #000000;}")
    t.set_body_style("{font-size: 10px; font-weight: bold; color: #d01f3c;}")

    chart = OpenFlashChart.new
    chart.title = title
    chart.add_element(bar)
    chart.set_tooltip(t)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.x_axis = x
    chart.y_axis = y
    chart.bg_colour = '#EAE5E1'
    render :text => chart.to_s
  end

  
  def test1
    @hours_day = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", " 9 AM", "10 AM", "11 AM", "12 PM",
      "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    @total_reply = [100, 150, 200, 140,  130,  240, 200, 102, 120, 101, 222, 213, 123, 134, 145, 165, 145, 100, 178, 190, 200, 150, 140, 170]

    #    @hours_day = ["4 PM"]
    #    @total_reply = [240]
    maxi_replies = 240
    x_legend = XLegend.new("Hours")
    x_legend.set_style('{font-size: 20px; color: #000000}')

    y_legend = YLegend.new("Replies")
    y_legend.set_style('{font-size: 20px; color: #000000}')

    y = YAxis.new
    y.set_range(0,maxi_replies.to_i,(maxi_replies)/10)

    x_labels = XAxisLabels.new
    x_labels.set_vertical()
    x_labels.labels = @hours_day
    x = XAxis.new
    x.set_labels(x_labels)
    
    title = Title.new(I18n.t('statistic.multibar'))

    bar = Bar.new
    bar.values  = @total_reply
    bar.tooltip = "#{I18n.t('statistic.replies')} #val# "
    bar.colour  = '#356aa0'


    t = Tooltip.new
    t.set_shadow
    t.stroke = 2
    t.colour = '#6E604F'
    t.set_background_colour("#EAE5E1")
    t.set_title_style("{font-size: 14px; color: #000000;}")
    t.set_body_style("{font-size: 10px; font-weight: bold; color: #d01f3c;}")

    chart = OpenFlashChart.new
    chart.title = title
    chart.add_element(bar)
    #    chart.add_element(bar2)
    chart.set_tooltip(t)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.x_axis = x
    chart.y_axis = y
    chart.bg_colour = '#EAE5E1'
    render :text => chart.to_s


  end
end
