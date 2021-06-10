# Cryptr with Rails API

## 03 - Validate Access Token

### Install dependencies

🛠️️ Open up `Gemfile` and add this gem:

`gem 'jwt'`

```ruby
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
 
ruby '2.7.1'
# Add this gem:
gem 'jwt'
# ...
```

🛠️️ Open your terminal and type this command:

```bash
bundle install
```

### JsonWebToken

🛠️️ Create `JsonWebToken` file in the lib folder

```bash
touch lib/json_web_token.rb
```

🛠️️ Now open up `lib/json_web_token.rb` and add the following code:

```ruby
#frozen_string_literal: true
require 'net/http'
require 'uri'
 
class JsonWebToken
  def self.verify(token)
    puts jwks_hash.count
    token_decode = jwks_hash.map do |kid, key|
      begin
        verify_token_with_key(token, key, kid)
      rescue JWT::VerificationError, JWT::DecodeError => e
        Rails.logger.info "failed with kid #{kid}: #{e}"
        nil
      end
    end
    token_decode.compact.first
  end
  
  def self.verify_token_with_key(token, key, kid)
    decoded = JWT.decode(token, key,
            true,
            algorithms: 'RS256',
            verify_iat: true,
            verify_jti: true,
            iss: issuer,
            verify_iss: true,
            aud: ENV['CRYPTR_AUDIENCE'],
            verify_aud: true)
    payload, header = decoded
    if header["kid"] == kid
      decoded
    end
  end
    def self.jwks_hash
    jwks_raw = Net::HTTP.get jwks_uri
    jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
    Hash[
      jwks_keys
      .map do |k|
        [
          k['kid'],
          OpenSSL::X509::Certificate.new(
            Base64.decode64(k['x5c'].first)
          ).public_key
        ]
      end
    ]
  end
  
  def self.issuer
    "#{ENV['CRYPTR_BASE_URL']}/t/#{ENV['TENANT_DOMAIN']}"
  end
    def self.jwks_uri
    URI("#{issuer}/.well-known")
  end
end
```

👀 Let's take a quick look at this file so that you can see how it works:

- The public key is fetched in `jwks_hash`
- The fetched token is verified with `decoded` param
- The header token is compared with the fetched key

🛠️️ Now open up `config/application.rb` and add this line to load the lib folder files:

`config.eager_load_paths << Rails.root.join("lib")`

```ruby {6}
module CryptrRailsApiSample
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
  
    # Add your Cryptr config:
    config.before_configuration do
      ENV['CRYPTR_BASE_URL'] = 'https://auth.cryptr.eu'
      ENV['TENANT_DOMAIN'] = 'shark-academy'
      ENV['CRYPTR_AUDIENCE'] = 'http://localhost:8081'
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  
    # Load lib folder files  
    config.eager_load_paths << Rails.root.join("lib")
  
    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
```

Note: __We need to load the files from the lib folder because the file was not designed by rails, we must let it know that it can read it.__

### Define a Secured concern

🛠️️ Create these files in the `app/controllers/concerns` folder:

```bash
touch app/controllers/concerns/secured.rb
```

🛠️️ Now open up the secured file in `app/controllers/concerns/secured.rb` and paste in the following code:

```ruby
#frozen_string_literal: true
module Secured
  extend ActiveSupport::Concern
  
  included do
    before_action :authenticate_request!, except: :options
  end
  
  private
  
  def authenticate_request!
    auth_payload, auth_header = auth_token
  
    if auth_payload === nil || auth_header === nil
      render json: { error: ['Not authenticated'] }, status: :unauthorized
    end
  end
  
  def http_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    end
  end
  
  def auth_token
    puts http_token
    JsonWebToken.verify(http_token)
  end
end
```

This file will check the token in the `Authorization` headers:

- if the token is not present, it is unauthorized.  
- if the token is present, it is passed to the `JsonWebToken.verify`

Scope: __Thanks to the `auth_payload`, you can refine the request with scopes__

```ruby
def authenticate_request!
  auth_payload, auth_header = auth_token

  if auth_payload === nil || auth_header === nil
    render json: { error: ['Not authenticated'] }, status: :unauthorized
  # Handle scope checking
  elsif auth_paylaod["scp"] !== ["openid" ....]
    render json: { error: ['Insufficient scope'] }, status: :unauthorized
  end
end
```

### Render Courses

🛠️️ Create a controller to render courses in `app/controllers`, it’s an api controller where index returns courses:

```bash
touch app/controllers/api_v1_controller.rb
```

🛠️️ Next, open up the api controller file in `app/controllers/api_v1_controller.rb` and paste in the following code:

```ruby
class ApiV1Controller < ApplicationController
 
  def index
    render json: [
      {
        "id" => 1,
        "user_id" =>
        "eba25511-afce-4c8e-8cab-f82822434648",
        "title" => "learn git",
        "tags" => ["colaborate", "git" ,"cli", "commit", "versionning"],
        "img" => "https://carlchenet.com/wp-content/uploads/2019/04/git-logo.png",
        "desc" => "Learn how to create, manage, fork, and collaborate on a project. Git stays a major part of all companies projects. Learning git is learning how to make your project better everyday",
        "date" => '5 Nov',
        "timestamp" => 1604577600000,
        "teacher" => {
            "name" => "Max",
            "picture" => "https://images.unsplash.com/photo-1558531304-a4773b7e3a9c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80"
        }
      }
    ]
  end
  
  private
  
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = ENV['CRYPTR_AUDIENCE']
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with'
  end
end
```

🛠️️ Call the `set_access_control_headers` function in the `before_action` [callback](https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action), all actions of the controller will inherit it. This will cause the `set_access_control_headers` function (which allows you to manage the cors) to be executed before each action of the controller.

```ruby
class ApiV1Controller < ApplicationController
 
 before_action :set_access_control_headers
 def index
    render json: [
      {
        "id" => 1,
        "user_id" =>
        "eba25511-afce-4c8e-8cab-f82822434648",
        "title" => "learn git",
        "tags" => ["colaborate", "git" ,"cli", "commit", "versionning"],
        "img" => "https://carlchenet.com/wp-content/uploads/2019/04/git-logo.png",
        "desc" => "Learn how to create, manage, fork, and collaborate on a project. Git stays a major part of all companies projects. Learning git is learning how to make your project better everyday",
        "date" => '5 Nov',
        "timestamp" => 1604577600000,
        "teacher" => {
            "name" => "Max",
            "picture" => "https://images.unsplash.com/photo-1558531304-a4773b7e3a9c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80"
        }
      }
    ]
 end
 
# ...
```

🛠️️ Now, open up `config/routes.rb` and copy paste this code to associate the controller with the routes:

```ruby
Rails.application.routes.draw do
  get "/api/v1/courses", to: 'api_v1#index'
  options "/api/v1/courses", to: 'api_v1#options'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

We can retrieve the response using a HTTP `GET` request on `http://localhost:3000/api/v1/courses`

🛠️️ Run the server with the command `rails s` and open **insomnia** or **postman** to make a `GET` request which should end with `200`

[Next](https://github.com/cryptr-examples/cryptr-rails-api-sample/tree/04-protect-api-endpoints)
