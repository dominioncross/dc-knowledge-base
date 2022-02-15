module KnowledgeBase
  class ApplicationController < ::ApplicationController
    helper Universal::ApplicationHelper
    
    #need helper methods: universal_scope and universal_user
    helper_method :universal_crm_config, :current_subscriber, :current_channel
    
    def current_subscriber
      if universal_user and universal_scope
        @current_subscriber ||= KnowledgeBase::Subscriber.find_or_create_by(user: universal_user, scope: universal_scope)
      end
    end
    
    def knowledge_base_config
      @knowledge_base_config ||= KnowledgeBase::Config.find_by_scope(universal_scope)
    end
    
    def current_channel
      if !params[:channel].blank? and @channel.nil?
        @channel = KnowledgeBase::Channel.find_by(name: params[:channel].sanitize, scope: universal_scope)
        if @channel.nil? and universal_user.has?(:knowledge_base, :create_channels, universal_scope)
          @channel = KnowledgeBase::Channel.find_or_create_by(name: params[:channel].sanitize, scope: universal_scope)
        end
      end
      return @channel.nil? ? nil : @channel.name
    end
    
  end
end
