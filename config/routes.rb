MDIH::Application.routes.draw do
  match 'feedbacks' => 'feedbacks#create'
  match 'feedbacks/new' => 'feedbacks#new'
  match 'language/:language/change' => 'sessions#change_language', :as => :change_language
  match '/signup' => 'users#new'
  match '/logout' => 'sessions#destroy', :as => :signout
  match 'about_us'=> "home#about_us"
  match 'contact_us' => "home#contact_us"
  match 'privacy', :controller => "home", :action => "privacy"
  match 'tos', :controller => "home", :action => "terms_of_use"
  post '/check_login' => "home#check_login", :as => :check_login

  match "/error/:id", :controller => "home", :action => "error"
  match "/home/start_search", :controller => "home", :action => "start_search"
  match '/auth/:provider/callback', :to => 'authentications#create'
  match '/auth/failure', :to => 'authentications#failure'

  match "/users/activate/:activation_code" => "users#activate", :as => :activate
  match '/reset_password/:reset_code' => "users#reset_password", :as => :reset_password
  match "/users/deactivate/:crypted_email" => "users#deactivate_account", :as => :deactivate_user_account
 
  match "/users/reactivate_account/:login" => "users#reactivate_account", :as => :reactivate_user_account
  match "/users/reactivate/:crypted_email" => "users#reactivate", :as => :reactivate_account

  match "facebook" => "facebook#index", :as => :facebook

  
  resource :session

  resources :users do
    collection do
      post :forgot_password
      match :accept_invitation
      post :resend_activation_email
      post  :signup_step1
      post  :signup_step2
      post  :create_user
      match :recharge_credits
      get :show_recharge_credits_form
      put :update_free_today
      put :update_chat_status
      post :change_online_status
    end
    member do
      post :hot_vote
      match :email_settings
      delete :delete_account
    end
    resources :profiles do
      collection do
        get :visitors
        get :visited
        get :edit_photo
        post :update_photo
        match :update_headline
      end
      member do
        get :show_inappropriate_dialog 
        post :report_inappropriate_avatar
      end
    end
    resources :quick_messages do
      collection do
        get :send_message
      end
    end
    resources :friends do
      collection do
        get :requested_friends
        get :search
        get :online_friends
      end
      member do
        match :add
        post :confirm_or_ignore
      end
    end
    resources :messages do
      collection do
        delete :make_delete
      end
      member do
        match :conversation
        post :reply
        get :block_user
        get :delete_all_messages
        match :sent_messages
        match :recall
      end
    end
    resources :gifts, :only => [:destroy] do
      collection do
        get :send_gifts
        get :ajax_send_gifts
        get :gifts_popup
      end
      member do
        get :send_gift
        post :send_to_friend
        get :received_gifts
        get :sent_gifts
      end
    end
    resources :albums do
      member do
        match :upload_photos
      end
      collection do
        get :albums_popup
      end
      resources :photos do
        member do
          get :make_album_cover
          get :ajax_show
          post :create_comment
          delete :delete_comment
          post :post_comment
          match :report_as_inappropriate
          get :show_photo_inappropriate_form
          post :make_profile_photo
        end
        collection do
          match :fancy_show
        end
      end
    end
    resources :schedules do
      collection do
        get :whom_i_requested
        get :who_requeted_me
        get :my_dates
      end
      member do
        get :change_status
        put :update_status
      end
    end
    resources :contacts do
      collection do
        match :import
        post :invite
      end
    end
    resources :message_templates do
      collection do
        delete :destroy_templates
        get :select_template
      end
    end
    resources :statistics do
      collection do
        get :email_responses
        get :best_time_to_get_response
        get  :highest_percentage_match_login
        get :test
      end
      member do
        get :match_login_history
        get :test 
      end
    end
  end
  match "/users/:user_id/messages/display/:message_type" => "messages#index", :as => :messages_box
  match "users/:user_id/gifts/:type" => "gifts#index", :as => :my_gifts
  resources :searches do
    collection do
      get :simple_results
      get :advance
      get :advance_results
      get :blocked_users
      get :near_by
      get :keyword_search_results
    end
    member do
      get :block_user
      get :unblock_user
    end
  end
  root :to => "home#index"
  resources :saved_searches
  
  resources :chat do
    member do
      get :new_window
      post :open_chat_window
      post :close_chat_window
    end
    collection do
      post :updates
      post :initial_data
      get :new_chats
    end
  end
  resources :video_chat do
    member do
      get :video
    end
  end

  match "/chat" => "users#chat", :as => :chat
  match "/all_notifications" => "home#all_notifications", :as => :all_notifications
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  namespace :admin do
    resources :users do
      member do
        put :change_status
        match :change_credits
        put :resend_activation_email
      end
      collection do
        get :blocked_users
        get :users_credits
        get :users_search
      end
    end
    resources :products
    resources :feedbacks, :only => [:index, :destroy]
    resources :inappropriate_photos, :only => [:index, :destroy, :show] do
      member  do
        delete :destroy_photo
        put :remove_photo
        get :profile
        put :remove_profile_photo
      end
      collection do
        get :profiles
      end
    end
    resources :pcategories
    resources :statistics, :only => [:index] do
      collection  do
        get :email_responses
        get :email_responses_by_category
        get :email_responses_to_original_vs_template
      end
    end
  end
  namespace :api do
    resource :session
    resources :users do
      collection  do
        post :forgot_password
        get :my_matches
        get :recent_actions
        get :visitors
        get :visited
        post :recharge_creadits
      end
      member do
        post :add_to_my_match
        delete :delete_from_my_match
      end
      resources :profiles do
        collection do
          post :update_photo
        end
      end
      resources :albums do
        resources :photos do
          member do
            get :make_album_cover
            get :comments
            delete :delete_comment
            post :post_comment
            post :report_as_inappropriate
            get  :make_profile_photo
          end
        end
      end
      resources :friends do
        collection do
          get :requested_friends
        end
        member do
          post :add
          post :confirm_or_ignore
        end
      end
    end
    resources :messages do
      member do
        post :reply
        get :conversation
        get :sent_messages
      end
    end
    resources :gifts, :only => [:index, :destroy] do
      collection do
        get :my_gifts
        get  :categories
      end
      member do
        post :send_to_fried
      end
    end
    resources :searches, :only => [] do
      collection do
        get :simple_results
        get :advance_results
        get :near_by_location
      end
    end
    resources :saved_searches, :only => [:index, :create, :destroy]
    resource :chat, :controller => "chat" do
      collection do
        post :updates
        post :initial_data
        post :history
        post :get_online_friends
        post :go_offline
        post :go_online
        post :get_counts
      end
    end
    resources :message_templates, :only => [:index, :create, :update, :destroy] do
      member do
        post :send_to_friends
      end
    end
  end

  match "/api/messages/display/:message_type.:format" => "api/messages#index", :as => :api_messages_box
  match '/api/contact_us.:format' => "api/users#contact_us" , :as => :api_contact_us
  match '/api/feedback.:format' => "api/users#feedback", :as => :api_feedback



  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
