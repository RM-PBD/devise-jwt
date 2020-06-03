Rails.application.routes.draw do

scope :api, defaults: { format: :json } do
  devise_for :users, controllers: { sessions: :sessions },
                       path_names: { sign_in: :login }

                       # Here I am telling router to use our sessions controller
                       # and changing path url name for login auth end point


   resource :user, only: [:show, :update]

    end

end
