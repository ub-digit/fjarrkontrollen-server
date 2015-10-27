Illbackend::Application.routes.draw do

  resources :session
  
  get "libris_info/neg_responses"
  get "libris_info/user_requests"
 
  get "app_info/deployinfo"
  get "users/authorise"
  #get "users/" => "users#index"
  #get "users/:xkonto" => "users#show"
  get 'users' => 'users#index'
  get 'users/:id' => 'users#show', :constraints => { :id => /[0-9]+/ }
  get 'users/:xkonto' => 'users#show_by_xkonto', :constraints => { :xkonto => /[A-Za-z]+/ }

  get 'statuses' => 'statuses#index'
  get 'statuses/:id' => 'statuses#show', :constraints => { :id => /[0-9]+/ }

  get 'status_groups' => 'status_groups#index'
  get 'status_groups/:id' => 'status_groups#show', :constraints => { :id => /[0-9]+/ }

  get 'order_types' => 'order_types#index'
  get 'order_types/:id' => 'order_types#show', :constraints => { :id => /[0-9]+/ }

  get 'locations' => 'locations#index'
  get 'locations/:id' => 'locations#show', :constraints => { :id => /[0-9]+/ }
  get 'locations/:label' => 'locations#show_by_label', :constraints => { :label => /[A-Za-z\-]+/ }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
#resources :orders do
#end


  get "form_orders/:id(.format)" => "orders#show", :constraints  => { :id => /[0-9]+/ }, :defaults => { :format => 'json' }
  get "form_orders/:order_number" => "orders#show_by_order_number", :constraints  => { :order_number => /[0-9\-\.]+/ }
  post "form_orders/" => "orders#create"


  get "orders/" => "orders#index"
  post "orders/" => "orders#create"
  get "orders/:id(.format)" => "orders#show", :constraints  => { :id => /\d{1,13}/ }, :defaults => { :format => 'json' }
  get "orders/:order_number" => "orders#show_by_order_number", :constraints  => { :order_number => /\d{14,}/ }
  get "orders/:order_number" => "orders#show_by_order_number", :constraints  => { :order_number => /[0-9\-\.]+/ }
  put "orders/:id" => "orders#update", :constraints  => { :id => /[0-9]+/ }
  delete "orders/:id" => "orders#destroy", :constraints  => { :id => /[0-9]+/ }
  get "orders/search" => "orders#search"

  # Notes
  get "orders/:order_id/notes" => "notes#index", :constraints  => { :order_id => /[0-9]+/ }

  get "notes/" => "notes#index"
  post "notes/" => "notes#create"
  get "notes/:id" => "notes#show", :constraints  => { :id => /[0-9]+/ }
  put "notes/:id" => "notes#update", :constraints  => { :id => /[0-9]+/ }
  delete "notes/:id" => "notes#destroy", :constraints  => { :id => /[0-9]+/ }

  # Email templates
  get "email_templates/" => "email_templates#index"
  get "email_templates/:id" => "email_templates#show", :constraints  => { :id => /[0-9]+/ }

  # Delivery sources
  get "delivery_sources/" => "delivery_sources#index"
  get "delivery_sources/:id" => "delivery_sources#show", :constraints  => { :id => /[0-9]+/ }

  get "statistics/" => "statistics#index"


  #match 'some_action/:id' => 'controller#action', :constraints  => { :order_id => /[0-9\-\.]+/ }

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
