require "knowledge-base/engine"
require "knowledge-base/configuration"
Gem.find_files("knowledge-base/models/*.rb").each { |path| require path }

module KnowledgeBase
  
  Universal::Configuration.class_name_user = 'Padlock::User'
  
end
