# frozen_string_literal: true

module KnowledgeBase
  class Engine < ::Rails::Engine
    isolate_namespace KnowledgeBase

    config.after_initialize do
      Universal::Configuration.class_name_user = 'Padlock::User'
      KnowledgeBase::Configuration.reset
    end

    config.generators do |generator|
      generator.test_framework :rspec
      generator.fixture_replacement :factory_bot
      generator.factory_bot dir: 'spec/factories'
    end
  end
end
