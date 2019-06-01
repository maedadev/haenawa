require 'resque/server'
require 'resque/scheduler/server'

Rails.application.routes.draw do
  mount Resque::Server.new, at: '/resque', as: :resque

  resources :projects, shallow: true do
    resources :scenarios, except: :index do
      member do
        patch :move_up
        patch :move_down
      end

      resources :steps, only: %i[index show create edit update destroy]

      resources :build_histories, only: %i[index show create]
    end
  end

  resource :system_setting, except: :destroy do
    get :download_node
    get :grid
  end

  # 将来、各種コントローラのアクションがAPIとの互換性を維持できなくなった際は、
  # 旧仕様用のコントローラを「app/controllers/api/<旧版>/」以下に定義する。
  scope :api do
    scope :v1 do
      resources :projects, shallow: true, only: :show do
        resources :scenarios, only: [] do
          resources :build_histories, only: %i[show create]
        end
      end
    end
  end

  root to: 'top#index'
end
