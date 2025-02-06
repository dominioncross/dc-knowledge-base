# frozen_string_literal: true

require 'rails_helper'

module KnowledgeBase
  RSpec.describe Channel, type: :model do
    subject(:model) { build(:channel) }

    it { expect(model).to be_valid }
  end
end
