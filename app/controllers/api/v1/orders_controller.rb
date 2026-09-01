module Api
  module V1
    class OrdersController < ApplicationController
      # Anyone can place an order; only the panel can list or move them.
      before_action :require_admin, only: [ :index, :show, :status ]

      def index
        orders = Order.includes(:customer).order(created_at: :desc)
        render json: OrderBlueprint.render(orders)
      end

      def show
        order = Order.includes(:customer, order_items: :product).find(params[:id])
        render json: OrderBlueprint.render(order, view: :full)
      end

      def create
        result = Orders::Creator.new(order_params).call

        if result.success?
          render json: OrderBlueprint.render(result.value, view: :full), status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      def status
        order = Order.includes(order_items: :product).find(params[:id])
        result = Orders::StatusTransition.new(order, params.require(:status)).call

        if result.success?
          render json: OrderBlueprint.render(result.value, view: :full)
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def order_params
        params.require(:order).permit(
          :customer_id, :delivery_date, :notes, :payment_method,
          items: [ :product_id, :quantity ]
        )
      end
    end
  end
end
