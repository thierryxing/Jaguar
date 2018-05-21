Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  require 'sidekiq/web'
  require 'sidekiq-scheduler'
  require 'sidekiq-scheduler/web'

  default_url_options :host => ENV['JAGUAR_HOST']

  mount Sidekiq::Web => '/sidekiq'
  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

  scope '/api/v1' do

    get '/', to: 'application#index'

    resources :account, only: [] do
      collection do
        post :login
        get :logout
      end
    end

    resources :fastlane_templates

    resources :activity, only: [] do
      get :executing_builds, on: :collection
    end

    resources :dashboard, only: [] do
      get :index, on: :collection
      get :weekly_data, on: :collection
    end

    resources :projects

    scope(path: 'projects/:project_id', module: :projects, as: :project) do

      resources :home, only: [] do
        member do
          get :sync_gitlab
        end
      end

      resources :builds do
        member do
          get :log
          get :download
          get :mark_status
        end
      end

      resources :environments do
        member do
          get :configs
          get :build_info
          post :clone
          post :build
        end
      end

      resources :dependencies, only: [:index]

      scope(path: 'environments/:environment_id', module: :environments, as: :environment) do
        resources :services, only: [:index, :edit, :update]
        resources :fastlane, only: [:index] do
          put :update_fastfile, on: :collection
        end
        resources :git, only: [] do
          collection do
            get :clone
            get :branches
            get :tags
            put :choose_branch
            put :choose_tag
          end
        end
      end

    end

    resources :users do
      get 'set_platform/:platform', to: 'users#set_platform'
    end

  end

end
