class AddDiscountAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    # Stored apart from total_price so the calculation stays auditable:
    # total_price = subtotal - discount_amount
    add_column :orders, :discount_amount, :decimal, precision: 8, scale: 2,
                                                    default: 0, null: false
  end
end
