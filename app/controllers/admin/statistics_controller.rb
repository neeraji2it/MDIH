class Admin::StatisticsController < ApplicationController
  before_filter :is_admin?
  layout 'admin'

  def index
    @email_responses_graph = open_flash_chart_object(420,400,"/admin/statistics/email_responses")
    @email_responses_to_original_vs_template_graph = open_flash_chart_object(550,400,"/admin/statistics/email_responses_to_original_vs_template")
    @country = 'United States'
    @age_from = 18
    @age_to = 35
    @email_responses_by_category_graph = open_flash_chart_object(420,400,"/admin/statistics/email_responses_by_category?country=#{@country}&age_from=#{@age_from}&age_to=#{@age_to}", "email_response_by_category")
  end

  def email_responses
    title = Title.new(I18n.t("statistic.email_response.title"))

    @total_received_people = MessagesUser.find(:all, :group => "to_id", :select => "count(id)").count
    @total_replied_people = MessagesReply.find(:all, :group => "user_id", :select => "count(id)").count
    @total_non_replied_people = (@total_received_people - @total_replied_people)
    pie = Pie.new
    pie.start_angle = 90
    pie.animate = true
    pie.tooltip = '#val# of #total#<br>#percent# of 100%'
    pie.colours = ["#d01f3c", "#356aa0"]  #["#d01f3c", "#356aa0", "#C79810"]
    pie.values  = [PieValue.new(@total_non_replied_people,I18n.t("statistic.non_responded")), PieValue.new(@total_replied_people,I18n.t("statistic.responded"))] #[@total_non_replied_people, @total_replied_people]

    chart = OpenFlashChart.new
    chart.bg_colour='#EAE5E1'
    chart.title = title
    chart.add_element(pie)
    chart.x_axis = nil
    render :text => chart.to_s
  end

  def email_responses_by_category
    title = Title.new(I18n.t("statistic.email_response_by_category.title"))
    @total_replied_people = 0
    @total_non_replied_people = 0
    if !params[:country].to_s.blank? and !params[:age_from].to_s.blank? and !params[:age_to].to_s.blank?
      user_ids = User.find(:all, :select => "users.id", :joins => "LEFT JOIN profiles ON profiles.user_id = users.id", :conditions =>["profiles.country = '#{params[:country]}' AND date_of_birth  <= '#{Date.today - (364 * params[:age_from].to_i)}' AND date_of_birth  >= '#{Date.today - (364 * params[:age_to].to_i)}'"]).map{|user| user.id}
      if !user_ids.empty?
        @total_received_people = MessagesUser.find(:all, :group => "to_id", :select => "count(id)", :conditions => ["to_id IN (#{user_ids.join(', ')})"]).count
        @total_replied_people = MessagesReply.find(:all, :group => "user_id", :select => "count(id)", :conditions => ["user_id IN (#{user_ids.join(', ')})"]).count
        @total_non_replied_people = (@total_received_people - @total_replied_people)
      end
    end
    pie = Pie.new
    pie.start_angle = 90
    pie.animate = true
    pie.tooltip = '#val# of #total#<br>#percent# of 100%'
    pie.colours = ["#d01f3c", "#356aa0"]  #["#d01f3c", "#356aa0", "#C79810"]
    pie.values  = [PieValue.new(@total_non_replied_people,I18n.t("statistic.non_responded")), PieValue.new(@total_replied_people,I18n.t("statistic.responded"))] #[@total_non_replied_people, @total_replied_people]

    chart = OpenFlashChart.new
    chart.bg_colour='#EAE5E1'
    chart.title = title
    chart.add_element(pie)
    chart.x_axis = nil
    render :text => chart.to_s
  end

  def email_responses_to_original_vs_template
    title = Title.new(I18n.t("statistic.email_responses_to_original_vs_template.title"))
    @people_replied_to_templates = MessagesReply.find(:all, :select => "count(distinct(messages_replies.user_id))",
      :joins => "LEFT JOIN messages ON messages.id = messages_replies.message_id LEFT JOIN message_templates on message_templates.user_id = messages.user_id", :conditions => ["messages.body = message_templates.body"], :group => "messages_replies.user_id").count
    @people_replied_to_original_emails = MessagesReply.find(:all, :select => "count(distinct(messages_replies.user_id))",
      :joins => "LEFT JOIN messages ON messages.id = messages_replies.message_id LEFT JOIN message_templates on message_templates.user_id = messages.user_id", :conditions => ["messages.body != message_templates.body"], :group => "messages_replies.user_id").count
    
#    @people_replied_to_templates = 50
#    @people_replied_to_original_emails = 12

    pie = Pie.new
    pie.start_angle = 90
    pie.animate = true
    pie.tooltip = '#val# of #total#<br>#percent# of 100%'
    pie.colours = ["#d01f3c", "#356aa0"]  #["#d01f3c", "#356aa0", "#C79810"]
    pie.values  = [PieValue.new(@people_replied_to_templates,I18n.t("statistic.email_responses_to_original_vs_template.replies_to_template_emails")), PieValue.new(@people_replied_to_original_emails,I18n.t("statistic.email_responses_to_original_vs_template.replies_to_template_emails"))] #[@total_non_replied_people, @total_replied_people]

    chart = OpenFlashChart.new
    chart.bg_colour='#EAE5E1'
    chart.title = title
    chart.add_element(pie)
    chart.x_axis = nil
    render :text => chart.to_s
  end
  
end
