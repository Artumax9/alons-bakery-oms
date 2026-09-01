require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  describe "GET /api/v1/products" do
    it "returns only active products as JSON" do
      active = create(:product, name: "Cachito")
      create(:product, :inactive, name: "Discontinued")

      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      names = response.parsed_body.map { |p| p["name"] }
      expect(names).to contain_exactly(active.name)
    end

    it "exposes the catalog fields the storefront needs" do
      create(:product, image_url: "https://example.com/roll.jpg", category: "Dulces")

      get "/api/v1/products"

      expect(response.parsed_body.first).to include(
        "image_url" => "https://example.com/roll.jpg",
        "category" => "Dulces"
      )
    end
  end

  describe "GET /api/v1/products/:id" do
    it "returns the product" do
      product = create(:product)

      get "/api/v1/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to eq(product.id)
    end

    it "returns 404 with an error body for an unknown id" do
      get "/api/v1/products/0"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["errors"]).to be_present
    end
  end
end
