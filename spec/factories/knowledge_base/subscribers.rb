# frozen_string_literal: true

FactoryBot.define do
  factory :subscriber, class: KnowledgeBase::Subscriber do
    phone_number { '12345' }
  end
end
