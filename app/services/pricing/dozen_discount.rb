module Pricing
  # Calculates the discount for a single order line (one product, one quantity).
  #
  # Rule (PENDING confirmation with Alondra): the discount applies per product.
  # Every complete dozen pays for 11 units instead of 12 — one free unit per
  # dozen. 6 cinnamon rolls + 6 croissants do NOT combine into a dozen.
  #
  # If the rule changes (a flat percentage, a whole-order discount, a different
  # free-unit count), this is the ONLY class that changes. Nothing else in the
  # system knows the rule.
  #
  # TODO: confirm UNITS_PER_DOZEN / FREE_UNITS_PER_DOZEN with Alondra.
  class DozenDiscount
    UNITS_PER_DOZEN = 12
    FREE_UNITS_PER_DOZEN = 1

    def initialize(quantity:, unit_price:)
      @quantity = quantity.to_i
      @unit_price = unit_price.to_d
    end

    # Returns the discount amount for the line (always >= 0).
    def amount
      return 0.to_d if @quantity <= 0 || @unit_price <= 0

      free_units = complete_dozens * FREE_UNITS_PER_DOZEN
      (free_units * @unit_price).round(2)
    end

    private

    def complete_dozens
      @quantity / UNITS_PER_DOZEN
    end
  end
end
