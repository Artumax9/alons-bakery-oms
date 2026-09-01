require "rails_helper"

RSpec.describe "Api::V1::Customers", type: :request do
  describe "POST /api/v1/customers" do
    it "creates a customer without an admin token (checkout is public)" do
      post "/api/v1/customers",
           params: { customer: { name: "Ana", phone: "+58 111" } }, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["name"]).to eq("Ana")
    end
  end

  describe "GET /api/v1/customers" do
    it "returns 401 without the admin token" do
      get "/api/v1/customers"

      expect(response).to have_http_status(:unauthorized)
    end

    it "lists customers with the admin token" do
      create(:customer, name: "Ana")

      get "/api/v1/customers", headers: admin_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.map { |c| c["name"] }).to include("Ana")
    end
  end
end
