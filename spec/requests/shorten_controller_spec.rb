require 'rails_helper'

RSpec.describe "Shortens", type: :request do
  describe "POST /encode" do
    subject {post "/encode", params: {url:}}

    context "success" do
      context "when url is new" do
        let(:url) {"https://www.example.com"}

        it "returns the shortened url" do
          expect{subject}.to change{Url.count}.by(1)
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json).to have_key("short_url")
        end
      end

      context "when url has leading/trailing spaces" do
        let(:url) {"   https://www.example.com   "}

        it "trims the spaces and returns the shortened url" do
          expect{subject}.to change{Url.count}.by(1)
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json).to have_key("short_url")
          expect(Url.last.origin_url).to eq url.strip
        end
      end

      context "when url already exists" do
        let!(:url_record) {create(:url)}
        let(:url) {url_record.origin_url}
        let(:expected_result) {ShortenUrlService.encode(url_record.origin_url.length, url_record.id)}

        it "returns the existing shortened url" do
          expect{subject}.not_to change{Url.count}
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json).to have_key("short_url")
          expect(json["short_url"]).to eq "#{request.base_url}/#{expected_result}"
        end
      end

      context "with the same url before" do
        let(:url) {Faker::Internet.url}
        let!(:url_record) {create(:url, origin_url: url)}
        let(:expected_result) {ShortenUrlService.encode(url_record.origin_url.length, url_record.id)}

        it "returns the same shortened url for the same original url" do
          expect{subject}.not_to change{Url.count}
          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json).to have_key("short_url")
          expect(json["short_url"]).to eq "#{request.base_url}/#{expected_result}"
        end
      end
    end

    context "failure" do
      context "with invalid url" do
        let(:url) {"invalid_url"}

        it "returns bad request status" do
          expect{subject}.not_to change{Url.count}
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to match(/is invalid/)
        end
      end

      context "with empty url" do
        let(:url) {""}

        it "returns bad request status" do
          expect{subject}.not_to change{Url.count}
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to match(/can't be blank/)
        end
      end

      context "with missing url param" do
        subject {post "/encode", params: {}}

        it "returns bad request status" do
          expect{subject}.not_to change{Url.count}
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to match(/can't be blank/)
        end
      end

      context "when an unexpected error occurs" do
        let(:url) {"https://www.example.com"}

        before do
          allow(Url).to receive(:find_by).and_raise(StandardError.new("Unexpected error"))
        end

        it "returns internal server error status" do
          expect{subject}.not_to change{Url.count}
          expect(response).to have_http_status(:internal_server_error)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to eq "Unexpected error"
        end
      end
    end
  end

  describe "POST /decode" do
    before do
      allow(ENV).to receive(:fetch).with("DOMAIN_NAME", "localhost").and_return(domain)
      post "/decode", params: {url:}
    end

    let(:domain) {"www.example.com"}

    context "success" do
      let!(:url_record) {create(:url)}
      let(:code) {ShortenUrlService.encode(url_record.origin_url.length, url_record.id)}
      let(:url) {"http://#{domain}/#{code}"}

      it "returns the original url" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("origin_url")
        expect(json["origin_url"]).to eq url_record.origin_url
      end
    end

    context "failure" do
      context "with non-existing code" do
        let(:url) {"http://#{domain}/nonexist"}

        it "returns not found status" do
          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to eq "Record not found"
        end
      end

      context "with invalid url format" do
        let(:url) {"invalid_url"}

        it "returns bad request status" do
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to eq "URL is invalid"
        end
      end

      context "with URL not matching domain" do
        let(:url) {"http://unauthorized.com/abcd"}

        it "returns bad request status" do
          expect(response).to have_http_status(:bad_request)
          json = JSON.parse(response.body)
          expect(json).to have_key("error")
          expect(json["error"]).to eq "URL is invalid"
        end
      end
    end
  end
end
