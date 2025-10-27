require 'rails_helper'

RSpec.describe ShortenUrlService do
  describe '.encode' do
    subject {ShortenUrlService.encode(length, id)}

    let(:length) {Faker::Number.between(from: 10, to: 100)}
    let(:id) {Faker::Number.between(from: 1, to: 1000)}

    context "with a valid input" do
      it 'encodes length and id into a code' do
        is_expected.to be_a(String)
        expect(subject.length).to be >= 6
      end
    end

    context "with same input returns same encode" do
      it 'returns the same code for the same length and id' do
        first_code = ShortenUrlService.encode(length, id)

        is_expected.to eq(first_code)
      end
    end
  end

  describe '.decode' do
    subject {ShortenUrlService.decode(code)}

    let(:code) {ShortenUrlService.encode(length, id)}
    let(:length) {Faker::Number.between(from: 10, to: 100)}
    let(:id) {Faker::Number.between(from: 1, to: 1000)}

    context "success" do
      context "with a valid encoded code" do
        it 'decodes a code back into the original id' do
          is_expected.to eq(id)
        end
      end

      context "with same input returns same decode" do
        it 'returns the same id for the same code' do
          first_id = ShortenUrlService.decode(code)

          is_expected.to eq id
          expect(first_id).to eq id
        end
      end
    end

    context "failure" do
      context "with an invalid encoded code" do
        let(:invalid_code) {"invalidcode#"}

        subject {ShortenUrlService.decode(invalid_code)}

        it 'returns nil for an invalid code' do
          is_expected.to be_nil
        end
      end

      context "with aninvalid alphabet" do
        let!(:code) {ShortenUrlService.encode(10, id)}
        let(:invalid_alphabet) {("a".."z").to_a.shuffle.join[0..10]}

        before do
          ShortenUrlService::SQIDS.instance_variable_set(:@alphabet, invalid_alphabet)
        end

        it 'returns nil when decoding with an invalid alphabet' do
          is_expected.to be_nil
        end
      end
    end
  end
end
