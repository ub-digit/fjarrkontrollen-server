Illbackend::Application.routes.draw do

  resources :session
  
  get "libris_info/neg_responses"
  get "libris_info/user_requests"
 
  get "app_info/deployinfo"
  get "users/authorise"

  get 'users' => 'users#index'
  get 'users/:id' => 'users#show', :constraints => { :id => /[0-9]+/ }
  get 'users/:xkonto' => 'users#show_by_xkonto', :constraints => { :xkonto => /[A-Za-z]+/ }
  put 'users/:id' => 'users#update', :constraints => { :id => /[0-9]+/ }

  get 'statuses' => 'statuses#index'
  get 'statuses/:id' => 'statuses#show', :constraints => { :id => /[0-9]+/ }

  get 'status_groups' => 'status_groups#index'
  get 'status_groups/:id' => 'status_groups#show', :constraints => { :id => /[0-9]+/ }

  get 'order_types' => 'order_types#index'
  get 'order_types/:id' => 'order_types#show', :constraints => { :id => /[0-9]+/ }

  get 'pickup_locations' => 'pickup_locations#index'
  get 'pickup_locations/:id' => 'pickup_locations#show', :constraints => { :id => /[0-9]+/ }
  get 'pickup_locations/:label' => 'pickup_locations#show_by_label', :constraints => { :label => /[A-Za-z\-]+/ }

  get 'managing_groups' => 'managing_groups#index'
  get 'managing_groups/:id' => 'managing_groups#show', :constraints => { :id => /[0-9]+/ }
  get 'managing_groups/:label' => 'managing_groups#show_by_label', :constraints => { :label => /[A-Za-z\-]+/ }

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

  # Delivery sources
  get "delivery_methods/" => "delivery_methods#index"
  get "delivery_methods/:id" => "delivery_methods#show", :constraints  => { :id => /[0-9]+/ }

  get "statistics/" => "statistics#index"

end
