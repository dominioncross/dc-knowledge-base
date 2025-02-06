# frozen_string_literal: true

module KnowledgeBase
  module Concerns
    module Logged
      extend ActiveSupport::Concern
      included do
        has_many :logs, as: :subject, class_name: 'KnowledgeBase::Message'

        def log!(scope, message, channel, user)
          log = logs.create scope: scope, message: message, channel: channel, user: user
          logger.debug log.errors.to_json
        end
      end
      def self.html_log_format_value(v)
        if v.instance_of?(TrueClass)
          'Yes'
        elsif v.instance_of?(FalseClass)
          'No'
        elsif v.instance_of?(NilClass)
          'N/A'
        elsif v.instance_of?(Array)
          v.join(', ')
        elsif v.instance_of?(Time)
          v.strftime('%b %d, %Y')
        elsif v.instance_of?(Date)
          v.strftime('%b %d, %Y - %I:%M%p')
        else
          v
        end
      end

      module ClassMethods
        def html_log_format(doc, attributes)
          Rails.logger.debug attributes
          h = attributes.map do |att|
            "<div class=\"log-item\"><span class=\"log-label\">#{att[1]}:</span> <span class=\"log-value\">#{Logged.html_log_format_value(doc[att[0]])}</span></div>"
          end
          h.join
        end
      end
    end
  end
end
