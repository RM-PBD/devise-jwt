class UsersController < ApplicationController

  before_action :authenticate_user!

  # ensures user needs to be authenticated

  def show
  end

  # show action doesn't require any logic since I can access current_user from the templates in views

  def update
    if current_user.update_attributes(user_params)
      render :show
      # This is renders the custom JSON template created in views
    else
      render json: { errors: current_user.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :bio, :image)
  end

  # This method is used for retrieving white-listed user params
  # only values params listed with 'permit' are available

end
