class AddStockToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stock, :integer, default: 0, null: false
    add_check_constraint :products, "stock >= 0", name: "products_stock_non_negative"

    # Not used yet: the Fase 2 costing module (ingredients + labor) will write here.
    add_column :products, :labor_percentage, :decimal, precision: 5, scale: 2,
                                                       default: 0, null: false
  end
end
