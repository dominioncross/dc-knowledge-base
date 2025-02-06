# frozen_string_literal: true

module KnowledgeBase
  class Config
    include Mongoid::Document
    include Universal::Concerns::Scoped
    include Universal::Concerns::Tokened

    store_in collection: 'kb_configs'

    field :system_name
    field :url
    field :hp, as: :hashed_password
    field :gak, as: :google_api_key
    field :su, as: :sms_url
    field :ss, as: :sms_source
    field :sus, as: :sms_username
    field :sp, as: :sms_password
    field :lb, as: :labels, type: Hash, default: {}

    def to_json(*_args)
      {
        scope_id: scope_id.to_s,
        system_name: system_name,
        url: url,
        token: token,
        labels: labels,
        hashed_password: hashed_password,
        google_api_key: google_api_key,
        sms_url: sms_url,
        sms_source: sms_source,
        sms_username: sms_username,
        sms_password: sms_password
      }
    end

    def self.find_by_scope(scope)
      KnowledgeBase::Config.find_or_create_by(scope: scope)
    end
  end
end
