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
    
    def to_json
      {
        scope_id: self.scope_id.to_s,
        system_name: self.system_name,
        url: self.url,
        token: self.token,
        labels: self.labels,
        hashed_password: self.hashed_password,
        google_api_key: self.google_api_key,
        sms_url: self.sms_url,
        sms_source: self.sms_source,
        sms_username: self.sms_username,
        sms_password: self.sms_password
      }
    end
      
    def self.find_by_scope(scope)
      return KnowledgeBase::Config.find_or_create_by(scope: scope)
    end
  end
end
