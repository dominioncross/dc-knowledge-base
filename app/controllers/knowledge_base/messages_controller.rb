require_dependency "knowledge_base/application_controller"

module KnowledgeBase
  class MessagesController < ApplicationController
    
    def index
      find_messages
      
      render json: messages_json
    end
    
    def create
      @message = KnowledgeBase::Message.new params[:message]
      @message.scope = universal_scope if !universal_scope.nil?
      @message.channel = current_channel
      @message.status = KnowledgeBase::Configuration.messages_require_approval ? :pending : :active
      if !universal_user.nil?
        @message.user = universal_user 
        @message.author = universal_user.name
      end
      if @message.save
        #send SMS, find subscribers to this channel
        if !knowledge_base_config.sms_url.blank?
          subscribers = KnowledgeBase::Subscriber.subscribed_to(current_channel).where(scope: universal_scope)
          require 'universal/sms_broadcast'
          subscribers.each do |subscriber|
            SmsBroadcast.send(knowledge_base_config, subscriber.phone_number, "#{universal_user.name} posted in the ##{current_channel} channel. #{knowledge_base_config.url}/#{current_channel}", current_channel)
          end
        end
      end
      find_messages
      render json: messages_json
    end
    
    def show
      @message = KnowledgeBase::Message.find(params[:id])
      render json: @message.to_json
    end
    
    def destroy
      @message = KnowledgeBase::Message.find(params[:id])
      @message.deleted!
      render json: {}
    end
    
    def update_status
      @message = KnowledgeBase::Message.find(params[:id])
      @message.update(status: params[:status])
      render json: {message: @message.to_json}
    end
    
    def pin
      @message = KnowledgeBase::Message.find(params[:id])
      @message.pin!
      render json: @message.to_json
    end
    
    private
      def find_messages
        @messages = KnowledgeBase::Message.all
        if KnowledgeBase::Configuration.messages_require_approval
          @messages = @messages.where(
            '$or' => [
              {status: 'active'},
              {'$and' => [
                status: 'pending',
                user_id: current_user.id
              ]}
            ]  
          )
        else
          @messages = @messages.in(status: %w(pending active))
        end
        @messages = @messages.scoped_to(universal_scope) if !universal_scope.nil?
        if !params[:keyword].blank?
          keywords = params[:keyword].split(' ')
          conditions = []
          keywords.each do |keyword|
            if !keyword.blank?
              conditions.push({'$or' => [
                {message: /\b#{keyword}/i}, 
                {author: /\b#{keyword}/i},
                {channel: /\b#{keyword}\b/i},
                {subject_name: /\b#{keyword}\b/i},
                {tags: /\b#{keyword}\b/i}
              ]})
            end
          end
          @messages = @messages.where('$and' => conditions)
        else
          @messages = @messages.where(channel: current_channel) if !current_channel.blank?
        end
      end
    
      def messages_json
        per=10
        params[:page] = 1 if params[:page].blank?
        @messages = @messages.page(params[:page]).per(per)
        return {
          pagination: {
            total_count: @messages.total_count,
            page_count: @messages.total_pages,
            current_page: params[:page].to_i,
            per_page: per
          },
          messages: @messages.map{|t| t.to_json}
        }
      end
      
  end
end
