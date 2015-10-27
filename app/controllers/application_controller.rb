class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

#
# Aktivera autentiseringen för resp. action (before_filter :validate_token, :only => [...])
#
# T.ex.
# before_filter :validate_token, only: [:create, :update]
  ##before_filter :validate_token

  private
  def validate_token
    token = params[:token]
    token_object = AccessToken.find_by_token(token)
    if !token_object || !token_object.user.validate_token(token)
      render json: {error: "Invalid token"}, status: 401
    end
  end
end
