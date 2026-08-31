module Orders
  # Given the order lines, returns the money breakdown. Knows nothing about
  # HTTP or persistence.
  class Calculator
    Totals = Struct.new(:subtotal, :discount, :total, keyword_init: true)

    def initialize(line_items)
      @line_items = line_items
    end

    def totals
      subtotal = @line_items.sum { |item| item.subtotal }
      discount = @line_items.sum do |item|
        Pricing::DozenDiscount.new(quantity: item.quantity, unit_price: item.unit_price).amount
      end

      Totals.new(subtotal: subtotal, discount: discount, total: subtotal - discount)
    end
  end
end
