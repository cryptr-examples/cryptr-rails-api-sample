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
 