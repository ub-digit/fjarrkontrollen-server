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

  def get_token
    if request.headers["Authorization"]
      request.headers["Authorization"][/^Bearer (.*)/, 1]
    end
  end

  def get_secret_token
    params[:token]
  end

  def validate_token
    unless @current_user
      token = get_token
      token_object = AccessToken.find_by_token(token)
      if !token_object || !token_object.user.validate_token(token)
        render json: {error: "Invalid token"}, status: 401
      else
        @current_user = token_object.user
      end
    end
  end
end
