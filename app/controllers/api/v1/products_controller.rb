module Api
  module V1
    class ProductsController < ApplicationController
      def index
        products = Product.available.order(:name)
        render json: ProductBlueprint.render(products)
      end

      def show
        product = Product.find(params[:id])
        render json: ProductBlueprint.render(product)
      end
    end
  end
end
