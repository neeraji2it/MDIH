class Api::SavedSearchesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_alert_variables, :http_auth

  def index
    @saved_searches = SavedSearch.all
    respond_to do |format|
      format.xml { render :xml => @saved_searches }
      format.json { render :json => @saved_searches }
    end
  end

  def create
    @saved_search = current_user.saved_searches.build(params[:saved_search])
    if @saved_search.save
      flash_message = {:message => I18n.t('search.create.search_save')}
    else
      flash_message = {:error => I18n.t('search.create.search_not_saved')}
    end
    respond_to do |format|
      format.xml { render :xml => flash_message }
      format.json { render :json => flash_message }
    end
  end

end
