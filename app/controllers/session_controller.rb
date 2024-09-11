class SessionController < ApplicationController

  def create
    if params[:code]
      body = {
        "client_id" => APP_CONFIG['oauth2']['client_id'],
        "client_secret" => APP_CONFIG['oauth2']['client_secret'],
        "code" => params[:code]
      }
      token_uri = URI(APP_CONFIG['oauth2']['token_endpoint'])

      APP_CONFIG['oauth2']['provider'] = 'github'

      if APP_CONFIG['oauth2']['provider'] == 'gu'
        authenticate_by_gu(body, token_uri)
      elsif APP_CONFIG['oauth2']['provider'] == 'github'
        authenticate_by_github(body, token_uri)
      else
        render json: {error: {msg: "Unknown OAuth2 provider"}}, status: 400
      end
    else
      render json: {error: {msg: "Missing 'code' parameter"}}, status: 400
    end
  end

  def show
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token)
      render json: {user: token_object.user, access_token: token, token_type: "bearer"}
    else
      # TODO: Inconsistent error format
      render json: {error: "Invalid session"}, status: 401
    end
  end

  private
  def authenticate_by_gu(body, token_uri)
    additional_body = {
      "grant_type" => "authorization_code",
      "redirect_uri" => "https://" + APP_CONFIG['frontend_hostname'] + "/torii/redirect.html"
    }
    body = body.merge(additional_body)

    http = Net::HTTP.new(token_uri.host, token_uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(token_uri.request_uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.set_form_data(body)
    response = http.request(request)

    case response
    when Net::HTTPSuccess then
      begin
        json_response = JSON.parse(response.body)
      rescue JSON::ParserError
        render json: {error: {msg: "Invalid JSON response"}}, status: 500
        return
      end
      if json_response["id_token"]
        token = json_response["id_token"]
        begin
          # Handle token as a JWT, decode it and extract the username
          decoded_token = JWT.decode(token, nil, false)
          username = decoded_token.first["account"]
          authenticated_user_response(username)
        rescue JWT::DecodeError
          render json: {error: {msg: "Invalid token"}}, status: 500
        end
      else
        render json: {error: {msg: "Invalid data"}}, status: 500
      end
    else
      render json: {error: {msg: "Oauth request failed"}}, status: 500
    end
  end

  def authenticate_by_github(body, token_uri)
    # TODO: Don't think keyword args as headers work for this version of Net::HTTP
    # (seems to work anyway though)
    response = Net::HTTP.post(
      token_uri,
      body.to_json,
      'Content-type' => 'application/json',
      'Accept' => 'application/json'
    )

    case response
    when Net::HTTPSuccess then
      begin
        json_response = JSON.parse(response.body)
      rescue JSON::ParserError
        render json: {error: {msg: "Invalid JSON response"}}, status: 500
        return
      end
      if json_response["access_token"]
        token = json_response["access_token"]
        uri = URI(APP_CONFIG['oauth2']['user_endpoint'])
        response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
          request = Net::HTTP::Get.new(uri)
          request['Accept'] = 'application/vnd.github+json'
          request['Authorization'] = "Bearer #{token}"
          request['X-GitHub-Api-Version'] = '2022-11-28'
          response = http.request(request)
          response
        }
        case response
          when Net::HTTPSuccess then
            begin
              json_response = JSON.parse(response.body)
            rescue JSON::ParserError
              render json: {error: {msg: "Invalid JSON response"}}, status: 500
              return
            end
            if json_response["login"]
              authenticated_user_response(json_response["login"])
            else
              # This should really never happen
              render json: {error: {msg: "Invalid user data"}}, status: 500
            end
          else
            render json: {error: {msg: "User request failed"}}, status: 500
          end
      else
        error = json_response["error"] ? json_response["error"] : "Unknown error"
        render json: {error: {msg: error}}, status: 500
      end
    else
      render json: {error: {msg: "OAuth request failed"}}, status: 500
    end
  end

  def authenticated_user_response(username)
    user = User.find_by_xkonto(username)
    if user
      token_object = user.generate_token()
      render json: {user: user, access_token: token_object.token, token_type: "bearer"}
    else
      render json: {error: {msg: "User not found"}}, status: 401
    end
  end
end
