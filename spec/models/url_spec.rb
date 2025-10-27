require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'validations' do
    subject {build(:url)}

    it {is_expected.to validate_presence_of(:origin_url)}
    it {is_expected.to validate_uniqueness_of(:origin_url)}
    it {is_expected.to allow_value('https://www.example.com').for(:origin_url)}
    it {is_expected.not_to allow_value('invalid_url').for(:origin_url)}
  end
end
