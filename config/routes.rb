Semjo::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  
  namespace :admin do
  
    resources :articles do
      member do 
        get :preview
      end
    end
  
    resources :pages do
      member do
        get :preview
      end 
    end
    
    resources :sessions

  end
  
  resources :articles
  resources :pages
  
  match '/admin' => redirect("/admin/articles")
  match '/feed.:format', :to => 'articles#feed'
  root :to => 'home#show'
  
end
