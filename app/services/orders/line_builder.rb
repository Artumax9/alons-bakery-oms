module Orders
  # Turns the raw JSON items ([{ product_id:, quantity: }]) into unsaved
  # OrderItem objects, pulling unit_price from the Product row in the database —
  # never from the request. This freezes the price at order time: if Alondra
  # raises a price tomorrow, past orders keep theirs.
  class LineBuilder
    def initialize(items_params)
      @items_params = Array(items_params)
    end

    def call
      return ServiceResult.failure("order must have at least one item") if @items_params.empty?

      lines = []
      errors = []

      @items_params.each do |raw|
        product_id = raw[:product_id] || raw["product_id"]
        quantity = (raw[:quantity] || raw["quantity"]).to_i
        product = Product.available.find_by(id: product_id)

        if product.nil?
          errors << "product #{product_id.inspect} not found or unavailable"
        elsif quantity <= 0
          errors << "quantity for product #{product_id} must be greater than 0"
        else
          lines << OrderItem.new(product: product, quantity: quantity, unit_price: product.price)
        end
      end

      return ServiceResult.failure(errors) if errors.any?

      ServiceResult.success(lines)
    end
  end
end
