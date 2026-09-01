require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:customer) { create(:customer) }
  let(:rolls) { create(:product, price: 1500, stock: 20) }

  describe "GET /api/v1/orders" do
    it "lists orders newest first with the customer name" do
      create(:order, customer: customer, status: :pending)

      get "/api/v1/orders", headers: admin_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.first).to include(
        "status" => "pending",
        "customer_name" => customer.name
      )
    end

    it "returns 401 without the admin token" do
      get "/api/v1/orders"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["errors"]).to eq([ "unauthorized" ])
    end
  end

  describe "POST /api/v1/orders" do
    it "creates the order and returns 201 with the discounted total" do
      post "/api/v1/orders", params: {
        order: {
          customer_id: customer.id,
          delivery_date: 2.days.from_now,
          items: [ { product_id: rolls.id, quantity: 12 } ]
        }
      }, as: :json

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["discount_amount"].to_f).to eq(1500.0)
      expect(body["total_price"].to_f).to eq(16500.0)
      expect(body["order_items"].size).to eq(1)
    end

    it "returns 422 when stock is insufficient" do
      post "/api/v1/orders", params: {
        order: { customer_id: customer.id, delivery_date: 2.days.from_now,
                 items: [ { product_id: rolls.id, quantity: 999 } ] }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"].join).to match(/insufficient stock/)
    end

    it "returns 422 for a missing product" do
      post "/api/v1/orders", params: {
        order: { customer_id: customer.id, delivery_date: 2.days.from_now,
                 items: [ { product_id: 0, quantity: 1 } ] }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 400 when the order params are missing" do
      post "/api/v1/orders", params: {}, as: :json

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /api/v1/orders/:id/status" do
    it "advances the status on a valid transition" do
      order = create(:order, status: :pending, customer: customer)

      patch "/api/v1/orders/#{order.id}/status",
            params: { status: "confirmed" }, headers: admin_headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["status"]).to eq("confirmed")
    end

    it "returns 422 on an invalid transition" do
      order = create(:order, status: :pending, customer: customer)

      patch "/api/v1/orders/#{order.id}/status",
            params: { status: "delivered" }, headers: admin_headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 401 without the admin token" do
      order = create(:order, status: :pending, customer: customer)

      patch "/api/v1/orders/#{order.id}/status", params: { status: "confirmed" }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
