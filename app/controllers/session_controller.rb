class SessionController < ApplicationController
  def create
    if params[:code]
      uri = URI(APP_CONFIG['oauth2']['token_endpoint'])
      body = {
        "client_id" => APP_CONFIG['oauth2']['client_id'],
        "client_secret" => APP_CONFIG['oauth2']['client_secret'],
        "code" => params[:code]
      }
      response = Net::HTTP.post(
        uri,
        body.to_json,
        'content-type' => 'application/json',
        'accept' => 'application/json'
      )
      case response
      when Net::HTTPSuccess then
        json_response = JSON.parse(response.body)
        if json_response["access_token"]
          token = json_response["access_token"]
          uri = URI(APP_CONFIG['oauth2']['user_endpoint'])
          response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
            request = Net::HTTP::Get.new(uri)
            #/vnd.github?
            request['Accept'] = 'application/vnd.github+json'
            request['Authorization'] = "Bearer #{token}"
            request['X-GitHub-Api-Version'] = '2022-11-28'
            response = http.request(request)
            response
          }

          case response
          when Net::HTTPSuccess
            json_response = JSON.parse(response.body)
            if json_response["login"]
              username = json_response["login"]
              user = User.find_by_xkonto(username)
              if user
                token_object = user.generate_token()
                render json: {user: user, access_token: token_object.token, token_type: "bearer"}
              else
                render json: {error: {msg: "User not found"}}, status: 401
              end
            else
              render json: {error: {msg: "Invalid user data"}}, status: 401
            end
          else
            error = "User service request failed: #{response.message}"
            render json: {error: {msg: error}}, status: 401
          end
        else
          error = json_response["error"] ? json_response["error"] : "Unknown error"
          render json: {error: {msg: error}}, status: 401
        end
      else
        # TODO: Should perhaps be 500
        error = "OAuth service request failed: #{response.message}"
        render json: {error: {msg: error}}, status: 401
      end
    else
      render json: {error: {msg: "Missing 'code' parameter"}}, status: 401
    end
  end

  def show
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token)
      render json: {user: token_object.user, access_token: token, token_type: "bearer"}
    else
      render json: {error: "Invalid session"}, status: 401
    end
  end
end
