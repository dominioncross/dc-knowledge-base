require_dependency "knowledge_base/application_controller"

module KnowledgeBase
  class HomeController < ApplicationController
    
    def index
      render(file: "#{Rails.root}/public/404.html", status: 404, layout: false) and return if universal_user.nil? #they must be signed in
      current_channel if !universal_user.nil? and universal_user.has?(:knowledge_base, :create_channels, universal_scope)
    end

    def init
      if Universal::Configuration.scoped_user_groups
        users = Universal::Configuration.class_name_user.classify.constantize.where("_ugf.knowledge_base.#{universal_scope.id.to_s}" => {'$ne' => nil})
      else
        users = Universal::Configuration.class_name_user.classify.constantize.where('_ugf.knowledge_base' => {'$ne' => nil})
      end
      users = users.sort_by{|a| a.name}.map{|u| {name: u.name, 
          email: u.email, 
          first_name: u.name.split(' ')[0].titleize, 
          id: u.id.to_s, 
          functions: (u.universal_user_group_functions.blank? ? [] : (Universal::Configuration.scoped_user_groups ? u.universal_user_group_functions['knowledge_base'][universal_scope.id.to_s] : u.universal_user_group_functions['knowledge_base']))}}
      
      json = {config: knowledge_base_config.to_json, users: users, subscriber: current_subscriber.to_json}

      if universal_user
        json.merge!({universal_user: {
          name: universal_user.name,
          email: universal_user.email,
          functions: (universal_user.universal_user_group_functions.blank? ? [] : (Universal::Configuration.scoped_user_groups ? (universal_user.universal_user_group_functions['knowledge_base'].nil? ? [] : universal_user.universal_user_group_functions['knowledge_base'][universal_scope.id.to_s]) : universal_user.universal_user_group_functions['knowledge_base']))
        }})
      end
      render json: json
    end
    
  end
end
