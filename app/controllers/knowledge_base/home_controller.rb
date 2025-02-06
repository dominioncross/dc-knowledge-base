# frozen_string_literal: true

require_dependency 'knowledge_base/application_controller'

module KnowledgeBase
  class HomeController < ApplicationController
    def index
      if universal_user.nil?
        render(file: Rails.public_path.join('404.html').to_s, status: :not_found, layout: false) and return
      end

      current_channel if !universal_user.nil? && universal_user.has?(:knowledge_base, :create_channels,
                                                                     universal_scope)
    end

    def init
      if Universal::Configuration.scoped_user_groups
        users = Universal::Configuration.class_name_user.classify.constantize.where("_ugf.knowledge_base.#{universal_scope.id}" => { '$ne' => nil })
      else
        users = Universal::Configuration.class_name_user.classify.constantize.where('_ugf.knowledge_base' => { '$ne' => nil })
      end
      users = users.sort_by(&:name).map do |u|
        { name: u.name,
          email: u.email,
          first_name: u.name.split[0].titleize,
          id: u.id.to_s,
          functions: (if u.universal_user_group_functions.blank?
                        []
                      else
                        (Universal::Configuration.scoped_user_groups ? u.universal_user_group_functions['knowledge_base'][universal_scope.id.to_s] : u.universal_user_group_functions['knowledge_base'])
                      end) }
      end

      json = { config: knowledge_base_config.to_json, users: users, subscriber: current_subscriber.to_json }

      if universal_user
        json.merge!({ universal_user: {
                      name: universal_user.name,
                      email: universal_user.email,
                      functions: (if universal_user.universal_user_group_functions.blank?
                                    []
                                  else
                                    (if Universal::Configuration.scoped_user_groups
                                       universal_user.universal_user_group_functions['knowledge_base'].nil? ? [] : universal_user.universal_user_group_functions['knowledge_base'][universal_scope.id.to_s]
                                     else
                                       universal_user.universal_user_group_functions['knowledge_base']
                                     end)
                                  end)
                    } })
      end
      render json: json
    end
  end
end
