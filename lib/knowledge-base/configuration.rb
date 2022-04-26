module KnowledgeBase
  class Configuration

    cattr_accessor :scope_class, :mongoid_session_name, :messages_require_approval

    def self.reset
      self.scope_class                    = nil
      self.mongoid_session_name           = :forklift
      self.messages_require_approval      = false
    end

  end
end
KnowledgeBase::Configuration.reset
