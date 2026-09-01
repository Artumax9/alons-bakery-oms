module Api
  module V1
    class CustomersController < ApplicationController
      def index
        render json: CustomerBlueprint.render(Customer.order(:name))
      end

      def show
        render json: CustomerBlueprint.render(Customer.find(params[:id]))
      end

      def create
        customer = Customer.new(customer_params)

        if customer.save
          render json: CustomerBlueprint.render(customer), status: :created
        else
          render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :phone, :email)
      end
    end
  end
end
