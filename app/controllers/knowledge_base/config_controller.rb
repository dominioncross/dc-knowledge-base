# frozen_string_literal: true

require_dependency 'knowledge_base/application_controller'

module KnowledgeBase
  class ConfigController < ApplicationController
    def show
      respond_to do |format|
        format.json { render json: knowledge_base_config.to_json }
        format.html {}
      end
    end

    def update
      params[:config][:labels] = {} if params[:config][:labels].blank?
      p = params.require(:config).permit(:system_name, :url, :google_api_key, :sms_url, :sms_source, :sms_username,
                                         :sms_password)
      p[:labels] = params[:config][:labels].sanitize
      knowledge_base_config.update(p)
      render json: knowledge_base_config.to_json
    end

    def set_password
      password = params[:password]
      hashed_password = Digest::SHA1.hexdigest(password)
      knowledge_base_config.update(hashed_password: hashed_password)
      knowledge_base_config.reload
      render json: knowledge_base_config.to_json
    end

    def signin
      password = params[:password]
      hashed_password = Digest::SHA1.hexdigest(password)
      render json: { signedIn: (knowledge_base_config.hashed_password == hashed_password) }
    end
  end
end
