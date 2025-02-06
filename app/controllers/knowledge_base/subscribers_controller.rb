# frozen_string_literal: true

require_dependency 'knowledge_base/application_controller'

module KnowledgeBase
  class SubscribersController < ApplicationController
    def update
      current_subscriber.update(phone_number: params[:phone_number])
      render json: current_subscriber.to_json
    end
  end
end
