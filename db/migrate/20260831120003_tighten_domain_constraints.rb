class TightenDomainConstraints < ActiveRecord::Migration[8.0]
  def up
    # Defaults first, so any existing NULL row gets backfilled by the
    # change_column_null default argument below.
    change_column_default :orders, :status, from: nil, to: 0
    change_column_default :orders, :total_price, from: nil, to: 0
    change_column_default :products, :active, from: true, to: true

    change_column_null :orders, :status, false, 0
    change_column_null :orders, :delivery_date, false, Time.current
    change_column_null :orders, :total_price, false, 0

    change_column_null :order_items, :quantity, false, 1
    change_column_null :order_items, :unit_price, false, 0

    change_column_null :products, :price, false, 0
    change_column_null :products, :active, false, true

    change_column_null :customers, :name, false, "Unknown"
    change_column_null :customers, :phone, false, "Unknown"
  end

  def down
    change_column_null :orders, :status, true
    change_column_null :orders, :delivery_date, true
    change_column_null :orders, :total_price, true
    change_column_null :order_items, :quantity, true
    change_column_null :order_items, :unit_price, true
    change_column_null :products, :price, true
    change_column_null :products, :active, true
    change_column_null :customers, :name, true
    change_column_null :customers, :phone, true

    change_column_default :orders, :status, from: 0, to: nil
    change_column_default :orders, :total_price, from: 0, to: nil
  end
end
