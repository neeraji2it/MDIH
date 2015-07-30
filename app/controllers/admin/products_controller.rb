class Admin::ProductsController < ApplicationController

  before_filter :is_admin?
  layout 'admin'

  # GET /products
  # GET /products.xml
  def index
    @products = Product.all.paginate(:per_page => 12, :page => params[:page], :order => "updated_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
#  def show
#    @product = Product.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @product }
#    end
#  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])
    @product.user_id = current_user.id
    @product.add_categories(params[:selected_categories])
    respond_to do |format|
      if @product.save
        flash[:notice] = I18n.t("product.create.notice")
        format.html { redirect_to admin_products_path }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      @product.add_categories(params[:selected_categories])
      if @product.update_attributes(params[:product])
        flash[:notice] = I18n.t("product.update.notice")
        format.html { redirect_to admin_products_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(admin_products_url) }
      format.xml  { head :ok }
    end
  end
end
