class Admin::PcategoriesController < ApplicationController

  before_filter :is_admin?
  layout 'admin'

  def index
    @pcategories = Pcategory.all
  end

  def new
    @pcategory = Pcategory.new
    render :partial => "form"
  end

  def create
    @pcategory = Pcategory.new(params[:pcategory])
    @status = @pcategory.save
  end

  def edit
    @pcategory = Pcategory.find(params[:id])
    render :partial => "form"
  end

  def update
    @pcategory = Pcategory.find(params[:id])
    @status =  @pcategory.update_attributes(params[:pcategory])
  end

  def destroy
    @pcategory = Pcategory.find(params[:id])
    if @pcategory.destroy
      flash[:notice] = I18n.t("pcategory.destroy.notice")
    else
      flash[:error] = I18n.t("pcategory.destroy.notice")
    end
    redirect_to admin_pcategories_path
  end
end
