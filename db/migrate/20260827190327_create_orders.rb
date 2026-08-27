class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.integer :status
      t.datetime :delivery_date
      t.decimal :total_price, precision: 8, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
