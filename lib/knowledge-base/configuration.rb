# frozen_string_literal: true

module KnowledgeBase
  class Configuration
    cattr_accessor :scope_class, :messages_require_approval

    def self.reset
      self.scope_class                    = nil
      self.messages_require_approval      = false
    end
  end
end
