module Stock
  # Reserves (decrements) and releases (restores) product stock for a set of
  # order lines. Every call must run inside a transaction so the row locks are
  # held until commit.
  #
  # Product.lock issues `SELECT ... FOR UPDATE`, so two orders racing for the
  # last cake can't both succeed.
  class Reservation
    def self.reserve(line_items)
      new(line_items).reserve
    end

    def self.release(line_items)
      new(line_items).release
    end

    def initialize(line_items)
      @line_items = line_items
    end

    def reserve
      needed_by_product = quantities_by_product
      # Lock every product up front, then check them all before mutating any —
      # so a partial reservation never lands even outside a transaction.
      products = Product.lock.where(id: needed_by_product.keys).index_by(&:id)

      errors = needed_by_product.filter_map do |product_id, needed|
        product = products.fetch(product_id)
        next if product.stock >= needed

        "insufficient stock for #{product.name} (need #{needed}, have #{product.stock})"
      end

      return ServiceResult.failure(errors) if errors.any?

      needed_by_product.each do |product_id, needed|
        product = products.fetch(product_id)
        product.update!(stock: product.stock - needed)
      end

      ServiceResult.success
    end

    def release
      quantities_by_product.each do |product_id, quantity|
        product = Product.lock.find(product_id)
        product.update!(stock: product.stock + quantity)
      end

      ServiceResult.success
    end

    private

    def quantities_by_product
      @line_items.group_by { |item| item.product_id || item.product.id }
                 .transform_values { |items| items.sum { |i| i.quantity } }
    end
  end
end
