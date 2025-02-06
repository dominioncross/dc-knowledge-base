# frozen_string_literal: true

require_dependency 'knowledge_base/application_controller'

module KnowledgeBase
  class FlagsController < ApplicationController
    before_action :find_subject

    def toggle
      if @subject.flagged_with?(params[:flag])
        @add = false
        @subject.remove_flag!(params[:flag])
        # @subject.save_comment!("Removed label: '#{params[:flag]}'", universal_user, universal_scope)
      else
        @add = true
        @subject.flag!(params[:flag], universal_user)
        # @subject.save_comment!("Added label: '#{params[:flag]}'", universal_user, universal_scope)
      end
      render json: { flags: @subject.flags }
    end

    private

    def find_subject
      if params[:subject_type].present? && (params[:subject_type] != 'undefined') && params[:subject_id].present? && (params[:subject_id] != 'undefined')
        @subject = params[:subject_type].classify.constantize.find(params[:subject_id])
      end
    end
  end
end
