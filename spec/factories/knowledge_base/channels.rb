# frozen_string_literal: true

FactoryBot.define do
  factory :channel, class: KnowledgeBase::Channel do
    name { 'test' }
    association :scope, factory: :subscriber
  end
end
